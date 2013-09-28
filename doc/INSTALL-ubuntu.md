## Writings Installation on Ubuntu 12.04

Install Ruby 2.0 by rvm or rbenv.

### Ubuntu 12.04 Dependencies

```bash
sudo apt-get install mongodb memcached redis-server pandoc

git clone https://github.com/chloerei/writings.git
cd writings
bundle

cp config/app_config.yml.example config/app_config.yml
cp config/mongoid.yml.example config/mongoid.yml

rails s

# run in separate terminals
sidekiq # delay jobs
guard start # live-reload
```

### For Production Environment

Generate a new secret_key_base string in config/app_config.yml.

An example deploy script in config/deploy.rb (for passenger), edit it for your situation.
