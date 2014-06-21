require "testa/version"

module Testa

  # Create a test
  #
  # description - test's description string. Default is nil
  # options     - :before, :after hooks
  # block       - test code
  def test description=nil, options={}, &block
    location = caller(0)[1].split(":").tap(&:pop).join ":"
    Testa.tests << Test.new(location, description, options, &block)
  end

  # setup default before/after hooks for tests created in block
  def with options
    Testa.option_chain.push options
    yield
  ensure
    Testa.option_chain.pop
  end

  class << self
    def run
      Testa::Context.send(:include, *config[:matchers])
      reporter = config[:reporter]
      runnable.each { |t| reporter.after_each(t.call) }
      reporter.after_all(results)
      not results.any? { |r| [:error, :failed].include? r.status }
    end

    def runnable
      @_tests ||= config[:filters].inject(tests) {|ts, f| f.call ts}
    end

    def tests
      @tests ||= []
    end

    def results
      runnable.map(&:result)
    end

    def define_hook(name, &block)
      config[:hooks][name] = block
    end

    def option_chain
      @option_chain ||= []
    end

    def current_options
      option_chain.inject({}) {|ret, opt| ret.merge opt}
    end

    # Configuration
    #
    #   :matchers     - {Array of Module} module(s) containing assertion helpers
    #   :reporter     - {Object} whose class inherits ReporterBase
    #   :filters      - {Array of Callable} filter out some tests
    #   :hooks        - {Hash of Callable} Global callbacks.
    def config
      @config ||= {:matchers     => [Matcher],
                   :reporter     => Reporter.new,
                   :filters      => [],
                   :hooks        => {}}
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

    def initialize location, description, options={}, &block
      @location = location
      @description = description
      @options = Testa.current_options.merge options
      @block = block
      @result = nil
    end

    def call
      @result ||= Result.new self, *_call
    end

    def hooks(before_or_after)
      Testa.config[:hooks].values_at(*@options[before_or_after]).compact
    end

    def in_context &block
      (@context ||= Context.new).instance_eval &block
    end

    private

    def run
      hooks(:before).each { |h| in_context &h }
      in_context &@block
      hooks(:after).each { |h| in_context &h }
    end

    def _call
      unless @block
        :todo
      else
        begin
          run
        rescue Failure => e
          [:failed, e]
        rescue => e
          [:error, e]
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

    def initialize(out=nil)
      @out = out || $stdout
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
      @out.puts

      results.each {|result|
        case result.status
        when :failed, :error
          @out.puts
          @out.puts "[#{result.status.upcase}] #{result.test.location}",
            (result.test.description || "*NO DESCRIPTION*")
          @out.puts "\t#{result.exception.message}"
          @out.puts result.exception.backtrace.reject {|m| m[__FILE__] }

        when :todo
          @out.puts
          @out.puts "[#{result.status.upcase}] #{result.test.location}",
            result.test.description || "*NO DESCRIPTION*"
        end
      }

      @out.puts
      @out.puts "  PASSED: #{@stat[:passed]}"
      @out.puts "  FAILED: #{@stat[:failed]}"
      @out.puts "   ERROR: #{@stat[:error]}"
      @out.puts "    TODO: #{@stat[:todo]}"
      @out.puts "   TOTAL: #{@stat.values.inject(:+)}"
      @out.puts
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
        return unless class_or_message
        ok { e.is_a?(class_or_message) and e.message[message] } if message
        if class_or_message.is_a? Class
          ok { e.class == class_or_message }
        else
          ok { e.message[class_or_message] }
        end
      else
        fail!
      end
    end

    def fail!
      raise Failure
    end
  end

end
