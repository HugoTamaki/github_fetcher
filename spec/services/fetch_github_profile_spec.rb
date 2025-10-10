require 'rails_helper'

describe FetchGithubProfile do
  describe "#call" do
    context "When blank url" do
      it "returns error" do
        service = described_class.call(github_url: "")
        expect(service.success?).to be_falsey
        expect(service.error).to eq("Github URL is require")
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
          expect(service.error).to eq("Invalid GitHub URL format")
        end
      end

      it "returns success for valid url" do
        service = described_class.call(github_url: "https://github.com/HugoTamaki")
        expect(service.success?).to be_truthy
        expect(service.error).to be_nil
      end
    end
  end
end