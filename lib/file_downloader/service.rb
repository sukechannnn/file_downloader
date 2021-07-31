module FileDownloader
  class Service
    class NotEofError < StandardError; end

    def initialize(url, filepath)
      @url = url
      @filepath = filepath
      @retry_count = 0
    end

    def execute
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = true if uri.port == 443

      header = http.head(uri.request_uri).to_hash
      content_length = header['content-length'][0]

      file = File.open(filepath, 'wb')

      retry_on_error do
        http.get(uri.request_uri, 'range' => "bytes=#{file.size}-#{content_length}") do |bytes|
          file << bytes
        end
        raise NotEofError unless file.size == content_length.to_i
      end
      filepath
    ensure
      file&.close
    end

    private

    attr_reader :url, :filepath

    def retry_on_error(times: 10)
      @retry_count += 1
      yield
    rescue NotEofError
      if @retry_count < times
        Rails.logger.info "Connection closed: #{@retry_count} time retry"
        retry
      else
        Rails.logger.error 'Connection closed'
        raise
      end
    end
  end
end
