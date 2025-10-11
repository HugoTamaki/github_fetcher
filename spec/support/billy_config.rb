require "billy/rspec"

Billy.configure do |c|
  c.cache = true
  c.persist_cache = true
  c.ignore_params = ['timestamp', 'nonce']
  c.path_blacklist = ['/assets']
end
