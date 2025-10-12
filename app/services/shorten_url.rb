class ShortenUrl < ApplicationService
  BITLY_API_URL = "https://api-ssl.bitly.com/v4/shorten".freeze

  def call
    @original_url = @args[:original_url]
    shorten_url
  end

  private

  def shorten_url
    return handle_failure("Original URL is required") if @original_url.blank?

    uri = URI.parse(BITLY_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['BITLY_API_TOKEN']}"
    })

    request.body = {
      long_url: @original_url
    }.to_json

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      json = JSON.parse(response.body)
      handle_success(link: json["link"])
    else
      handle_failure("Failed to shorten URL: #{response.message}")
    end
  rescue StandardError => e
    handle_failure("Failed to shorten URL: #{e.message}")
  end
end
