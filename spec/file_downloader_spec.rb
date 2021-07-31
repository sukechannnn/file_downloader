require 'pry'

RSpec.describe FileDownloader do
  context 'ordinary' do
    let(:file_url) { 'https://example.com/file' }
    let(:download_file) { File.read('spec/fixtures/test_file.csv') }
    let(:download_filesize) { File.size('spec/fixtures/test_file.csv') }

    let!(:stub_check_filesize) do
      stub_request(:head, file_url)
        .to_return(
          status: 200,
          body: '',
          headers: { 'Content-Type' => 'text/csv', 'Content-Length' => download_filesize }
        )
    end

    let!(:stub_download_file) do
      stub_request(:get, file_url)
        .to_return(
          status: 200,
          body: download_file,
          headers: { 'Content-Type' => 'text/csv', 'Content-Length' => download_filesize }
        )
    end

    it 'can download file' do
      FileDownloader.download(url: file_url, filepath: 'tmp/downloaded_file.csv')
      expect(File.read('tmp/downloaded_file.csv')).to eq download_file
    end
  end
end
