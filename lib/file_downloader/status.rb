class NotFoundError < StandardError; end

module Status
  module_function

  def check(code)
    raise NotFoundError if code == '404'
  end
end
