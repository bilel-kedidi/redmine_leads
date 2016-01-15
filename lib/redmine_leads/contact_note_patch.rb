require_dependency 'contact_note'

module  RedmineLeads
  module ContactNotePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        before_create :update_contact

        def update_contact
          if self.contact.last_note < self.created_on
            c = self.contact
            c.last_note =  self.created_on
            c.save
          end
        end
      end
    end
  end
end

