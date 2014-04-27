require 'spec_helper'

describe Actor::Base do
  before :each do 
    @actor_class = Class.new do
      include Actor::Base

      def action
      end
    end
  end

  it 'initializes mailbox on creation' do
    proxy = @actor_class.new
    actor = proxy.__proxy_target
    
    expect(actor.instance_variable_get :@mailbox).not_to be nil
  end

  it 'initializes mailbox on creation of subclass' do
    child_actor = Class.new(@actor_class).new.__proxy_target
    expect(child_actor.instance_variable_get :@mailbox).not_to be nil
  end

  it 'receives proxied messages' do
    Thread.stub :new

    proxy = @actor_class.new
    actor = proxy.__proxy_target
    
    proxy.message1
    proxy.message2 :arg1, :arg2

    messages = actor.instance_variable_get :@mailbox
    expect(messages.size).to be 2
    expect(messages.pop).to eq [:message1, [], nil]
    expect(messages.pop).to eq [:message2, [:arg1, :arg2], nil]
  end

  it 'processes messages' do
    proxy = @actor_class.new
    actor = proxy.__proxy_target

    actor.should_receive :message1
    actor.should_receive(:message2).with :arg1
    actor.should_receive(:message3).with :arg1, :arg2

    proxy.message1
    proxy.message2 :arg1
    proxy.message3 :arg1, :arg2
    
    # Sleep because threads are lame.
    sleep 0.1

    messages = actor.instance_variable_get :@mailbox
    expect(messages.size).to be 0
  end

  it 'executes before/after callbacks' do    
    proxy = @actor_class.new
    actor = proxy.__proxy_target
        
    proxy.before_action :action do 
      actor.before_method
    end

    proxy.after_action :action do
      actor.after_method
    end
    
    actor.should_receive(:before_method).ordered
    actor.should_receive(:action).ordered
    actor.should_receive(:after_method).ordered
  
    proxy.action
    sleep 0.1
  end
end
