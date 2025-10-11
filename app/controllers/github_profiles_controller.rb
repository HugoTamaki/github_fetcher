class GithubProfilesController < ApplicationController
  def index
    @github_profiles = GithubProfile.all
  end

  def search_profile
    
  end
  
  def fetch_profile
    result = FetchGithubProfile.call(github_url: params[:github_url])

    unless result.success?
      flash.now[:alert] = result.data[:error]
      return render :search_profile, status: :unprocessable_entity
    end

    github_profile = GithubProfile.new(result.data[:result])

    if github_profile.save
      redirect_to github_profiles_path, notice: "GitHub profile fetched successfully."
    else
      flash.now[:alert] = github_profile.errors.full_messages.to_sentence
      return render :search_profile, status: :unprocessable_entity
    end
  end
end
