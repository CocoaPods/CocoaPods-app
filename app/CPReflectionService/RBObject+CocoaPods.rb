Encoding.default_external = 'UTF-8'

# This is required for Foundation classes to be known to this side of the bridge at all.
require 'osx/objc/foundation'

service_bundle = OSX::NSBundle.mainBundle
bundle_path = File.expand_path('../../Resources/bundle', service_bundle.bundlePath)
incorrect_root = File.join(service_bundle.bundlePath, 'Contents/MacOS')

# Fix all load paths to point to the bundled Ruby.
$LOAD_PATH.map! do |path|
  path.sub(incorrect_root, bundle_path)
end

module Pod
  module App
    # Doing this here so that you get nicer errors when a require fails.
    def self.require_gems
      require 'rubygems'
      require 'cocoapods'

      require 'claide/command/plugin_manager'
      require 'claide/ansi'
      CLAide::ANSI.disabled = true
    end

    # TODO This needs tests.
    def self.analyze_podfile(podfile, installation_root)
      config = Pod::Config.new
      config.podfile = podfile
      config.installation_root = installation_root
      Pod::Config.instance = config

      analyzer = Pod::Installer::Analyzer.new(config.sandbox, config.podfile, config.lockfile)
      analysis = analyzer.send(:inspect_targets_to_integrate).values
      
      user_projects = {}
      analysis.each do |target|
        user_project = user_projects[target.project_path.to_s] ||= {}
        user_targets = user_project["targets"] ||= {}
        target.project_target_uuids.each do |uuid|
          user_target = target.project.objects_by_uuid[uuid]
          user_target_info = user_targets[user_target.name] ||= begin
            {
              "info_plist" => user_target.resolved_build_setting("INFOPLIST_FILE").values.first,
              "type" => user_target.product_type,
              "platform" => target.platform.to_s,
              "pod_targets" => [],
            }
          end
          user_target_info["pod_targets"] << target.target_definition.label
        end
      end

      pod_targets = config.podfile.target_definitions.values.inject({}) do |h, target_definition|
        h[target_definition.label] = target_definition.dependencies.map(&:name) unless target_definition.empty?
        h
      end

      uses_frameworks = config.podfile.target_definitions.first.last.to_hash["uses_frameworks"]
      last_installed_version = config.sandbox.manifest && config.sandbox.manifest.cocoapods_version.to_s
      {
        "projects" => user_projects,
        "pod_targets" => pod_targets,
        "uses_frameworks" => uses_frameworks,
        "cocoapods_build_version" => last_installed_version
      }
    end

    def self.sources_manager
      Pod::Config.instance.sources_manager
    end

    def self.all_pods
      sources_manager.aggregate.all_pods
    end

    def self.pod_versions(podName)
      sources_manager.aggregate.search_by_name(podName).first.versions.map(&:to_s)
    end

    def self.master_source
      sources_manager.master
    end

    def self.pod_sources
      sources_manager.all.map { |source|
        { source.name => source.url }

      }.reduce &:merge
    end

    def self.lockfile_version(path)
      lockfile = Lockfile.from_file(path)
      lockfile.cocoapods_version.to_s
    end

    def self.compare_versions(version1, version2)
      Pod::Version.new(version1) <=> Pod::Version.new(version2)
    end
  end
end