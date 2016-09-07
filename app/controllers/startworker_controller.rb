class StartworkerController < ApplicationController
  def run
    HardWorker.perform_async('bob', 5)
  end
end
