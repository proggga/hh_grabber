class HardWorker
  include Sidekiq::Worker
  def perform(name, count)
    print "dddo #{name} something #{count}\n"
    sleep(10)
  end
end
