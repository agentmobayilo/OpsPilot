ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

ENV.each do |k, v|
  if v.to_s.include?("local_secret")
    ENV.delete(k)
  end
end
# require "bootsnap/setup" # Speed up boot time by caching expensive operations.


module IOIntercept
  def sysopen(path, *args, **kwargs)
    if path.to_s.include?("local_secret")
      puts "CRASHING TRACE FOR local_secret.txt:"
      puts caller
      exit(1)
    end
    super
  end
  def read(path, *args, **kwargs)
    if path.to_s.include?("local_secret")
      puts "CRASHING TRACE FOR local_secret.txt:"
      puts caller
      exit(1)
    end
    super
  end
  def open(path, *args, **kwargs)
    if path.to_s.include?("local_secret")
      puts "CRASHING TRACE FOR local_secret.txt:"
      puts caller
      exit(1)
    end
    super
  end
end
class << IO
  prepend IOIntercept
end
class << File
  prepend IOIntercept
end
