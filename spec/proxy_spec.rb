require 'spec_helper'

describe Actor::Proxy do
  before :each do
    @target = Object.new
    @proxy = Actor::Proxy.new @target
  end

  it 'sets the proxy target' do
    expect(@proxy.instance_eval '@proxy_target').to be @target
  end

  it 'preserves equality' do
    expect(@proxy).to eq @target
    expect(@proxy != @target).to be false
    expect(@proxy.equal? @target).to be true
  end

  it 'gets the proxy target' do
    expect(@proxy.__proxy_target).to be @target
  end

  it 'forwards messages via send' do
    @target.should_receive(:send).with :method, :to_s
    @proxy.method :to_s
  end
end
