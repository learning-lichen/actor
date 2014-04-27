module Actor
  ##
  # Simple timer implementation
  class Timer
    ##
    # Create a new timer that fires every <period> milliseconds. The number of
    # iterations specifies how many times the timer should fire.
    #
    # * *Args*:
    #   - +period+: the time, in seconds, between firing the timer.
    #   - +iterations+: the number times the timer should fire. 0 iterations
    # means fire continuously
    def initialize period, iterations, &block
      @pause_queue = Queue.new

      i = iterations == 0 ? 1.0 / 0.0 : iterations
      @timer_thread = Thread.new do
        (1..i).step do
          sleep unless @pause_queue.empty?
          block.call
          sleep period
        end
      end
    end

    ##
    # Pauses the timer. The currently executing iteration is finished before
    # the time is paused
    def pause
      @pause_queue << :paused
    end

    ##
    # Resumes the timer
    def resume
      @pause_queue.clear
      @timer_thread.wakeup
    end

    ##
    # Block the current thread until the timer has finished executing
    def wait
      @timer_thread.join
    end
  end
end
