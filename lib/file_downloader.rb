require 'file_downloader/version'
require 'file_downloader/service'

module FileDownloader
  def self.download(url:, filepath:)
    Service.new(url, filepath).execute
  end
end
