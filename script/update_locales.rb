# This script update en.yml base on zh-CN.yml, run it after zh-CN.yml changed, and edit en.yml to complete translation.

source = File.open("#{Rails.root}/config/locales/zh-CN.yml")
source_yaml = YAML.load source
target = File.open("#{Rails.root}/config/locales/en.yml")
target_yaml = YAML.load target

File.open("#{Rails.root}/config/locales/en.yml", 'w') do |file|
  file.write({'en' => source_yaml['zh-CN'].deep_merge(target_yaml['en'])}.to_yaml)
end
