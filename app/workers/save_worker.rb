# ecoding: utf-8
require 'tiny_grabber'

class SaveWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :save, :retry => true, :backtrace => false

  def perform(url, parent_url, name, company, salary, city, expirience, description)
    Vacancy.transaction do
      Vacancy.create(url: url, parent_url: parent_url, name:  name, company: company, salary: salary, city: city, expirience: expirience, description: description)
    end
  end
end
