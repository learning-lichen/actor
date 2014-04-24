module Actor
  ##
  # Module that actors should include
  module Base
    ##
    # Adds a new message to the queue
    def send method_name, *args
      @mailbox << [method_name, args]
    end

    def self.included klass
      class << klass
        alias_method :__new, :new
        
        ##
        # Hooks into the initialization of the object to initialize the
        # mailbox. Also starts the thread executing async method calls
        def new *args
          __new(*args).tap do |instance|
            instance.instance_variable_set :@mailbox, Queue.new
            
            Thread.new do
              loop do
                mailbox = instance.instance_variable_get :@mailbox
                method_name, args = mailbox.pop
                instance.method(method_name).call(*args)
              end
            end
          end
        end
      end
    end
  end
end
