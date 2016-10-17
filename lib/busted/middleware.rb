require "logger"

module Busted
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Busted.start
      request = @app.call(env)
      report = Busted.finish

      logger.info "[Cache Invalidations] methods=#{report[:invalidations][:method]} constants=#{report[:invalidations][:constant]}"
      request
    end

    private

    def logger
      if defined?(Rails)
        Rails.logger
      else
        Logger.new(STDOUT)
      end
    end
  end
end
