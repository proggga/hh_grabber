class CreateVacancies < ActiveRecord::Migration
  def change
    create_table :vacancies do |t|
      t.string :url
      t.string :name
      t.string :company
      t.string :salary
      t.string :city
      t.string :expirience
      t.text :desciption

      t.timestamps null: false
    end
  end
end
