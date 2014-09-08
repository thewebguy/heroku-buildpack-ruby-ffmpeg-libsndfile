require "shellwords"

class NoShellEscape < String
  def shellescape
    self
  end
end

module LanguagePack
  module ShellHelpers
    @@user_env_hash = {}

    def self.user_env_hash
      @warnings
    end

    def user_env_hash
      @@user_env_hash
    end

    def env(var)
      ENV[var] || user_env_hash[var]
    end

    def self.blacklist?(key)
      %w(PATH GEM_PATH GEM_HOME GIT_DIR).include?(key)
    end

    def self.initialize_env(path)
      env_dir = Pathname.new("#{path}")
      if env_dir.exist? && env_dir.directory?
        env_dir.each_child do |file|
          key   = file.basename.to_s
          value = file.read.strip
          user_env_hash[key] = value unless blacklist?(key)
        end
      end
    end
    
    # display error message and stop the build process
    # @param [String] error message
    def error(message)
      Kernel.puts " !"
      message.split("\n").each do |line|
        Kernel.puts " !     #{line.strip}"
      end
      Kernel.puts " !"
      log "exit", :error => message
      exit 1
    end

    # run a shell comannd and pipe stderr to stdout
    # @param [String] command to be run
    # @return [String] output of stdout and stderr
    def run(command)
      %x{ #{command} 2>&1 }
    end

    # run a shell command and pipe stderr to /dev/null
    # @param [String] command to be run
    # @return [String] output of stdout
    def run_stdout(command)
      %x{ #{command} 2>/dev/null }
    end

    # run a shell command and stream the output
    # @param [String] command to be run
    def pipe(command)
      output = ""
      IO.popen(command) do |io|
        until io.eof?
          buffer = io.gets
          output << buffer
          puts buffer
        end
      end

      output
    end

    # display a topic message
    # (denoted by ----->)
    # @param [String] topic message to be displayed
    def topic(message)
      Kernel.puts "-----> #{message}"
      $stdout.flush
    end

    # display a message in line
    # (indented by 6 spaces)
    # @param [String] message to be displayed
    def puts(message)
      message.split("\n").each do |line|
        super "       #{line.strip}"
      end
      $stdout.flush
    end

    def warn(message)
      @warnings ||= []
      @warnings << message
    end

    def deprecate(message)
      @deprecations ||= []
      @deprecations << message
    end
  end
end
