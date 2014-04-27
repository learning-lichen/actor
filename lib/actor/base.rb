require 'set'
require 'actor/proxy'

module Actor
  ##
  # Module that actors should include
  module Base
    ##
    # Adds a new message to the queue
    def send method_name, *args, &block
      @mailbox << [method_name, args, block]
    end

    ##
    # Adds a listener that is called before the including object performs 
    # the specified action.
    #
    # * *Args*:
    #   - +action+: the action (symbol) the hook into
    #   - +block+: the block to execute before the specified action
    def before_action action, &block
      @audience[:before][action] ||= Set.new
      @audience[:before][action] << block
    end

    ##
    # Adds a listener that is called after the including object performs 
    # the specified action.
    #
    # * *Args*:
    #   - +action+: the action the hook into
    #   - +block+: the block to execute after the specified action
    def after_action action, &block
      @audience[:after][action] ||= Set.new
      @audience[:after][action] << block
    end

    ##
    # Adds a hook before object initialization to automatically sets up the
    # thread that executes actions and sets up the callback data structures.
    #
    # * *Args*:
    #   - +klass+: the class whose initialization is hooked into.
    def self.included klass
      class << klass
        alias_method :__new, :new
        
        ##
        # Hooks into the initialization of the object to initialize the
        # mailbox. Also starts the thread executing async method calls
        def new *args
          instance = __new *args
          instance.instance_variable_set :@audience, {}
          instance.instance_variable_set :@mailbox, Queue.new
            
          audience = {}
          audience[:before] = {}
          audience[:after] = {}
          instance.instance_variable_set :@audience, audience

          Thread.new do
            loop do
              mailbox = instance.instance_variable_get :@mailbox
              method_name, args, block = mailbox.pop
              
              if audience[:before][method_name]
                audience[:before][method_name].each { |callback| callback.call }
              end

              instance.method(method_name).call *args, &block
              
              if audience[:after][method_name]
                audience[:after][method_name].each { |callback| callback.call }
              end
            end
          end

          Proxy.new instance
        end
      end
    end
  end
end
