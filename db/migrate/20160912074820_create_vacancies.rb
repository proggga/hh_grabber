class CreateVacancies < ActiveRecord::Migration
  def change
    create_table :vacancies do |t|
      t.string :url
      t.string :parent_url
      t.string :name
      t.string :company
      t.string :salary
      t.string :city
      t.string :expirience
      t.text :description

      t.timestamps null: false
    end
  end
end
