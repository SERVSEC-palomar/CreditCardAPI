class CreateUsers < ActiveRecord::Migration
  def change
  	create_table :users do |u|
  		u.string :username
  		u.string :encrypted_fullname
  		u.string :encrytped_address
  		u.string :encrypted_dob
      	u.string :email
   		u.string :hashed_password
   		u.string :nonce
      	u.string :salt
      	u.timestamps null: true

  	end
  end
end
