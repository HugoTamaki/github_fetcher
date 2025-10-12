require 'rails_helper'

describe ShortenUrl do
  subject { described_class.call(original_url: original_url) }

  describe "#call" do
    context "When blank url" do
      let(:original_url) { "" }

      it "returns error" do
        service = subject
        expect(service.success?).to be_falsey
        expect(service.data[:error]).to eq("Original URL is required")
      end
    end

    context "When url is valid" do
      let(:original_url) { "https://github.com/matz" }

      it "shortens the url" do
        VCR.use_cassette("shorten_url_success") do
          service = subject
          expect(service.success?).to be_truthy
          expect(service.data[:error]).to be_nil
          expect(service.data[:link]).to eql("https://bit.ly/4oidcPs")
        end
      end
    end
  end
end
