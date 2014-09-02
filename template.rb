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

# Select2 is a jQuery based replacement for select boxes
gem "select2-rails"

# CSV support
gem 'smarter_csv'

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
if yes("Would you like to create products and review scaffolds at this time?")
  generate(:scaffold, "product sku name description price_cents:integer active:boolean available_on:date")
  generate(:scaffold, "review product:references title body:text")
  route "root to: 'products#index'"
  rake("db:migrate")
end

# Environment files
# ==================================================
# Support of glyphicons and other assets in Heroku
replace_line('config/environments/production.rb', :match => /config.assets.compile = false/, :with => "config.assets.compile = true")

# Git: Initialize
# ==================================================
file ".gitignore", <<-END
# Ignore bin
/bin

# Ignore bundler config.
/.bundle

# Ignore the default SQLite database.
/db/*.sqlite3
/db/*.sqlite3-journal

# Ignore all logfiles and tempfiles.
/log/*.log
/tmp
END
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

# Deploy to Heroku
# ==================================================
if yes("Would you like to deploy to Heroku at this time?")
  app_name = ask("What would you like to name the Heroku app?")
  run "heroku apps:create #{app_name}"
  run "git push heroku master"
  run "heroku run rake db:migrate"
  run "heroku open"
end

# heroku apps:create app-name
# heroku git:remote -a app-name
# git push heroku master
# heroku run rake db:migrate
# heroku open