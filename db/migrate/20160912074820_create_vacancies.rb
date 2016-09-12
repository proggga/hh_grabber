class CreateVacancies < ActiveRecord::Migration
  def change
    create_table :vacancies do |t|
      t.string :url
      t.string :name
      t.string :company
      t.float :salary_from
      t.float :salary_to
      t.string :city
      t.string :metro_station
      t.string :expirience
      t.text :desciption

      t.timestamps null: false
    end
  end
end
