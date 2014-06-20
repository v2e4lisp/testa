require "testa/version"

module Testa

  # Then only public API for unit test
  #
  # description - test's description string. Default is nil
  # block       - test code
  def test description=nil, options={}, &block
    Testa.tests << Test.new(caller(0)[1], description, options, &block)
  end

  class << self
    def run
      Testa::Context.send(:include, *config[:matcher])
      reporter ||= config[:reporter].new

      runnable.each { |t|
        t.hooks[:before].each { |h|
          Array(config[:before][h]).each(&:call)
        }

        reporter.after_each(t.call)

        t.hooks[:after].each { |h|
          Array(config[:after][h]).each(&:call)
        }
      }

      reporter.after_all(results)
    end

    def runnable
      @_tests ||= Array(config[:filter]).inject(tests) {|ts, f| f.call ts}
    end

    def tests
      @tests ||= []
    end

    def results
      runnable.map(&:result)
    end

    # Configuration
    #
    #  :matcher  - {Array|Module} module(s) containing assertion helpers
    #  :reporter - {Class} inherit ReporterBase for message logging
    #  :filter   - {Array|Callable} filter out some tests
    #  :before   - {Array|Callable} Global callbacks. Run before each test.
    #  :after    - {Array|Callable} Global callbacks. Run after each test.
    def config
      @config ||= {:matcher  => Matcher,
                   :reporter => Reporter,
                   :filter   => lambda {|tests| tests},
                   :before   => {},
                   :after    => {}}
    end
  end

  class Failure < StandardError; end
  class Context < Object; end
  class Result < Struct.new(:test, :status, :exception); end
  class ReporterBase
    def after_each(result); end
    def after_all(results); end
  end

  class Test
    attr_accessor :description, :result, :location, :options

    def initialize location, description, option={}, &block
      @description = description
      @options = options
      @options[:before] = Array(*@options[:before]) if @options[:before]
      @options[:after] = Array(*@options[:after]) if @options[:after]
      @block = block
      @result = nil
      @location = location
    end

    def call
      @result ||= _call
    end

    def hooks
      options
    end

    private

    def _call
      unless @block
        :todo
      else
        begin
          Testa::Context.new.instance_eval &@block
        rescue Testa::Failure => e
          :failed, e
        rescue => e
          :error, e
        else
          :passed
        end
      end
    end
  end

  class Reporter < ReporterBase
    CHARS = {:passed => ".",
             :failed => "F",
             :error  => "E",
             :todo   => "*"}

    def initialize
      @stat = {:passed => 0,
               :failed => 0,
               :error  => 0,
               :todo   => 0}
    end

    def after_each(result)
      return unless result
      @stat[result.status] += 1
      print CHARS[result.status]
    end

    def after_all(results)
      puts

      results.each {|result|
        if [:failed, :error].include? result.status
          puts
          puts result.test.description || "*NO DESCRIPTION*"
          puts "\t#{result.exception.message}"
          puts "\t#{result.test.location}"
          puts result.exception.backtrace
        end
      }

      puts
      puts "  PASSED: #{@stat[:passed]}"
      puts "  FAILED: #{@stat[:failed]}"
      puts "   ERROR: #{@stat[:todo]}"
      puts "    TODO: #{@stat[:todo]}"
      puts "   TOTAL: #{@stat.values.inject(:+)}"
      puts
    end
  end

  # Assertion methods
  #
  # Assertion method should raise Testa::Failure if assertion failed
  module Matcher
    def ok
      yield or fail!
    end

    def error(class_or_message=nil, message=nil)
      begin
        yield
      rescue => e
        return ok { e.is_a?(class_or_message) and e.message[message] } if message
        if class_or_message.is_a? Class
          ok { e.is_a? class_or_message }
        else
          ok { e.message[message] }
        end
      else
        fail!
      end
    end

    def fail!
      raise Testa::Failure
    end
  end

end
