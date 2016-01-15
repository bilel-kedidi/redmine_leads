require_dependency 'contact_query'

module  RedmineLeads
  module ContactQueryPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        self.available_columns = [
            QueryColumn.new(:id, :sortable => "#{Contact.table_name}.id", :default_order => 'desc', :caption => '#'),
            QueryColumn.new(:name, :sortable => lambda {Contact.fields_for_order_statement}, :caption => :field_contact_full_name),
            QueryColumn.new(:first_name, :sortable => "#{Contact.table_name}.first_name"),
            QueryColumn.new(:last_name, :sortable => "#{Contact.table_name}.last_name"),
            QueryColumn.new(:middle_name, :sortable => "#{Contact.table_name}.middle_name", :caption => :field_contact_middle_name),
            QueryColumn.new(:job_title, :sortable => "#{Contact.table_name}.job_title", :caption => :field_contact_job_title, :groupable => true),
            QueryColumn.new(:company, :sortable => "#{Contact.table_name}.company", :groupable => "#{Contact.table_name}.company", :caption => :field_contact_company),
            QueryColumn.new(:phones, :sortable => "#{Contact.table_name}.phone", :caption => :field_contact_phone),
            QueryColumn.new(:emails, :sortable => "#{Contact.table_name}.email", :caption => :field_contact_email),
            QueryColumn.new(:address, :sortable => "#{Address.table_name}.full_address", :caption => :label_crm_address),
            QueryColumn.new(:street1, :sortable => "#{Address.table_name}.street1", :caption => :label_crm_street1),
            QueryColumn.new(:street2, :sortable => "#{Address.table_name}.street2", :caption => :label_crm_street2),
            QueryColumn.new(:city, :sortable => "#{Address.table_name}.city", :groupable => "#{Address.table_name}.city", :caption => :label_crm_city),
            QueryColumn.new(:region, :sortable => "#{Address.table_name}.region", :caption => :label_crm_region),
            QueryColumn.new(:postcode, :sortable => "#{Address.table_name}.postcode", :caption => :label_crm_postcode),
            QueryColumn.new(:country, :sortable => "#{Address.table_name}.country_code", :groupable => "#{Address.table_name}.country_code", :caption => :label_crm_country),
            QueryColumn.new(:tags),
            QueryColumn.new(:created_on, :sortable => "#{Contact.table_name}.created_on"),
            QueryColumn.new(:updated_on, :sortable => "#{Contact.table_name}.updated_on"),
            QueryColumn.new(:assigned_to, :sortable => lambda {User.fields_for_order_statement}, :groupable => true),
            QueryColumn.new(:author, :sortable => lambda {User.fields_for_order_statement("authors")}),
            QueryColumn.new(:last_note, :sortable => "#{Contact.table_name}.created_on", :caption => "Last_note")
        ]
      end
    end
  end
end

