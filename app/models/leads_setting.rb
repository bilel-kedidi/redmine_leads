class LeadsSetting< ActiveRecord::Base
  unloadable

  def self.leads_show_in_top_menu?
    !!Setting.plugin_redmine_contacts["leads_show_in_top_menu"]
  end

  def self.leads_show_in_app_menu?
    !!Setting.plugin_redmine_contacts["leads_show_in_app_menu"]
  end
end