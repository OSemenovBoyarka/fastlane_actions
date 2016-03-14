require 'erb'
require 'json'

module Fastlane
  module Actions
    module SharedValues
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class SnapshotMultiReportAction < Action
      def self.run(params)
        Dir.chdir(FastlaneFolder.path) do
          # fastlane will take care of reading in the parameter and fetching the environment variable:
          screenshots_path = params[:screenshots_path]
          @languages = Dir["#{screenshots_path}/*/"].map { |a| File.basename(a) }
          # we assume all languages has screenshots for all simulators, so it would be sufficient to check only first language
          @devices = Dir["#{screenshots_path}/#{@languages[0]}/*/"].map { |a| File.basename(a) }
          @title = params[:html_title]
          template = File.read(params[:html_template_path])
          result = ERB.new(template).result(binding)
          File.open(screenshots_path + '/screenshots.html', 'w') do |fo|
            fo.write(result)
          end

          ### collecting metadata for screenshot compare script
          filenames = {}

          orientations = %w(portrait landscape)
          orientations.each { |o| filenames[o] = [] }

          otherOrientation = []
          Dir["#{screenshots_path}/#{@languages[0]}/#{@devices[0]}/#{@languages[0]}/*.png"].each do |fn|
            filename = File.basename(fn)
            # we don't want device name in files hash as it changes across devices
            filename.slice!("#{@devices[0].delete(' ')}-")
            added = false
            orientations.each do |o|
              next unless filename.include? o
              filenames[o] << filename
              added = true
              break
            end
            otherOrientation << filename unless added
          end

          # if we couldn't detect orientaion - put all that screenshots in 'other' category
          unless otherOrientation.empty?
            filenames['other'] = otherOrientation
            orientations << 'other'
          end

          metadataJson = {
            'devices' => @devices,
            'languages' => @languages,
            'orientations' => orientations,
            'filenames' => filenames
          }

          File.open(screenshots_path + '/metadata.json', 'w') do |f|
            f.write(metadataJson.to_json)
          end

          ### writing html for compare from assets
          FileUtils.cp 'assets/screenshots_compare.html', "#{screenshots_path}/screenshots_compare.html"
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Gathers all language/device html reports to single html table '
      end

      def self.details
        # Optional:
        # this is your change to provide a more detailed description of this action
        'Action iterates over given screenshots folder for each language and each device type, picks eachs screenshots.html file and creates gathered table to show all of it. Also this adds metadata and html/js page for screenshots comparison'
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :screenshots_path,
                                       env_name: 'FL_SNAPSHOT_MULTI_REPORT_SCREENSHOTS_PATH', # The name of the environment variable
                                       description: 'Base directory for screenshots, from where action will separate snapfiles through language dirs', # a short description of this parameter
                                       default_value: 'screenshots-ui-test'
                                      ),
          FastlaneCore::ConfigItem.new(key: :html_title,
                                       env_name: 'FL_SNAPSHOT_MULTI_REPORT_HTML_TITLE', # The name of the environment variable
                                       description: 'Title to show in result html', # a short description of this parameter
                                       default_value: 'Screenshots report'
                                      ),
          FastlaneCore::ConfigItem.new(key: :html_template_path,
                                       env_name: 'FL_SNAPSHOT_MULTI_REPORT_HTML_TEMPLATE_PATH', # The name of the environment variable
                                       description: 'Path to ERB template for HTML report', # a short description of this parameter
                                       default_value: 'assets/screenshots_list.erb'
                                      )
        ]
      end

      def self.output
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ['SemenovAlexander']
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include? platform
        #

        [:ios, :mac].include? platform
      end
    end
  end
end
