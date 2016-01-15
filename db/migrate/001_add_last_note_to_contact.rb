
class AddLastNoteToContact < ActiveRecord::Migration
  def self.up
    add_column :contacts, :last_note, :datetime
    db_table = ContactNote.table_name
    @contacts = Contact.where("#{Contact.table_name}.id IN (  SELECT #{Contact.table_name}.id FROM #{Contact.table_name}
           INNER JOIN #{db_table} ON #{db_table}.source_id = #{Contact.table_name}.id and #{db_table}.source_type = 'Contact'
            GROUP BY #{Contact.table_name}.id HAVING COUNT(#{db_table}.id) > 0)").
        joins("INNER JOIN #{db_table} ON #{db_table}.source_id = #{Contact.table_name}.id and #{db_table}.source_type = 'Contact'  ").
        group(" #{Contact.table_name}.id HAVING COUNT(#{db_table}.id) > 0")

    @contacts.each do |c|
      cn = c.notes.last
      c.last_note = cn.created_on
      c.save
    end
  end

  def self.down
    remove_column :contacts, :last_note
  end
end