require 'memcache'
#require 'rubygems'
#require 'sinatra/base'

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
          keys = client['cache:keys'] || []
          keys << key
          client.set('cache:keys', keys);
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
      def expire(key)
        return unless options.cache_enable

        options.cache_client.delete(key)
        log "expire: #{key}"
        true
      rescue
        false
      end

      def expire_all
        return unless options.cache_enable

        keys = options.cache_client['cache:keys'] || []
        keys.each do |key|
          expire(key)
        end
        expire('cache:keys')
      rescue
      end

      private
      def log(msg)
        puts "[sinatra-memcache] #{msg}" if options.cache_logging
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
