# Load the Rails application.
require_relative "application"

begin
  if defined?(Rails::Initializable::Initializer)
    Rails::Initializable::Initializer.class_eval do
      alias_method :original_run, :run
      def run(*args)
        puts "Running initializer: #{name}"
        original_run(*args)
      end
    end
  end
  Rails.application.initialize!
rescue => e
  puts "HARD CRASH TRACE:"
  puts e.backtrace.join("\n")
  raise
end
