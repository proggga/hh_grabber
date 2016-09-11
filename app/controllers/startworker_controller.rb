class StartworkerController < ApplicationController
  def run
    word = 'ruby'
    if params.has_key?(:keyword)
      word = params[:keyword]
    end
    DownloadWorker.perform_async(word, 5, 0)
    render plain: "command 'search #{word}' accepted"
  end
end
