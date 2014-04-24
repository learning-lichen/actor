require 'spec_helper'

describe Actor::Base do
  before :each do 
    @actor_class = Class.new do
      include Actor::Base
      
      def out message
        puts message
      end
    end
  end

  it 'initializes mailbox on creation' do
    expect(@actor_class.new.instance_variable_get :@mailbox).not_to be nil
  end

  it 'initializes mailbox on creation of subclass' do
    child_actor = Class.new(@actor_class).new
    expect(child_actor.instance_variable_get :@mailbox).not_to be nil
  end

  it 'receives messages' do
    Thread.stub :new
    
    actor = @actor_class.new
    actor.send :message1
    actor.send :message2, :arg1, :arg2

    messages = actor.instance_variable_get :@mailbox
    expect(messages.size).to be 2
    expect(messages.pop).to eq [:message1, []]
    expect(messages.pop).to eq [:message2, [:arg1, :arg2]]
  end

  it 'processes messages' do
    actor = @actor_class.new
    actor.should_receive :message1
    actor.should_receive(:message2).with :arg1
    actor.should_receive(:message3).with :arg1, :arg2

    actor.send :message1
    actor.send :message2, :arg1
    actor.send :message3, :arg1, :arg2
    
    # Sleep because threads are lame.
    sleep 0.1

    messages = actor.instance_variable_get :@mailbox
    expect(messages.size).to be 0
  end
end
