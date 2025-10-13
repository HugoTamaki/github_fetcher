require 'rails_helper'

describe "GithubProfiles", type: :request do
  before do
    allow(ShortenUrl).to receive(:call).and_return(
      double(success?: true, data: { link: "https://bit.ly/fake" })
    )
  end

  describe "GET /index" do
    let!(:github_profiles) { create_list(:github_profile, 3) }

    it "returns status ok" do
      get github_profiles_path
      expect(response).to have_http_status(:ok)
    end

    it "returns github profiles" do
      get github_profiles_path
      expect(response.body).to include(github_profiles.first.name)
    end

    context "When searching" do
      it "returns profiles matching the name" do
        get github_profiles_path, params: { query: github_profiles.first.name }
        expect(response.body).to include(github_profiles.first.name)
        expect(response.body).not_to include(github_profiles.second.name)
      end

      it "returns profiles matching the nick" do
        get github_profiles_path, params: { query: github_profiles.first.nick }
        expect(response.body).to include(github_profiles.first.name)
        expect(response.body).not_to include(github_profiles.second.name)
      end

      it "returns profiles matching the github_url" do
        get github_profiles_path, params: { query: github_profiles.first.github_url }
        expect(response.body).to include(github_profiles.first.name)
        expect(response.body).not_to include(github_profiles.second.name)
      end

      it "returns no profiles if query does not match" do
        get github_profiles_path, params: { query: "nonexistent" }
        github_profiles.each do |profile|
          expect(response.body).not_to include(profile.name)
        end
      end
    end
  end

  describe "GET /edit" do
    let!(:github_profile) { create(:github_profile) }

    it "returns the edit page with the profile's data" do
      github_profile = create(:github_profile)
      get edit_github_profile_path(github_profile)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(github_profile.name)
      expect(response.body).to include(github_profile.github_url)
    end
  end

  describe "GET /show" do
    let!(:github_profile) { create(:github_profile, shortened_github_url: "https://bit.ly/fake") }

    it "returns status ok" do
      get github_profile_path(github_profile)
      expect(response).to have_http_status(:ok)
    end

    it "returns the github profile" do
      get github_profile_path(github_profile)
      expect(response.body).to include(github_profile.name)
      expect(response.body).to include(github_profile.nick)
      expect(response.body).to include(github_profile.shortened_github_url)
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
        expect { post fetch_profile_path, params: fetch_params }.to change(GithubProfile, :count).by(1)
      end

      it "redirects to the profile show page" do
        post fetch_profile_path, params: fetch_params
        github_profile = GithubProfile.last
        expect(response).to redirect_to(github_profile_path(github_profile))
      end
    end

    context "When there is existing profile" do
      let!(:existing_profile) { create(:github_profile, github_url: "https://github.com/matz", nick: "matz") }

      it "updates existing data" do
        expect { post fetch_profile_path, params: fetch_params }.not_to change(GithubProfile, :count)
      end
    end

    context "When FetchGithubProfile fails" do
      let(:fetch_params) do
        { github_url: "https://github.com/john_doe", name: "Lero" }
      end

      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:referer).and_return("/search_profile")
      end

      it "does not create profile" do
        post fetch_profile_path, params: fetch_params
        expect { post fetch_profile_path, params: fetch_params }.not_to change(GithubProfile, :count)
      end

      it "returns error" do
        post fetch_profile_path, params: fetch_params
        expect(response.body).to include("Invalid GitHub URL format")
      end
    end

    context "When fails to save profile" do
      let(:fetch_params) do
        { github_url: "https://github.com/matz", name: "Lero" }
      end

      before do
        allow_any_instance_of(GithubProfile).to receive(:save).and_return(false)
        allow_any_instance_of(GithubProfile).to receive(:errors).and_return(double(full_messages: ["Save failed"]))
        allow_any_instance_of(ActionDispatch::Request).to receive(:referer).and_return("/search_profile")
      end

      it "does not save the profile and returns error when save fails" do
        post fetch_profile_path, params: fetch_params
        expect(response.status).to eq(422)
        expect(response.body).to include("Save failed")
      end
    end
  end

  describe "POST /update" do
    let!(:github_profile) { create(:github_profile) }
    let(:update_params) do
       { github_profile: { name: "New Name", github_url: "https://github.com/matz" } }
    end

    it "updates the github profile" do
      patch github_profile_path(github_profile), params: update_params
      expect(github_profile.reload.name).to eql("New Name")
    end

    it "Rescan data" do
      patch github_profile_path(github_profile), params: update_params
      expect(github_profile.reload.nick).to eql("matz")
      expect(github_profile.reload.shortened_github_url).to eql("https://bit.ly/fake")
    end

    context "When FetchGithubProfile fails" do
      let(:update_params) do
        { github_profile: { name: "New Name", github_url: "https://github.com/john--doe" } }
      end

      it "does not update data" do
        patch github_profile_path(github_profile), params: update_params
        expect(response.status).to be(422)
      end

      it "returns error message" do
        patch github_profile_path(github_profile), params: update_params
        expect(response.body).to include("Invalid GitHub URL format")
      end
    end

    context "When fails to save profile" do
      let(:fetch_params) do
        { github_url: "https://github.com/matz", name: "Lero" }
      end

      before do
        allow_any_instance_of(GithubProfile).to receive(:save).and_return(false)
        allow_any_instance_of(GithubProfile).to receive(:errors).and_return(double(full_messages: ["Save failed"]))
      end

      it "does not save the profile and returns error when save fails" do
        post fetch_profile_path, params: fetch_params
        expect(response.status).to eq(422)
        expect(response.body).to include("Save failed")
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:github_profile) { create(:github_profile) }

    it "deletes the github profile" do
      expect { delete github_profile_path(github_profile) }.to change(GithubProfile, :count).by(-1)
    end

    it "redirects to the root path" do
      delete github_profile_path(github_profile)
      expect(response).to redirect_to(root_path)
    end
  end
end
