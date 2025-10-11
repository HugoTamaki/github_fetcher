FactoryBot.define do
  factory :github_profile do
    name { "MyString" }
    nick { Faker::Name.unique.name }
    github_url { "MyString" }
    followers_count { 1 }
    following_count { 1 }
    stars_count { 1 }
    contributions_count { 1 }
    image_url { "MyString" }
    org { "MyString" }
    location { "MyString" }
  end
end
