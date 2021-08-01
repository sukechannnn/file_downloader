# FileDownloader

Complete downloading huge file even if connection interrupted few times.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'file_downloader'
```

And then execute:

```
$ bundle install
```

## Usage

Specify access url and filepath to download, like below.

```ruby
FileDownloader.download(url: file_url, filepath: 'path/to/downloaded_file.csv')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies & run rspec.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.
You can also run `bundle exec rspec` to test with RSpec.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sukechannnn/file_downloader. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FileDownloader project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/file_downloader/blob/master/CODE_OF_CONDUCT.md).
