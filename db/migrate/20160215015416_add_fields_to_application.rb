class AddFieldsToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :why_andconf, :text
    add_column :applications, :feminism, :text
    add_column :applications, :programming_experience, :text
    add_column :applications, :diversity, :text

    rename_column :applications, :agreement_terms, :agreement_coc
    rename_column :applications, :agreement_policies, :agreement_attendance
    rename_column :applications, :agreement_female, :agreement_deadline
  end
end
