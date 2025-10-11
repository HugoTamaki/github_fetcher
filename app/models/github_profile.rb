class GithubProfile < ApplicationRecord
  validates :name, :nick, :github_url, :followers_count, :following_count, :contributions_count, :image_url, presence: true
  validates_numericality_of :followers_count, :following_count, :contributions_count, only_integer: true, greater_than_or_equal_to: 0
  validates :nick, uniqueness: true
end
