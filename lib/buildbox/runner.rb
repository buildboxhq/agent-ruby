require 'celluloid'
require 'fileutils'

module Buildbox
  class Runner
    include Celluloid
    include Celluloid::Logger

    def initialize(build)
      @build = build
    end

    def start
      info "Starting to build #{@build.namespace}/#{@build.id} starting..."

      FileUtils.mkdir_p(directory_path)
      File.open(script_path, 'w+') { |file| file.write(@build.script) }
      File.chmod(0777, script_path)

      command = Command.new(script_path, :environment => @build.env, :directory => directory_path)

      @build.output     = ""
      @build.process    = command.process
      @build.started_at = Time.now.utc

      command.start { |chunk| @build.output << chunk }

      @build.output      = command.output
      @build.exit_status = command.exit_status

      File.delete(script_path)

      @build.finished_at = Time.now.utc

      info "#{@build.namespace} ##{@build.id} finished with exit status #{command.exit_status}"
    end

    private

    def directory_path
      @directory_path ||= Buildbox.root_path.join(@build.namespace)
    end

    def script_path
      @script_path ||= Buildbox.root_path.join("buildbox-#{@build.namespace.gsub(/\//, '-')}-#{@build.id}")
    end
  end
end
