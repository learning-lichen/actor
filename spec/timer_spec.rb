require 'spec_helper'

describe Actor::Timer do
  it 'executes for the given number of iterations' do
    iterations = 0
    Actor::Timer.new 0.033, 30 do
      iterations += 1
    end.wait

    expect(iterations).to be 30
  end

  it 'fires every period' do
    deltas = []
    last_time = Time.now - 0.033

    Actor::Timer.new 0.033, 30 do
      deltas << (Time.now - last_time).to_f
      last_time = Time.now
    end.wait

    deltas.each { |delta| expect(delta).to be_within(0.01).of(0.033) }
  end

  it 'pauses and resumes' do
    long_pointless_sum = 0
    timer = Actor::Timer.new 0.033, 3000 do
      long_pointless_sum += 1
    end

    timer.pause
    timer.pause # Verify that two messages get queued
    post_pause_sum = long_pointless_sum
    sleep 1

    pause_queue = timer.instance_variable_get(:@pause_queue)

    expect(long_pointless_sum).to be post_pause_sum
    expect(timer.instance_variable_get(:@timer_thread).status).to eq 'sleep'
    expect(pause_queue.pop).to be :paused
    expect(pause_queue.pop).to be :paused
    expect(pause_queue).to be_empty

    pause_queue.should_receive :clear
    timer.resume
    sleep 1

    expect(long_pointless_sum).to be > post_pause_sum
  end

  it 'blocks the calling thread when waiting' do
    side_effect = false
    Actor::Timer.new 0.01, 1 do 
      sleep 1
      side_effect = true
    end.wait

    expect(side_effect).to be true
  end
end
