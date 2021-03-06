class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string :company_name
      t.string :contact_name
      t.string :contact_title
      t.string :address
      t.string :city
      t.string :region
      t.string :postal_code
      t.string :country
      t.string :phone
      t.string :fax

      t.timestamps
    end
  end

  def self.down
    drop_table :customers
  end
end
