module FactoryHelpers
  def fake_github_username
    name = Faker::Internet.username(specifier: 5..15, separators: ['-', ''])
    name.downcase.gsub(/[^a-z0-9\-]/, '')
  end
end
