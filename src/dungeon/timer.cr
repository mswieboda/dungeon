module Dungeon
  class Timer
    def self.time(&block)
      time_start = Time.now

      yield

      time_end = Time.now

      time_end - time_start
    end
  end
end
