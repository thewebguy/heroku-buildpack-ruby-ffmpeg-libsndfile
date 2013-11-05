require "custom"
require "pathname"

module Custom
  class Installer
    def initialize(package_name)
      @vendor_url        = 'https://s3-eu-west-1.amazonaws.com/trucker-buildpacks'
      @package_name      = package_name
      @package_file_name = "#{@package_name}.tar.gz"
      @build_dir         = ARGV[0]
      @vendor_dir        = "#{@build_dir}/vendor"
    end

    def go
      unless installed?
        download
        install
        makeinstall if @package_name == 'libsndfile'
        clean_up
        link
      end
    end

    def installed?
      File.directory?("#{@vendor_dir}/#{@package_name}/bin") && File.directory?("#{@vendor_dir}/#{@package_name}/lib")
    end

    def download
      topic "Downloading #{@package_name}"
      system "cd #{@vendor_dir} && curl #{@vendor_url}/#{@package_file_name} -s -O"
    end

    def install
      system "tar zxpf #{@vendor_dir}/#{@package_file_name} -C #{@vendor_dir}"
      comment "Installed #{@package_name}"
    end

    def makeinstall
      comment "Make install"
      output = system "cd #{@vendor_dir}/#{@package_file_name};"
      comment output
      output = system "cd #{@vendor_dir}/#{@package_file_name}; ./configure"
      comment output
      output = system "cd #{@vendor_dir}/#{@package_file_name}; make"
      comment output
      output = system "cd #{@vendor_dir}/#{@package_file_name}; make install"
      comment output
    end

    def clean_up
      system "rm #{@vendor_dir}/#{@package_file_name}"
    end

    def link
      comment "Linking #{@package_name} with application"
      set_env_override "PATH", "$HOME/vendor/#{@package_name}/bin:$PATH"
      set_env_override "LD_LIBRARY_PATH", "$HOME/vendor/#{@package_name}/lib:$LD_LIBRARY_PATH"
    end

  private
    
    def add_to_profiled(string)
      FileUtils.mkdir_p "#{@build_dir}/.profile.d"
      File.open("#{@build_dir}/.profile.d/ruby.sh", "a") do |file|
        file.puts string
      end
      # comment File.read("#{@build_dir}/.profile.d/ruby.sh")
    end

    def set_env_override(key, val)
      add_to_profiled %{export #{key}="#{val.gsub('"','\"')}"}
    end

    def topic(msg)
      system "echo '-----> #{msg}'"
    end

    def comment(msg)
      system "echo '       #{msg}'"
    end
  end
end
