class CreateSellerProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :seller_profiles do |t|
      t.references :payment, null: false, foreign_key: true
      t.string :seller_name
      t.string :business_name

      t.timestamps
    end
  end
end
