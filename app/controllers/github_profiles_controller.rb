class GithubProfilesController < ApplicationController
  def index
    @github_profiles = GithubProfile.all
  end

  def show
    @github_profile = GithubProfile.find(params[:id])
  end

  def search_profile
    
  end
  
  def fetch_profile
    result = FetchGithubProfile.call(github_url: params[:github_url])

    @github_profile = GithubProfile.find_or_initialize_by(nick: result.data[:result][:nick])
    @github_profile.assign_attributes(result.data[:result])

    unless result.success?
      flash.now[:alert] = result.data[:error]
      return render page_by_request_referrer, status: :unprocessable_entity
    end

    if @github_profile.save
      redirect_to github_profile_path(@github_profile), notice: "GitHub profile fetched successfully."
    else
      flash.now[:alert] = @github_profile.errors.full_messages.to_sentence
      return render page_by_request_referrer, status: :unprocessable_entity
    end
  end

  private

  def page_by_request_referrer
    if request.referer&.include?("search_profile")
      :search_profile
    else
      :show
    end
  end
end
