class StartworkerController < ApplicationController
  def run
    word = 'ruby'
    if params.has_key?(:keyword)
      word = params[:keyword]
    end
    DownloadWorker.perform_async(word)
    render plain: "command 'search #{word}' accepted"
  end

  def test
    ProceedWorker.perform_async('Yolo bro', 'https://spb.hh.ru/vacancy/18149155?query', 'http:/lol')
    ProceedWorker.perform_async('Yolo bro', 'https://spb.hh.ru/vacancy/18157830?query=ruby', 'http:/lol')
    render plain: "ok"
  end
end
