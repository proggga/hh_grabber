# ecoding: utf-8
require 'tiny_grabber'

class DownloadWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :download, :retry => false, :backtrace => false

  def perform(keyword)
    user_agent = 'curl/7.24.0'
    headers = { 'Content-Type' => 'text/html; charset=utf-8' }
    tg = TinyGrabber.new
    print "START\n"
    tg.debug = { active: true, destination: :print, save_html: true }
    tg.headers = headers
    tg.user_agent = user_agent
    main_url = "https://spb.hh.ru/search/vacancy?text=#{keyword}"
    url = main_url.dup
    begin
      print "LLOPIN\n"
      response = tg.get url, headers
      print "AFFTER GET\n"
      url = response['location']
    end until main_url == response['location'] or response.instance_of?(Net::HTTPOK)
    #
    #print response.body
    ng = response.ng
    urls = []
    ng.css('a.search-result-item__name').each do |alink|
      urls.push([alink.text, alink['href']])
    end
    puts "yolo", urls
    return response.body
    ng = response.ng
    new_url = ng.xpath("//meta/@content").to_s
    new_url = new_url.gsub('0;url=','')

    response = tg.get new_url, headers

    new_url = response['location']
    response = tg.get new_url, headers
    puts response.body
  end
end
