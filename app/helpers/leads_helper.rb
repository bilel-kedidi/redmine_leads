
module LeadsHelper
  def lead_tag(contact, options={})
    avatar_size = options.delete(:size) || 16
    if contact.visible? && !options[:no_link]
      contact_avatar = link_to(avatar_to(contact, :size => avatar_size), lead_path(contact, :project_id => @project), :id => "avatar")
      contact_name = link_to_source(contact, :project_id => @project).gsub('contact', 'lead')
    else
      contact_avatar = avatar_to(contact, :size => avatar_size)
      contact_name = contact.name
    end

    case options.delete(:type).to_s
      when "avatar"
        contact_avatar.html_safe
      when "plain"
        contact_name.html_safe
      else
        content_tag(:span, "#{contact_avatar} #{contact_name}".html_safe, :class => "contact")
    end
  end

  def lead_tabs(contact)
    contact_tabs = []
    if !User.current.allowed_to_globally?(:hide_notes) or User.current.admin?
      contact_tabs << {:name => 'notes', :partial => 'leads/notes', :label => l(:label_crm_note_plural)} if contact.visible?
    end

    contact_tabs << {:name => 'contacts', :partial => 'company_contacts', :label => l(:label_contact_plural) + (contact.company_contacts.visible.count > 0 ? " (#{contact.company_contacts.count})" : "")} if contact.is_company?
    if !User.current.allowed_to_globally?(:hide_deals) or User.current.admin?
      contact_tabs << {:name => 'deals', :partial => 'deals/related_deals', :label => l(:label_deal_plural) + (contact.all_visible_deals.size > 0 ? " (#{contact.all_visible_deals.size})" : "") } if User.current.allowed_to?(:add_deals, @project)
    end
    contact_tabs
  end
end