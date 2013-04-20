# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'livereload' do
  watch(%r{app/views/.+\.slim$})
  watch(%r{app/helpers/.+\.rb$})
  watch(%r{public/.+\.(css|js|html)$})
  watch(%r{config/locales/.+\.yml$})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)/assets/.+\.(scss|css|js|coffee|html)$})
  watch(%r{test/javascripts/.+\.(js|coffee)$})
  watch(%r{test/stylesheets/.+\.css$})
end
