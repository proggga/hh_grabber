# ecoding: utf-8
require 'tiny_grabber'

class ProceedWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :proceed, :retry => true, :backtrace => false

  def perform(name, url)
    user_agent = 'curl/7.24.0'
    main_server = 'https://spb.hh.ru'
    headers = { 'Content-Type' => 'text/html; charset=utf-8' }
    tg = TinyGrabber.new
    tg.debug = { active: false, destination: :print, save_html: true }
    tg.headers = headers
    tg.user_agent = user_agent
    url = main_server + url
    response = tg.get url, headers
    url = response['location']
  end
end
#TODO parsing of https://spb.hh.ru/vacancy/18149155?query
