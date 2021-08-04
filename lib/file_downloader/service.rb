require 'file_downloader/status'
require 'net/http'
require 'logger'

module FileDownloader
  class NoResponseBodyError < StandardError; end
  class NotEofError < StandardError; end

  class Service
    def initialize(url, filepath, logger: nil)
      @url = url
      @filepath = filepath
      @retry_count = 0
      @logger = logger || Logger.new($stdout)
    end

    def execute
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)

      content_length = fetch_content_length(http, uri)
      raise NoResponseBodyError if content_length.to_i.zero?
      download_file(http, uri, content_length)
      filepath
    end

    private

    attr_reader :url, :filepath, :logger

    def fetch_content_length(http, uri)
      http.use_ssl = true if uri.port == 443

      res = http.head(uri.request_uri)
      Status.check(res.code)
      header = res.to_hash
      header['content-length'][0]
    end

    def download_file(http, uri, content_length)
      file = File.open(filepath, 'wb')

      retry_on_error do
        res = http.get(uri.request_uri, 'range' => "bytes=#{file.size}-#{content_length}") do |bytes|
          file << bytes
        end
        Status.check(res.code)
        raise NotEofError unless file.size == content_length.to_i
      end
    ensure
      file&.close
    end

    def retry_on_error(times: 10)
      @retry_count += 1
      yield
    rescue NotEofError
      if @retry_count < times
        logger.info "Connection closed: #{@retry_count} time retry"
        retry
      else
        logger.error 'Connection closed'
        raise
      end
    end
  end
end
