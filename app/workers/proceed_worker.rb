# ecoding: utf-8
require 'tiny_grabber'

class ProceedWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :proceed, :retry => true, :backtrace => false

  def perform(name, url, parent_url)
    Vacancy.parse_card(name, url, parent_url) do | url, parent_url, name, company, salary, city, expirience, description |
      SaveWorker.perform_async(url, parent_url, name, company, salary, city, expirience, description)
    end
  end
end
