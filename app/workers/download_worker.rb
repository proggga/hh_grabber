class DownloadWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :download, :retry => true, :backtrace => false

  def perform(name, count, startid)
    print "dddo #{name} sleep with #{count}\n"
    sleep count
    print "completed #{name} do something\n"
    print ProceedWorker.perform_async(startid + 1)
    print ProceedWorker.perform_async(startid + 2)
    print ProceedWorker.perform_async(startid + 3)
  end
end
