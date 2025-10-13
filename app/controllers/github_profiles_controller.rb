class GithubProfilesController < ApplicationController
  def index
    @github_profiles = GithubProfile.all
  end

  def show
    @github_profile = GithubProfile.find(params[:id])
  end

  def edit
    @github_profile = GithubProfile.find(params[:id])
  end

  def update
    @github_profile = GithubProfile.find(params[:id])

    @github_profile.assign_attributes(github_profile_params)

    if @github_profile.github_url_changed?
      fetch_profile_service = FetchGithubProfile.call(
        github_url: github_profile_params[:github_url],
        name: github_profile_params[:name]
      )

      unless fetch_profile_service.success?
        flash.now[:alert] = fetch_profile_service.data[:error]
        return render :edit, status: :unprocessable_entity
      end

      @github_profile.assign_attributes(fetch_profile_service.data[:result])

      generate_short_url
    end

    if @github_profile.save
      redirect_to github_profile_path(@github_profile), notice: "GitHub profile updated successfully."
    else
      flash.now[:alert] = @github_profile.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @github_profile = GithubProfile.find(params[:id])

    if @github_profile.destroy
      redirect_to root_path, notice: "GitHub profile deleted successfully."
    else
      redirect_to github_profile_path(@github_profile), alert: "Failed to delete GitHub profile."
    end
  end

  def search_profile
  end

  def fetch_profile
    fetch_profile_service = FetchGithubProfile.call(github_url: params[:github_url], name: params[:name])

    @github_profile = GithubProfile.find_by(id: params[:id]) if params[:id].present?

    unless fetch_profile_service.success?
      flash.now[:alert] = fetch_profile_service.data[:error]
      return render page_by_request_referer, status: :unprocessable_entity
    end

    @github_profile ||= GithubProfile.find_or_initialize_by(nick: fetch_profile_service.data[:result][:nick])
    @github_profile.assign_attributes(fetch_profile_service.data[:result])

    generate_short_url if @github_profile.shortened_github_url.blank?

    if @github_profile.save
      redirect_to github_profile_path(@github_profile), notice: "GitHub profile fetched successfully."
    else
      flash.now[:alert] = @github_profile.errors.full_messages.to_sentence
      render page_by_request_referer, status: :unprocessable_entity
    end
  end

  private

  def generate_short_url
    shorten_url_service = ShortenUrl.call(original_url: params[:github_url])
    @github_profile.shortened_github_url = shorten_url_service.data[:link]
  end

  def github_profile_params
    params.require(:github_profile).permit(:name, :github_url)
  end

  def page_by_request_referer
    if request.referer&.include?("search_profile")
      :search_profile
    else
      :show
    end
  end
end
