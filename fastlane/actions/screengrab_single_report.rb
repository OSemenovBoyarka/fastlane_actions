require 'erb'

module Fastlane
  module Actions
    module SharedValues
      #       SCREENGRAB_SINGLE_REPORT_CUSTOM_VALUE = :SCREENGRAB_SINGLE_REPORT_CUSTOM_VALUE
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/fastlane/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class ScreengrabSingleReportAction < Action
      def self.run(params)
        Dir.chdir(FastlaneFolder.path) do
          base_path = params[:base_dir]

          output_filename = params[:output_filename]

          # this is adopted code from https://github.com/fastlane/fastlane/blob/master/snapshot/lib/snapshot/reports_generator.rb
          @data = {}

          orientation = 'portrait'
          screenshots_path_prefix = params[:path_prefix]
          screenshots_count = 0
          Dir[File.join(base_path, '*')].sort.each do |language_folder|
            language = File.basename(language_folder)
            Dir[File.join(language_folder, "#{screenshots_path_prefix}/*.png")].sort.each do |screenshot|
            #creating needed hashes
              @data[language] ||= {}
              @data[language][orientation] ||= []

              resulting_path = File.join('.', language, "#{screenshots_path_prefix}/#{File.basename(screenshot)}")
              @data[language][orientation] << resulting_path
              screenshots_count += 1
            end
          end
          
          raise "No screenshots found at '#{base_path}/<langugage_code>/#{screenshots_path_prefix}'" unless screenshots_count > 0
        
          # generating html
          html_template = File.read(params[:html_template_path])
          html = ERB.new(html_template).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

          export_path = "#{base_path}/#{output_filename}"
          File.write(export_path, html)

          export_path = File.expand_path(export_path)
          UI.success "Total #{screenshots_count} screenshots. See HMTL report with overview of all screenshots: '#{export_path}'"
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Screengrab report creator'
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        'This action gathers screenshots obtained by screengrab to a nice looking HTML, just like Fastlane/Snapshot'
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :base_dir,
                                       env_name: 'FL_SCREENGRAB_SINGLE_REPORT_BASE_DIRECTORY', # directory, where screenshots are stored
                                       description: 'Directory, where screenshots are stored. Basically, this should be a screengrab output', # a short description of this parameter
                                       verify_block: proc do |value|
                                         raise "No Base Directory for ScreengrabSingleReportAction given, pass using `base_dir: 'path/'`".red unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :output_filename,
                                       env_name: 'FL_SCREENGRAB_SINGLE_REPORT_OUTPUT_FILENAME',
                                       description: 'Name of resulting html. Default is screnshots.html',
                                       default_value: 'screenshots.html'),
          FastlaneCore::ConfigItem.new(key: :html_template_path,
                                       env_name: 'FL_SNAPSHOT_MULTI_REPORT_HTML_TEMPLATE_PATH', # The name of the environment variable
                                       description: 'Path to ERB template for HTML report', # a short description of this parameter
                                       default_value: 'assets/screenshots_single.html.erb'
                                      ),
          FastlaneCore::ConfigItem.new(key: :path_prefix,
                                       env_name: 'FL_SNAPSHOT_MULTI_REPORT_HTML_SCREENSHOTS_PATH_PREFIX', # The name of the environment variable
                                       description: 'Prefix, represents relative path for screenshots folder relative to locale folder', # a short description of this parameter
                                       default_value: 'images/phoneScreenshots'
                                      )
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        #         [
        #           ['SCREENGRAB_SINGLE_REPORT_CUSTOM_VALUE', 'A description of what this value contains']
        #         ]
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
        #  [:ios, :mac].include?(platform)
        #

        platform == :android
      end
    end
  end
end