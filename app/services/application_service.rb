class ApplicationService
  attr_reader :data, :errors

  def self.call(**args)
    new(**args).tap(&:call)
  end

  def initialize(**args)
    @args = args
    @data = nil
    @error = nil
  end

  def success?
    @error.blank?
  end

  def error
    @error
  end

  def call
    raise NotImplementedError, "You need to implement the call method"
  end

  private

  attr_reader :args
end