# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'livereload' do
  watch(%r{app/views/(\w+\/)*[^.].+\.(erb|haml|slim)})
  watch(%r{app/helpers/(\w+\/)*[^.].+\.rb})
  watch(%r{public/(\w+\/)*[^.].+\.(css|js|html)})
  watch(%r{config/locales/[^.].+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)/assets/\w+/([^.].+\.(scss|css|js|html)).*})  { |m| "/assets/#{m[2]}" }
  watch(%r{test/javascripts/([^.].+\.js).*})  { |m| "/assets/#{m[1]}" }
  watch(%r{test/stylesheets/([^.].+\.css).*})  { |m| "/assets/#{m[1]}" }
end
