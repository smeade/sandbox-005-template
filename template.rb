# rails new sandbox-005-template -m template.rb -d postgresql

# from: https://github.com/dockyard/sail_plan/blob/master/template.rb
def replace_line(path, options = {})
  lines = File.open(path).readlines
  lines.map! do |line|
    if line.match(options[:match])
      line = "#{options[:with].rstrip}\n"
    end
    line
  end

  run "rm #{path}"
  File.open(path, 'w+') { |file| file << lines.join }
end

# Gems
# ==================================================
insert_into_file 'Gemfile', "\nruby '2.0.0'", after: "source 'https://rubygems.org'\n"

# bootstrap-generators gem provides Twitter Bootstrap generators for Rails (and includes Bootstrap)
gem 'bootstrap-generators'

gem_group :production do
  # Support for Heroku deployment
  gem 'rails_12factor'
end

# Initialize bootstrap-generators
# ==================================================
run "rails generate bootstrap:install -f"

# config.generators in support of boostrap-generators
environment <<-eos
    # config.generators in support of boostrap-generators
    config.generators do |g|
      g.orm             :active_record
      g.template_engine :erb
      g.test_framework  :test_unit, fixture: true
      g.stylesheets     false
    end
eos

# Remove Rails's scaffolds.css.scss stylesheet
# run "rm app/assets/stylesheets/scaffolds.css.scss"

# Generate a resource to have something to play with
# ==================================================
rake("db:create")
generate(:scaffold, "product sku name description price_cents:integer active:boolean available_on:date")
route "root to: 'products#index'"
rake("db:migrate")

# Environment files
# ==================================================
# Support of glyphicons and other assets in Heroku
replace_line('config/environments/production.rb', :match => /config.assets.compile = false/, :with => "config.assets.compile = true")

# Git: Initialize
# ==================================================
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

# Deploy to Heroku
# ==================================================
run "heroku apps:create"
run "git push heroku master"
run "heroku run rake db:migrate"
run "heroku open"

# heroku apps:create app-name
# heroku git:remote -a app-name
# git push heroku master
# heroku run rake db:migrate
# heroku open