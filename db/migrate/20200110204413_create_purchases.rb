class CreatePurchases < ActiveRecord::Migration[6.0]
  def change
    create_table :purchases do |t|
      t.string :token
      t.string :card_token
      t.string :last_four
      t.string :card_type
      t.references :product

      t.timestamps
    end
  end
end
