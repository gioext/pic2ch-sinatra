require 'memcache'
#require 'rubygems'
#require 'sinatra/base'

class MemCache
  def all_keys
    raise MemCacheError, "No active servers" unless active?
    keys = []

    @servers.each do |server|
      sock = server.socket
      raise MemCacheError, "No connection to server" if sock.nil?

      begin
        sock.write "stats items\r\n"
        slabs = {}
        while line = sock.gets
          break if line == "END\r\n"
          slabs[$1] = $2 if line =~ /^STAT items:(\d+):number (\d+)/ 
        end

        slabs.each do |k, v|
          sock.write "stats cachedump #{k} #{v}\r\n"
          while line = sock.gets
            break if line == "END\r\n"
            keys << $1 if line =~ /^ITEM ([^\s]+)/
          end
        end
      rescue SocketError, SystemCallError, IOError => err
        server.close
        raise MemCacheError, err.message
      end
    end

    keys
  end
end

module Sinatra
  module MemCache
    module Helpers

      #
      #
      #
      def cache(key, opt = {}, &block)
        return block.call unless options.cache_enable

        opt = { :expiry => options.cache_expiry,
                :raw => options.cache_raw }.merge(opt)

        client = options.cache_client
        value = client[key, opt[:raw]]
        unless value
          value = block.call
          client.set(key, value, opt[:expiry], opt[:raw])
          log "cache: #{key}"
        end
        value
      rescue => e
        throw e if development?
        block.call
      end

      #
      #
      #
      def expire(p)
        return unless options.cache_enable

        case p
        when String
          expire_key(p)
        when Regexp
          expire_regexp(p)
        end
        true
      rescue => e
        throw e if development?
        false
      end


      private

      #
      #
      #
      def log(msg)
        puts "[sinatra-memcache] #{msg}" if options.cache_logging
      end

      #
      #
      #
      def expire_key(key)
        options.cache_client.delete(key)
        log "expire: #{key}"
      end

      #
      #
      #
      def expire_regexp(re)
        keys = options.cache_client.all_keys
        keys.each do |key|
          expire(key) if key =~ re
        end
      end
    end

    #
    #
    #
    def self.registered(app)
      app.helpers MemCache::Helpers

      app.set :cache_client, ::MemCache.new('localhost:11211') 
      app.set :cache_enable, true
      app.set :cache_expiry, 3600
      app.set :cache_raw, true
      app.set :cache_logging, true
    end
  end
  
  register MemCache

end
