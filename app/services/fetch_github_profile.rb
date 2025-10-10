class FetchGithubProfile < ApplicationService
  GITHUB_PROFILE_URL_REGEX = /\Ahttps:\/\/github\.com\/(?!-)(?!.*--)[a-zA-Z0-9-]{1,39}(?<!-)\z/.freeze

  def initialize(args = {})
    super()
    @github_url = args[:github_url]
  end

  def call
    validate_github_url
    return if @error.present?

    fetch_and_store_profile
  end

  private

  def validate_github_url
    @error = "Github URL is require" and return if @github_url.blank?
    @error = "Invalid GitHub URL format" and return unless @github_url =~ GITHUB_PROFILE_URL_REGEX
  end

  def fetch_and_store_profile
    
  end
end