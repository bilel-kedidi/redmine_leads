require_dependency 'contact'

module  RedmineLeads
  module ContactPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        acts_as_attachable :view_permission => [:view_leads, :view_leads],
                           :delete_permission => [:edit_contacts, :edit_leads]


        if ActiveRecord::VERSION::MAJOR >= 4
          acts_as_activity_provider :type => 'contacts',
                                    :permission => [:view_leads, :view_contacts],
                                    :author_key => :author_id,
                                    :scope => joins(:projects)

        else
          acts_as_activity_provider :type => 'contacts',
                                    :permission => [:view_leads, :view_contacts],
                                    :author_key => :author_id,
                                    :find_options => {:include => :projects}

        end


        def self.editable_condition(user, options={})
          self.visible_condition(user, options) + " AND (#{Project.allowed_to_condition(user, :edit_contacts)} OR #{Project.allowed_to_condition(user, :edit_leads)} )"
        end

        def self.deletable_condition(user, options={})
          self.visible_condition(user, options) + " AND (#{Project.allowed_to_condition(user, :delete_contacts)} OR #{Project.allowed_to_condition(user, :delete_leads)} )"
        end

        def self.visible_condition(user, options={})
          user.reload
          user_ids = [user.id] + user.groups.map(&:id)

          projects_allowed_to_view_contacts = Project.where("#{Project.allowed_to_condition(user, :view_leads)} OR #{Project.allowed_to_condition(user, :view_contacts)}").pluck(:id)
          allowed_to_view_condition = projects_allowed_to_view_contacts.empty? ? "(1=0)" : "#{Project.table_name}.id IN (#{projects_allowed_to_view_contacts.join(',')})"
          projects_allowed_to_view_private = Project.where("#{Project.allowed_to_condition(user, :view_private_contacts)} OR #{Project.allowed_to_condition(user, :view_private_leads)}").pluck(:id)
          allowed_to_view_private_condition = projects_allowed_to_view_private.empty? ? "(1=0)" : "#{Project.table_name}.id IN (#{projects_allowed_to_view_private.join(',')})"

          cond = "(#{Project.table_name}.id <> -1 ) AND ("
          if user.admin?
            cond << "(#{table_name}.visibility = 1) OR (#{allowed_to_view_condition}) "
          else
            cond << " (#{table_name}.visibility = 1) OR" if (user.allowed_to_globally?(:view_leads, {}) or user.allowed_to_globally?(:view_contacts, {}))
            cond << " (#{allowed_to_view_condition} AND #{table_name}.visibility <> 2) "

            if user.logged?
              cond << " OR (#{allowed_to_view_private_condition} " +
                  " OR (#{allowed_to_view_condition} " +
                  " AND (#{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}) )))"
            end
          end

          cond << ")"

        end
        def visible?(usr=nil)
          usr ||= User.current
          if self.is_public?
            usr.allowed_to_globally?(:view_leads, {}) or usr.allowed_to_globally?(:view_contacts, {})
          else
            self.allowed_to?(usr || User.current, :view_leads) or self.allowed_to?(usr || User.current, :view_contacts)
          end
        end

        def editable?(usr=nil)
          self.allowed_to?(usr || User.current, :edit_contacts) or self.allowed_to?(usr || User.current, :edit_leads)
        end

        def deletable?(usr=nil)
          self.allowed_to?(usr || User.current, :delete_contacts) or self.allowed_to?(usr || User.current, :delete_leads)
        end

        def allowed_to?(user, action, options={})
          if self.is_private?
            (self.projects.map{|p| user.allowed_to?(action, p)}.compact.any? && (self.author == user || user.is_or_belongs_to?(assigned_to))) ||
                (self.projects.map{|p| user.allowed_to?(:view_private_contacts, p)}.compact.any? && self.projects.map{|p| user.allowed_to?(action, p)}.compact.any?)
          else
            self.projects.map{|p| user.allowed_to?(action, p)}.compact.any?
          end
        end

        def send_mail_allowed?(usr=nil)
          usr ||= User.current
          @send_mail_allowed ||= 0 < self.projects.visible(usr).count(:conditions => Project.allowed_to_condition(usr, :send_contacts_mail))
        end

        def project(current_project=nil)
          return @project if @project
          if current_project && self.projects.visible.include?(current_project)
            @project  = current_project
          else
            @project  = self.projects.visible.where("#{Project.allowed_to_condition(User.current, :view_leads)} OR #{Project.allowed_to_condition(User.current, :view_contacts)}").first
          end

          @project ||= self.projects.first
        end
      end
    end

  end
  module ClassMethods
  end

  module InstanceMethods

  end

end
