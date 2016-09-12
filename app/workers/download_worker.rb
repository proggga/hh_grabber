# ecoding: utf-8
require 'tiny_grabber'

class DownloadWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :download, :retry => false, :backtrace => false

  def perform(keyword)
    headers = { 'Content-Type' => 'text/html; charset=utf-8' }
    tg = TinyGrabber.new
    tg.debug = { active: true, destination: :print, save_html: true }
    tg.headers = headers
    main_url = "https://spb.hh.ru/search/vacancy?text=#{keyword}"
    url = main_url.dup
    begin
      response = tg.get url, headers
      url = response['location']
    end until main_url == response['location'] or response.instance_of?(Net::HTTPOK)
    #
    ng = response.ng
    new_url = ng.xpath("//meta/@content").to_s
    new_url = new_url.gsub('0;url=','')

    response = tg.get new_url, headers

    new_url = response['location']
    response = tg.get new_url, headers
    puts response.body
  end
end
