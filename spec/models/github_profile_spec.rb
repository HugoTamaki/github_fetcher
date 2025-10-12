require 'rails_helper'

describe GithubProfile, type: :model do
  describe "validations" do
    it "validates fields" do
      profile = GithubProfile.new
      expect(profile.valid?).to be_falsey
      expect(profile.errors[:name]).to include("can't be blank")
      expect(profile.errors[:github_url]).to include("can't be blank")
      expect(profile.errors[:followers_count]).to include("can't be blank")
      expect(profile.errors[:following_count]).to include("can't be blank")
      expect(profile.errors[:contributions_count]).to include("can't be blank")
    end

    it "validates numericality" do
      profile = GithubProfile.new(followers_count: "a", following_count: "a", stars_count: "a", contributions_count: "a")
      expect(profile.valid?).to be_falsey
      expect(profile.errors[:followers_count]).to include("is not a number")
      expect(profile.errors[:following_count]).to include("is not a number")
      expect(profile.errors[:contributions_count]).to include("is not a number")
    end

    it "saves valid data" do
      profile = create(:github_profile)
      expect(profile.valid?).to be_truthy
    end
  end
end
