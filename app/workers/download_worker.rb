# ecoding: utf-8
require 'tiny_grabber'

class DownloadWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :download, :retry => false, :backtrace => false

  def perform(keyword, main_url=nil, worker_page_id=1, add_pages=true)
    user_agent = 'curl/7.24.0'
    main_server = "https://spb.hh.ru"
    headers = { 'Content-Type' => 'text/html; charset=utf-8' }
    tg = TinyGrabber.new
    tg.debug = { active: false, destination: :print, save_html: true }
    tg.headers = headers
    tg.user_agent = user_agent
    main_url = main_server + "/search/vacancy?text=#{keyword}" if not main_url

    puts main_url

    url = main_url.dup
    begin
      response = tg.get url, headers
      url = response['location']
    end until main_url == response['location'] or response.instance_of?(Net::HTTPOK)
    #
    #print response.body
    ng = response.ng
    vacancies_urls = {}
    links = ng.css('div.search-result-item__head > a.search-result-item__name.search-result-item__name_standard')
    print "links size #{links.size}\n"
    links.each do |alink|
      vacancies_urls[alink['href']] = alink.text
    end
    print "vacancies size #{vacancies_urls.size}\n"
    vacancies_urls.each do | href, name |
      #print "#{name} #{href}\n"
      Sidekiq::Client.push('queue' => 'proceed', 'class' => ProceedWorker, 'args' => [name, href, main_url])
    end
    if add_pages
      pages_urls = {}
      ng.css('li[data-qa="pager-page"]>a.HH-Pager-Control').each do |alink|
        # ignore '...' page
        page = alink.text
        if page != '...'
          page_id = page.to_i
          if page_id > worker_page_id
            pages_urls[page_id] = main_server + alink['href']
          end
        end
      end
      pages_urls.each do | page_id, link |
        add_pages_flag = page_id == pages_urls.keys.max
        queue_push = add_pages_flag ? 'download' : 'collect'
        print "[#{worker_page_id}]PUT #{queue_push} #{link} #{page_id}\n"
        Sidekiq::Client.push('queue' => queue_push, 'class' => DownloadWorker, 'args' => [keyword, link, page_id, add_pages_flag])
      end
    end
  end
end
