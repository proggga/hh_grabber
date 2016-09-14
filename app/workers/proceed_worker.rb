# ecoding: utf-8
require 'tiny_grabber'

class ProceedWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :proceed, :retry => true, :backtrace => false

  def perform(name, url)
    if not Vacancy.exists?(url: url)
      user_agent = 'curl/7.24.0'
      headers = { 'Content-Type' => 'text/html; charset=utf-8' }
      tg = TinyGrabber.new
      tg.debug = { active: false, destination: :print, save_html: true }
      tg.headers = headers
      tg.user_agent = user_agent
      response = tg.get url, headers
      ng = response.ng
      name = ng.css('.title.b-vacancy-title').text
      company = ng.css('div.companyname > a').text
      salary_block  = ng.xpath('//td[@class="l-content-colum-1 b-v-info-content"]/div')

      salary = 0

      salary_block.children.each do | item |
        if item.instance_of?(Nokogiri::XML::Text)
          salary = item.text.strip
        end
      end
      city = ng.css('td.l-content-colum-2.b-v-info-content > div').text
      expirience = ng.css('td.l-content-colum-3.b-v-info-content > div').text
      print "#{name} #{company} #{salary} #{city} #{expirience}\n"

      SaveWorker.perform_async(url, name, company, salary, city, expirience)
    end
  end
end
