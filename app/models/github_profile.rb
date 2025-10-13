class GithubProfile < ApplicationRecord
  validates :name, :nick, :github_url, :followers_count, :following_count, :contributions_count, :image_url, presence: true
  validates_numericality_of :followers_count, :following_count, :contributions_count, only_integer: true, greater_than_or_equal_to: 0
  validates :nick, uniqueness: true

  scope :search_by_name_nick_or_github_url, ->(query) {
    where(
      "LOWER(name) LIKE :q OR LOWER(nick) LIKE :q OR LOWER(github_url) LIKE :q",
      q: "%#{query.downcase}%"
    )
  }
end
