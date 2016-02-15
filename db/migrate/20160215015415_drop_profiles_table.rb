class DropProfilesTable < ActiveRecord::Migration
  def up
    drop_table :profiles
  end

  def down
    create_table "profiles" do |t|
      t.integer  "user_id", null: false
      t.string   "twitter"
      t.string   "facebook"
      t.string   "website"
      t.string   "linkedin"
      t.string   "blog"
      t.boolean  "show_name_on_site", default: false, null: false
      t.string   "gravatar_email"
      t.string   "summary",           limit: 2000
      t.string   "reasons",           limit: 2000
      t.string   "projects",          limit: 2000
      t.string   "skills",            limit: 2000
      t.string   "feminism",          limit: 2000
      t.timestamps
    end

    add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree
  end
end
