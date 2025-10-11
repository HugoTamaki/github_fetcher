require 'rails_helper'

describe FetchGithubProfile do
  subject { described_class.call(github_url: github_url) }

  describe "#call" do
    context "When blank url" do
      let(:github_url) { "" }

      it "returns error" do
        service = subject
        expect(service.success?).to be_falsey
        expect(service.data[:error]).to eq("Github URL is require")
      end
    end

    context "When invalid url" do
      invalid_urls = [
        "https://github.com/johndoe-",
        "https://github.com/-johndoe",
        "https://github.com/john_doe",
        "https://github.com/john--doe",
        "https://github.com/johndoe123456789012345678901234567890123456789"
      ]

      it "returns error" do
        invalid_urls.each do |url|
          service = described_class.call(github_url: url)
          expect(service.success?).to be_falsey
          expect(service.data[:error]).to eq("Invalid GitHub URL format")
        end
      end
    end

    context "When url is valid" do
      let(:github_url) { "https://github.com/matz" }

      it "fetches and returns profile data" do
        service = subject
        expect(service.success?).to be_truthy
        expect(service.data[:error]).to be_nil
        expect(service.data[:result]).to include(
          :name,
          :nick,
          :image_url,
          :github_url,
          :followers_count,
          :following_count,
          :contributions_count
        )
      end
    end
  end
end