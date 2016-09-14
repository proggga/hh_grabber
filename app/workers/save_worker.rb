# ecoding: utf-8
require 'tiny_grabber'

class SaveWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :save, :retry => true, :backtrace => false

  def perform(url, name, company, salary, city, expirience)
    Vacancy.transaction do
      vacancy = Vacancy.create(url: url, name:  name, company: company, salary: salary, city: city, expirience: expirience)
    end
  end
end
