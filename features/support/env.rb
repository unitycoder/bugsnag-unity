require 'fileutils'

$api_key = 'a35a2a72bd230ac0aa0f52715bbdc6aa'

Before('@skip_webgl') do |_scenario|
  skip_this_scenario("Skipping scenario") unless Maze.config.browser.nil?
end

Before('@webgl_only') do |_scenario|
  skip_this_scenario("Skipping scenario") if Maze.config.browser.nil?
end

Before('@macos_only') do |_scenario|
  skip_this_scenario("Skipping scenario") unless Maze.config.os == 'macos'
end

AfterConfiguration do |_config|
  Maze.config.enforce_bugsnag_integrity = false

  if Maze.config.os&.downcase == 'macos'
    # The default macOS Crash Reporter "#{app_name} quit unexpectedly" alert grabs focus which can cause tests to flake.
    # This option, which appears to have been introduced in macOS 10.11, displays a notification instead of the alert.
    Maze::Runner.run_command('defaults write com.apple.CrashReporter UseUNC 1')
  elsif Maze.config.os&.downcase == 'windows'
    # Allow the necessary environment variables to be passed from Ubuntu (under WSL) to the Windows test fixture
    ENV['WSLENV'] = 'BUGSNAG_SCENARIO:BUGSNAG_APIKEY:MAZE_ENDPOINT'
  elsif Maze.config.browser != nil # WebGL
    Maze.config.document_server_root = 'features/fixtures/maze_runner/build/WebGL/Mazerunner'
  elsif Maze.config.device.nil?
    raise '--browser (WebGL), --device (for Android/iOS) or --os (for desktop) option must be set'
  end
end

Maze.hooks.before do
  if Maze.config.os == 'macos'
    support_dir = File.expand_path '~/Library/Application Support/com.bugsnag.Bugsnag'
    $logger.info "Clearing #{support_dir}"
    FileUtils.rm_rf(support_dir)
  end
end

at_exit do
  if Maze.config.os == 'macos'
    app_name = Maze.config.app.gsub /\.app$/, ''
    Maze::Runner.run_command("log show --predicate '(process == \"#{app_name}\")' --style syslog --start '#{Maze.start_time}' > #{app_name}.log")
  end
end
