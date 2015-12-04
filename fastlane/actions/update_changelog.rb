module Fastlane
  module Actions
    module SharedValues
      UPDATE_CHANGELOG_CURRENT = :UPDATE_CHANGELOG_CURRENT
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class UpdateChangelogAction < Action
    	CHANGELOG_TEMPLATE_LEGACY = "### Fixed\n*\n\n### Added\n*\n\n### Removed\n*"
    	CHANGELOG_TEMPLATE = "* Put your changes here one by one, you can use markdown syntax"
    
      def self.run(params)

        changelogFilename ='CHANGELOG.md';
        currentChangelogFilename ='CHANGELOG_CURRENT.md';

        version = params[:version]

        currentChangeLog = File.read(currentChangelogFilename).to_s.strip
        changelogErrorMessage = "You have not provided changelog for build. Please, fill in file CHANGELOG_CURRENT.md";
      	raise changelogErrorMessage unless CHANGELOG_TEMPLATE.to_s != currentChangeLog.to_s
      	raise changelogErrorMessage unless CHANGELOG_TEMPLATE_LEGACY.to_s != currentChangeLog.to_s
        globalChangeLog = File.read(changelogFilename);
#       prepending contents of current changelog to existing file
        File.open(changelogFilename, 'w') do |fo|
                currentDate = Time.now.strftime('%Y-%m-%d')
                fo.puts "## #{version} - #{ currentDate }"
                fo.puts currentChangeLog
                fo.puts "\n"
                fo.puts globalChangeLog
        end
#        deleting current changelog file to make it clean for next releases
        File.open(currentChangelogFilename, 'w') do |fo|
        	fo.puts CHANGELOG_TEMPLATE
        end
    
      Actions.lane_context[SharedValues::UPDATE_CHANGELOG_CURRENT] = currentChangeLog
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Reads current changelog and appends it to global one"
      end

      def self.details
        # Optional:
        # this is your change to provide a more detailed description of this action
        "You can use this action to provide change log for olg version and update global one with it. You must have CHANGELOG_CURRENT.md file with changes for current version. You can use standard markdown. It then be moved to CHANGELOG.md as changes for current version and cleaned"
      end

      def self.available_options
[
FastlaneCore::ConfigItem.new(key: :version,
                             env_name: "FL_UPDATE_CHANGELOG_VERSION", # The name of the environment variable
                             description: "Complete version string, which will be added as current version to changelog", # a short description of this parameter
                             verify_block: proc do |value|
                             raise "No new app version for UpdateChangeLog given, pass using `version: 'token'`".red unless (value and not value.empty?)
                             end)
]
        # Define all options your action supports.
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
          ['UPDATE_CHANGELOG_CURRENT', 'Current version changelog string representation, you can send it to slack, for instance']
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["SemenovAlexander"]
      end

      def self.is_supported?(platform)
         [:ios, :mac, :android].include? platform
      end
    end
  end
end
