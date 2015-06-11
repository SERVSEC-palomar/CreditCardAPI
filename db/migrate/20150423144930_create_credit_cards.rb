class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |card|
      card.string :nonce, :owner, :credit_network, :expiration_date, :user_id
      card.text :encrypted_number
      card.timestamps null: false
    end
  end
end
