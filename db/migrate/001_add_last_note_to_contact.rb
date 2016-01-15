
class AddLastNoteToContact < ActiveRecord::Migration
  def self.up
    add_column :contacts, :last_note, :datetime
    Contact.all.each do |c|
      cn = c.notes.last
      if cn
        c.last_note = cn.created_on
        c.save
      end
    end
  end

  def self.down
    remove_column :contacts, :last_note
  end
end