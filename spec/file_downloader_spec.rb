require 'pry'

RSpec.describe FileDownloader do
  subject { FileDownloader.download(url: file_url, filepath: 'tmp/downloaded_file.csv') }

  let(:file_url) { 'https://example.com/file' }
  let(:download_file) { File.read('spec/fixtures/test_file.csv') }
  let(:download_filesize) { File.size('spec/fixtures/test_file.csv') }

  context 'ordinary' do
    context 'when complete download with once request' do
      let!(:stub_check_filesize) do
        stub_request(:head, file_url)
        .to_return(
          status: 200,
          body: '',
          headers: { 'Content-Type' => 'text/csv', 'Content-Length' => download_filesize },
        )
      end

      let!(:stub_download_file) do
        stub_request(:get, file_url)
        .to_return(
          status: 200,
          body: download_file,
          headers: { 'Content-Type' => 'text/csv', 'Content-Length' => download_filesize },
        )
      end

      it 'can download file' do
        subject
        expect(File.read('tmp/downloaded_file.csv')).to eq download_file
      end
    end

    context 'when connection interrupted once when downloading' do
      let(:fragment1) { File.read('spec/fixtures/test_file_fragment1.csv') }
      let(:fragment2) { File.read('spec/fixtures/test_file_fragment2.csv') }

      let!(:stub_check_filesize) do
        stub_request(:head, file_url)
        .to_return(
          status: 200,
          body: '',
          headers: { 'Content-Type' => 'text/csv', 'Content-Length' => download_filesize },
        )
      end

      let!(:stub_download_file) do
        stub_request(:get, file_url)
        .to_return(
          status: 200,
          body: fragment1,
          headers: { 'Content-Type' => 'text/csv', 'Content-Length' => download_filesize },
        ).to_return(
          status: 200,
          body: fragment2,
          headers: { 'Content-Type' => 'text/csv', 'Content-Length' => download_filesize },
        )
      end

      it 'can download file' do
        subject
        expect(File.read('tmp/downloaded_file.csv')).to eq download_file
      end
    end

    context 'when connection interrupted and it does not return' do
      let(:fragment1) { File.read('spec/fixtures/test_file_fragment1.csv') }

      let!(:stub_check_filesize) do
        stub_request(:head, file_url)
        .to_return(
          status: 200,
          body: '',
          headers: { 'Content-Type' => 'text/csv', 'Content-Length' => download_filesize },
        )
      end

      let!(:stub_download_file) do
        stub_request(:get, file_url)
        .to_return(
          status: 200,
          body: fragment1,
          headers: { 'Content-Type' => 'text/csv', 'Content-Length' => download_filesize },
        )
      end

      it 'raises FileDownloader::NotEofError' do
        expect { subject }.to raise_error(FileDownloader::NotEofError)
      end
    end
  end

  context '404' do
    context 'when `head` access returns 404' do
      let!(:stub_check_filesize) do
        stub_request(:head, file_url)
        .to_return(
          status: 404,
          body: '',
          headers: { 'Content-Type' => 'text/csv', 'Content-Length' => download_filesize },
        )
      end

      it 'raises NotFoundError' do
        expect { subject }.to raise_error(NotFoundError)
      end
    end

    context 'when `get` access returns 404' do
      let!(:stub_check_filesize) do
        stub_request(:head, file_url)
          .to_return(
            status: 200,
            body: '',
            headers: { 'Content-Type' => 'text/csv', 'Content-Length' => download_filesize },
          )
      end

      let!(:stub_download_file) do
        stub_request(:get, file_url)
          .to_return(
            status: 404,
            body: 'NotFound',
            headers: { 'Content-Type' => 'text/csv', 'Content-Length' => download_filesize },
          )
      end

      it 'raises NotFoundError' do
        expect { subject }.to raise_error(NotFoundError)
      end
    end
  end
end
