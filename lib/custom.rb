require "pathname"
require "dotenv"
require "custom/installer"

module Custom
  def self.install_all
    ['ffmpeg', 'libsndfile1'].each do |library|
      installer = Custom::Installer.new(library)
      installer.go
    end
  end
end
