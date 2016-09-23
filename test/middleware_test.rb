require "test_helper"

class BustedTracerTest < Minitest::Test
  class MockLogger
    def initialize
      @info = []
    end
    def info(info)
      @info << info
    end

    def messages
      @info
    end
  end

  def test_returns_result_exactly
    app = proc {|env| [200, {'Content-Type' => 'text/plain'}, ['OK']]}
    middleware = BustedTracer.new(app)
    assert_equal [200, {'Content-Type' => 'text/plain'}, ['OK']], middleware.call({})
  end

  def test_it_logs_cache_invalidations
    log = MockLogger.new
    app = proc {|env| [200, {'Content-Type' => 'text/plain'}, ['OK']]}
    middleware = BustedTracer.new(app)
    middleware.stub :logger, log do
      middleware.call({})
    end

    assert_match(/methods=0 constants=0/, log.messages.last)
  end

  def test_it_logs_method_cache_correctly
    log = MockLogger.new
    app = proc {|env|
      Object.class_exec { def margarita; end }
      [200, {'Content-Type' => 'text/plain'}, ['OK']]
    }
    middleware = BustedTracer.new(app)
    middleware.stub :logger, log do
      middleware.call({})
    end

    assert_match(/methods=1 constants=0/, log.messages.last)
  end

  def test_it_logs_constant_cache_correctly
    log = MockLogger.new
    app = proc {|env|
      self.class.const_set :"VEGETABLE", "vegetable"
      [200, {'Content-Type' => 'text/plain'}, ['OK']]
    }
    middleware = BustedTracer.new(app)
    middleware.stub :logger, log do
      middleware.call({})
    end

    assert_match(/methods=0 constants=1/, log.messages.last)
  end
end
