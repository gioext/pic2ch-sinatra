require File.dirname(__FILE__) + '/../pic2ch-sinatra'
require File.dirname(__FILE__) + '/spec_helpers'

describe 'GET /' do
  it 'should be response ok' do
    get '/'
    last_response.ok?.should be_true
  end
end
