require 'rubygems'
require 'hashie/mash'
require 'json'

module Buildbox
  class Configuration < Hashie::Mash
    def worker_access_tokens
      env_workers = ENV['BUILDBOX_WORKERS']

      if env_workers.nil?
        self[:worker_access_tokens] || []
      else
        env_workers.to_s.split(",")
      end
    end

    def api_endpoint
      ENV['BUILDBOX_API_ENDPOINT'] || self[:api_endpoint] || "https://api.buildbox.io/v1"
    end

    def update(attributes)
      attributes.each_pair { |key, value| self[key] = value }
      save
    end

    def save
      File.open(path, 'w+') { |file| file.write(pretty_json) }
    end

    def reload
      if path.exist?
        read_and_load
      else
        save && read_and_load
      end
    end

    private

    def pretty_json
      JSON.pretty_generate(self)
    end

    def read_and_load
      merge! JSON.parse(path.read)
    end

    def path
      Buildbox.root_path.join("configuration.json")
    end
  end
end
