module Innate

  # In order to reset the body contents we also need to reset the length set by
  # Response#write - until I can submit a patch to Rack and the next release we
  # just do this.

  class Response < Rack::Response
    attr_accessor :length
  end
end