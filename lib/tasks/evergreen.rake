require 'evergreen'

namespace :evergreen  do
  desc "Run jasmine specs via evergreen"
  task :run => :generate_stuff do
    Kernel.exit(1) unless Evergreen::Cli.execute(["run"])
  end

  desc "Run jasmine specs server via evergreen"
  task :serve => :generate_stuff do
    Evergreen::Cli.execute(["serve"])
  end

  task :generate_stuff do
    File.open(File.join(TouraAPP::Directories.javascript, 'toura', 'app', 'TouraConfig.js'), 'w') do |f|
      f.write TouraAPP::Generators.config('ios', 'phone')
    end
  end
end
