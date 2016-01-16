require_dependency 'contact_note'

module  RedmineLeads
  module NotePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        after_create :update_contact

        def update_contact
          db_table = ContactNote.table_name
          c = Contact.where("#{Contact.table_name}.id IN (  SELECT #{Contact.table_name}.id FROM #{Contact.table_name}
           INNER JOIN #{db_table} ON #{db_table}.source_id = #{Contact.table_name}.id and #{db_table}.source_type = 'Contact'
            GROUP BY #{Contact.table_name}.id HAVING COUNT(#{db_table}.id) > 0)").
              joins("INNER JOIN #{db_table} ON #{db_table}.source_id = #{Contact.table_name}.id and #{db_table}.source_type = 'Contact'  ").
              group(" #{Contact.table_name}.id HAVING COUNT(#{db_table}.id) > 0").select("contacts.*, notes.id AS note_id, notes.created_on AS followup").where("notes.id = #{self.id}").first


          if c and c.note_id == self.id
            cn = c.notes.order("#{Note.table_name}.created_on DESC").first
            c.last_note = cn.created_on
            # c.last_note = c.followup
            c.save
          end
        end
      end
    end
  end
end

