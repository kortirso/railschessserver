class CreateIdentities < ActiveRecord::Migration
    def change
        create_table :identities do |t|
            t.integer :user_id
            t.string :provider
            t.string :uid

            t.timestamps null: false
        end

        add_index :identities, :user_id
    end
end
