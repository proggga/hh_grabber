class ProceedWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :proceed, :retry => true, :backtrace => false

  def perform(line_nu)
    print "Proceed file with #{line_nu}\n"
    sleep 5
    print "completed proceed line_nu #{line_nu}\n"
  end
end
