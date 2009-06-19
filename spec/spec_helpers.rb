require 'rack/test'
require 'singleton'

# hack for spec
module Sinatra
  class Base
    alias :_call! :call!

    def call!(env)
      SinatraSpecHelper.instance.last_app = self
      _call!(env)
    end

    def assigned?(sym)
      instance_variables.include?("@#{sym}")
    end
  end
end

class SinatraSpecHelper
  include Singleton
  attr_accessor :last_app
end

include Rack::Test::Methods
def app
  Sinatra::Application
end
def last_app
  SinatraSpecHelper.instance.last_app
end
