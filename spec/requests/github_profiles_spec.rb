require 'rails_helper'

describe "GithubProfiles", type: :request do
  describe "GET /index" do
    let!(:github_profiles) { create_list(:github_profile, 3) }

    it "returns status ok" do
      get github_profiles_path
      expect(response).to have_http_status(:ok)
    end

    it "returns github profiles" do
      get github_profiles_path
      expect(response.body).to include(github_profiles.first.nick)
    end
  end

  describe "GET /show" do
    let!(:github_profile) { create(:github_profile) }

    it "returns status ok" do
      get github_profile_path(github_profile)
      expect(response).to have_http_status(:ok)
    end

    it "returns the github profile" do
      get github_profile_path(github_profile)
      expect(response.body).to include(github_profile.name)
      expect(response.body).to include(github_profile.nick)
      expect(response.body).to include(github_profile.github_url)
      expect(response.body).to include(github_profile.followers_count.to_s)
      expect(response.body).to include(github_profile.following_count.to_s)
      expect(response.body).to include(github_profile.contributions_count.to_s)
    end
  end

  describe "GET /search_profile" do
    it "returns status ok" do
      get search_profile_path
      expect(response).to have_http_status(:ok)
    end

    it "has a form to input GitHub URL" do
      get search_profile_path
      expect(response.body).to include("form")
      expect(response.body).to include("github_url")
    end
  end

  describe "POST /fetch_profile" do
    let(:fetch_params) do
      { github_url: "https://github.com/matz", name: "Yukihiro Matsumoto" }
    end

    context "When creating new profile" do
      it "creates there is no github profile" do
        VCR.use_cassette("fetch_github_profile_request_valid") do
          expect { post fetch_profile_path, params: fetch_params }.to change(GithubProfile, :count).by(1)
        end
      end

      it "redirects to the profile show page" do
        VCR.use_cassette("fetch_github_profile_request_valid") do
          post fetch_profile_path, params: fetch_params
          github_profile = GithubProfile.last
          expect(response).to redirect_to(github_profile_path(github_profile))
        end
      end
    end

    context "When there is existing profile" do
      let!(:existing_profile) { create(:github_profile, github_url: "https://github.com/matz", nick: "matz") }

      it "updates existing data" do
        VCR.use_cassette("fetch_github_profile_request_valid") do
          expect { post fetch_profile_path, params: fetch_params }.not_to change(GithubProfile, :count)
        end
      end
    end
  end
end
