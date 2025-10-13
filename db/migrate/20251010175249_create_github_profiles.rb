class CreateGithubProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :github_profiles do |t|
      t.string :name, null: false
      t.string :nick, null: false
      t.string :github_url, null: false
      t.string :shortened_github_url
      t.integer :followers_count
      t.integer :following_count
      t.integer :stars_count
      t.integer :contributions_count
      t.string :image_url
      t.string :org
      t.string :location

      t.timestamps
    end
    
    add_index :github_profiles, :name
    add_index :github_profiles, :nick
    add_index :github_profiles, :github_url, unique: true
  end
end
