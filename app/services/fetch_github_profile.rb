class FetchGithubProfile < ApplicationService
  GITHUB_PROFILE_URL_REGEX = /\Ahttps:\/\/github\.com\/(?!-)(?!.*--)[a-zA-Z0-9-]{1,39}(?<!-)\z/.freeze

  def call
    @github_url = @args[:github_url]

    validate_github_url
    return handle_failure(@error) if @error.present?

    fetch_and_store_profile
  end

  private

  def validate_github_url
    @error = "Github URL is require" and return if @github_url.blank?
    @error = "Invalid GitHub URL format" and return unless @github_url =~ GITHUB_PROFILE_URL_REGEX
  end

  def fetch_and_store_profile
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    
    @driver = Selenium::WebDriver.for :chrome, options: options
    @driver.navigate.to @github_url
    
    sleep 0.5
    
    name = fetch_name
    nick = fetch_nickname
    image_url = fetch_image_url
    followers_count = fetch_followers_count
    following_count = fetch_following_count
    contributions_count = fetch_contributions_count
    image_url = @driver.find_element(css: 'img.avatar-user').attribute('src') rescue nil
    @driver.quit

    handle_success(result: {
      name: name,
      nick: nick,
      image_url: image_url,
      github_url: @github_url,
      followers_count: followers_count,
      following_count: following_count,
      contributions_count: contributions_count
    })

  rescue StandardError => e
    handle_failure("Failed to fetch GitHub profile: #{e.message}")
  end

  def fetch_name
    name_element = @driver.find_element(css: 'span.p-name')
    name_element.text.strip rescue nil
  end

  def fetch_nickname
    nickname_element = @driver.find_element(css: 'span.p-nickname')
    nickname_element.text.strip rescue nil
  end

  def fetch_image_url
    @driver.find_element(css: 'img.avatar-user').attribute('src') rescue nil
  end

  def fetch_followers_count
    followers_link = @driver.find_element(css: "a[href='#{@github_url}?tab=followers']")
    followers_text = followers_link.text.strip.split(" ").first rescue "0"
    ConvertAbreviatedToNumber.call(abreviated_number: followers_text).data[:result]
  end

  def fetch_following_count
    following_link = @driver.find_element(css: "a[href='#{@github_url}?tab=following']")
    following_text = following_link.text.strip.split(" ").first rescue "0"
    ConvertAbreviatedToNumber.call(abreviated_number: following_text).data[:result]
  end

  def fetch_contributions_count
    contributions_element = @driver.find_element(id: 'js-contribution-activity-description')
    if contributions_element
      contributions_text = contributions_element.text.strip
      contributions_text.split(" ").first.scan(/\d/).join.to_i rescue 0
    else
      0
    end
  end
end