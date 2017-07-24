require 'stripe'
require 'test/unit'
require 'mocha/setup'
require 'stringio'
require 'shoulda/context'
require 'webmock/test_unit'

PROJECT_ROOT = File.expand_path("../../", __FILE__)

require File.expand_path('../test_data', __FILE__)

LOCAL_PORT = ENV["STRIPE_LOCAL_PORT"]
if LOCAL_PORT.nil?
  abort("Please specify STRIPE_LOCAL_PORT. See README for setup instructions.")
end

# Disable all real network connections except those that are outgoing to
# stripelocal.
WebMock.disable_net_connect!(allow: "localhost:#{LOCAL_PORT}")

# Try one initial test connection to stripelocal so that if there's a problem
# we can print one error and fail fast so that it's more clear to the user how
# they should fix the problem.
begin
  Faraday.get("http://localhost:#{LOCAL_PORT}/")
rescue Faraday::ConnectionFailed
  abort("Couldn't reach stripelocal server at `localhost:#{LOCAL_PORT}`. Is " \
    "it running? Please see README for setup instructions.")
end

class Test::Unit::TestCase
  include Stripe::TestData
  include Mocha

  setup do
    Stripe.api_key = "foo"
    Stripe.api_base = "http://localhost:#{LOCAL_PORT}"
    stub_connect
  end

  teardown do
    Stripe.api_key = nil
  end

  private def stub_connect
    stub_request(:any, /^#{Stripe.connect_base}/).to_return(:body => "{}")
  end
end
