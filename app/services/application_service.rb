class ApplicationService
  attr_reader :data

  def self.call(**args)
    new(**args).call
  end

  def initialize(**args)
    @args = args
    @data = {}
    @success = false
  end
  
  def call
    raise NotImplementedError, "You need to implement the call method"
  end

  def success?
    @success
  end

  private

  def handle_success(result = {})
    @success = true
    @data.merge!(result)
    self
  end

  def handle_failure(error = nil)
    @success = false
    @data[:error] = error
    self
  end
end