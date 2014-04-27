module Actor
  ##
  # The proxy class wraps an object and invokes all of its method using :send
  class Proxy < BasicObject
    ##
    # Create a new proxy
    #
    # * *Args*:
    #   - +proxy_target+: the instance to proxy
    def initialize proxy_target
      @proxy_target = proxy_target
    end
    
    ##
    # Proxies the method call to the proxy target using :send
    def method_missing name, *args, &block
      @proxy_target.send name, *args, &block
    end
    
    ##
    # Get the proxy target of this proxy
    #
    # * *Returns*: the proxy target
    def __proxy_target
      @proxy_target
    end

    ##
    # Override
    def == other
      @proxy_target == other
    end

    ##
    # Override
    def != other
      @proxy_target != other
    end

    ##
    # Override
    def equal? other
      @proxy_target.equal? other
    end
  end
end
