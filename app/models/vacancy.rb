# ecoding: utf-8
require 'tiny_grabber'

class Vacancy < ActiveRecord::Base

  def self.parse_page(keyword, main_url=nil, worker_page_id=1, add_pages=true)
    user_agent = 'curl/7.24.0'
    main_server = "https://spb.hh.ru"
    headers = { 'Content-Type' => 'text/html; charset=utf-8' }
    tg = TinyGrabber.new
    tg.debug = { active: false, destination: :print, save_html: true }
    tg.headers = headers
    tg.user_agent = user_agent
    main_url = main_server + "/search/vacancy?text=#{keyword}" if not main_url

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
    pages_urls = {}
    if add_pages
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
    end
    yield vacancies_urls, pages_urls
  end

  def self.parse_card(name, url, parent_url)
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
      description = ng.css('div.b-vacancy-desc > div.b-vacancy-desc-wrapper').text
      print "#{name} #{company} #{salary} #{city} #{expirience}\n"

      yield url, parent_url, name, company, salary, city, expirience, description
    end
  end
end
