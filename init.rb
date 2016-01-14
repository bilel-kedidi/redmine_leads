Redmine::Plugin.register :redmine_leads do
  name 'Redmine Leads plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  requires_redmine :version_or_higher => '2.3'

  require 'redmine_contacts'

  project_module :leads do
    permission :view_leads, {
        :leads => [:show, :index, :live_search, :contacts_notes, :context_menu],
        :notes => [:show]
    }
    permission :view_private_leads, {
        :leads => [:show, :index, :live_search, :contacts_notes, :context_menu],
        :notes => [:show]
    }

    permission :add_leads, {
        :leads => [:new, :create],
        :contacts_duplicates => [:index, :duplicates],
        :contacts_vcf => [:load]
    }

    permission :edit_leads, {
        :leads => [:edit, :update, :bulk_update, :bulk_edit],
        :notes => [:create, :destroy, :edit, :update],
        :contacts_duplicates => [:index, :merge, :duplicates],
        :contacts_projects => [:new, :destroy, :create],
        :contacts_vcf => [:load]
    }

    permission :manage_lead_issue_relations, {
        :contacts_issues => [:new, :create_issue, :create, :delete, :close, :autocomplete_for_contact],
    }

    permission :delete_leads, :leads => [:destroy, :bulk_destroy]
    permission :add_notes, :notes => [:create]
    permission :delete_notes, :notes => [:destroy, :edit, :update]
    permission :delete_own_notes, :notes => [:destroy, :edit, :update]

    permission :manage_leads, {
        :projects => :settings,
        :contacts_settings => :save,
    }
    permission :import_leads, {:contact_imports => [:new, :create, :show, :settings, :mapping, :run]}
    permission :export_leads, {}
    permission :send_leads_mail, :leads => [:edit_mails, :send_mails, :preview_email]
    permission :manage_public_leads_queries, {}, :require => :member
    permission :save_leads_queries, {}, :require => :loggedin
    permission :manage_public_deals_queries, {}, :require => :member
    permission :save_deals_queries, {}, :require => :loggedin

    permission :hide_search, {}
    permission :hide_notes, {}
    permission :hide_tags, {}
    permission :hide_deals, {}
    permission :hide_filters_and_options, {}
    permission :view_assigned_lead, {}
    permission :view_status_filter, {}
    permission :view_date_filter, {}
    permission :view_follow_up, {}

  end


  menu :project_menu, :leads, { :controller => 'leads', :action => 'index' },
       caption: :label_lead_plural,
       :before => :activity, param: :project_id


  menu :top_menu, :leads,
       {:controller => 'leads', :action => 'index', :project_id => nil},
       :caption => :label_lead_plural,
       :if => Proc.new{ User.current.allowed_to?({:controller => 'leads', :action => 'index'},
                                                 nil, {:global => true})  && LeadsSetting.leads_show_in_top_menu? }

  menu :application_menu, :leads,
       {:controller => 'leads', :action => 'index'},
       :caption => :label_lead_plural,
       :if => Proc.new{ User.current.allowed_to?({:controller => 'leads', :action => 'index'},
                                                 nil, {:global => true})  && LeadsSetting.leads_show_in_app_menu? }

  # activity_provider :leads, :default => false, :class_name => ['ContactNote', 'Lead']

  Redmine::Search.map do |search|
    search.register :leads
  end



end

Rails.application.config.to_prepare do
  Contact.send(:include, RedmineLeads::ContactPatch)
  ContactQuery.send(:include, RedmineLeads::ContactQueryPatch)
end

