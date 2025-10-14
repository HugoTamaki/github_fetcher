class FetchGithubProfile < ApplicationService
  GITHUB_PROFILE_URL_REGEX = /\Ahttps:\/\/github\.com\/(?!-)(?!.*--)[a-zA-Z0-9-]{1,39}(?<!-)\z/.freeze

  def call
    @github_url = @args[:github_url]
    @name = @args[:name]

    validate_github_url
    return handle_failure(@error) if @error.present?

    fetch_and_store_profile
  end

  private

  def validate_github_url
    @error = "Github URL is required" and return if @github_url.blank?
    @error = "Invalid GitHub URL format" and return unless @github_url =~ GITHUB_PROFILE_URL_REGEX
  end

  def fetch_and_store_profile
    browser.goto(@github_url)
    browser.network.wait_for_idle

    name = @name || fetch_name
    nick = fetch_nickname
    image_url = fetch_image_url
    followers_count = fetch_followers_count
    following_count = fetch_following_count
    contributions_count = fetch_contributions_count

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
  ensure
    browser.quit
  end

  def fetch_name
    browser.at_css('h1.vcard-names .vcard-fullname')&.text&.strip
  end

  def fetch_nickname
    browser.at_css('h1.vcard-names .vcard-username')&.text&.strip
  end

  def fetch_image_url
    browser.at_css("img.avatar-user")[:src] rescue nil
  end

  def browser
    @browser ||= Ferrum::Browser.new(headless: true)
  end

  def fetch_followers_count
    followers_text = @browser.at_css("a[href='#{@github_url}?tab=followers'] .text-bold")&.text&.strip
    ConvertAbreviatedToNumber.call(abreviated_number: followers_text).data[:result]
  end

  def fetch_following_count
    following_text = @browser.at_css("a[href='#{@github_url}?tab=following'] .text-bold")&.text&.strip
    ConvertAbreviatedToNumber.call(abreviated_number: following_text).data[:result]
  end

  def fetch_contributions_count
    contributions_element = @browser.at_css("#js-contribution-activity-description")
    if contributions_element
      contributions_text = contributions_element.text.strip
      contributions_text.split(" ").first.scan(/\d/).join.to_i rescue 0
    else
      0
    end
  end
end
