# ecoding: utf-8
require 'tiny_grabber'

class DownloadWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :download, :retry => false, :backtrace => false

  def perform(keyword, main_url=nil, worker_page_id=1, add_pages=true)
    Vacancy.parse_page(keyword, main_url, worker_page_id, add_pages) do | vacancies_urls, pages_urls |
      vacancies_urls.each do | href, name |
        Sidekiq::Client.push('queue' => 'proceed', 'class' => ProceedWorker, 'args' => [name, href, main_url])
      end
      if add_pages
        pages_urls.each do | page_id, link |
          add_pages_flag = page_id == pages_urls.keys.max
          queue_push = add_pages_flag ? 'download' : 'collect'
          print "[#{worker_page_id}]PUT #{queue_push} #{link} #{page_id}\n"
          Sidekiq::Client.push('queue' => queue_push, 'class' => DownloadWorker, 'args' => [keyword, link, page_id, add_pages_flag])
        end
      end
    end
  end
end
