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
    fetch_profile_service = FetchGithubProfile.call(github_url: params[:github_url], name: params[:name])

    @github_profile = GithubProfile.find_by(id: params[:id]) if params[:id].present?

    unless fetch_profile_service.success?
      flash.now[:alert] = fetch_profile_service.data[:error]
      return render page_by_request_referrer, status: :unprocessable_entity
    end

    @github_profile ||= GithubProfile.find_or_initialize_by(nick: fetch_profile_service.data[:result][:nick])
    @github_profile.assign_attributes(fetch_profile_service.data[:result])

    if @github_profile.shortened_github_url.blank?
      shorten_url_service = ShortenUrl.call(original_url: params[:github_url])
      @github_profile.shortened_github_url = shorten_url_service.data[:link]
    end

    if @github_profile.save
      redirect_to github_profile_path(@github_profile), notice: "GitHub profile fetched successfully."
    else
      flash.now[:alert] = @github_profile.errors.full_messages.to_sentence
      render page_by_request_referrer, status: :unprocessable_entity
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
