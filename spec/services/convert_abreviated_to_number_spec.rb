require 'rails_helper'

describe ConvertAbreviatedToNumber do
  subject { described_class.call(abreviated_number: abreviated_number) }

  describe "#call" do
    context "When number is not abreviated" do
      let(:abreviated_number) { "1234" }

      it "returns the number as is" do
        service = subject
        expect(service.success?).to be_truthy
        expect(service.data[:result]).to eq("1234")
      end
    end

    context "When number is abreviated with 'k'" do
      let(:abreviated_number) { "1.2k" }

      it "converts and returns the full number" do
        service = subject
        expect(service.success?).to be_truthy
        expect(service.data[:result]).to eq(1_200)
      end
    end

    context "When number is abreviated with 'K'" do
      let(:abreviated_number) { "1.2m" }

      it "converts and returns the full number" do
        service = subject
        expect(service.success?).to be_truthy
        expect(service.data[:result]).to eq(1_200_000)
      end
    end

    context "When number is abreviated with 'b'" do
      let(:abreviated_number) { "1.2b" }

      it "converts and returns the full number" do
        service = subject
        expect(service.success?).to be_truthy
        expect(service.data[:result]).to eq(1_200_000_000)
      end
    end
  end
end
