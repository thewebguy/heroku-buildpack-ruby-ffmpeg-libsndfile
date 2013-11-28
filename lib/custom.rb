require "pathname"
require "dotenv"
require "custom/installer"

module Custom
  def self.install_all
    ['libsndfile-1.0.25', 'ffmpeg'].each do |library|
      installer = Custom::Installer.new(library)
      installer.go
    end
  end
end
