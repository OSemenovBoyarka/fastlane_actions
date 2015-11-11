module Fastlane
  module Actions
    module SharedValues
      PREPARE_SNAPFILES_FILES_PATHS = :PREPARE_SNAPFILES_FILES_PATHS
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class PrepareSnapfilesAction < Action
      def self.run(params)
        require 'fileutils'
		Dir.chdir(FastlaneFolder.path) do
			template = File.read("#{params[:snapfile_template_path]}")
	
			devices = params[:devices]
			langs = params[:languages]
			basePath = params[:screenshots_path]
			resultPaths = []
			ios_version = params[:ios_version]
			langs.each do |item|
                language = item.kind_of?(Array) ? item[0] : item
                locale = item.kind_of?(Array) ? item[1] : item
				devices.each do |device|
					path = basePath+"/"+locale+"/"+device
					if not ios_version.empty? 
						path += " (#{ios_version})"
					end	
					FileUtils.mkdir_p path
					File.open(path+"/Snapfile", "w") do |fo|
						fo.puts template
						fo.puts "\n"
						fo.puts "output_directory \"fastlane/#{path}\""
						fo.puts "\n"
						fo.puts "devices([\"#{device}\"])"
						fo.puts "\n"
						fo.puts "languages([[\"#{language}\",\"#{locale}\"]])"
						fo.puts "\n"
						fo.puts "ios_version '#{ios_version}'" unless ios_version.empty?
					end
					resultPaths << path
				end
			end
			Actions.lane_context[SharedValues::PREPARE_SNAPFILES_FILES_PATHS] = resultPaths
		end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Generates snapfile from template in each language/device folder combination"
      end

      def self.details
        # Optional:
        # this is your change to provide a more detailed description of this action
        "You can use this action to generate individuat snapshot report for each language/device combination. Just run snapshot for each path, returned in PREPARE_SNAPFILES_FILES_PATHS shared value"
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :devices,
                                       env_name: "FL_PREPARE_SNAPFILES_DEVICES", # The name of the environment variable
                                       description: "Array with names of simulator devices to use", # a short description of this parameter
                                       is_string: false,
                                       verify_block: proc do |value|
                                          raise "No Devices for PrepareSnapfilesAction given, pass using `devices: ['iPhone 4s', 'iPhone 6',...]`".red unless (value and not value.empty?)
                                       end),
		  FastlaneCore::ConfigItem.new(key: :languages,
                                       env_name: "FL_PREPARE_SNAPFILES_LANGUAGES", # The name of the environment variable
                                       description: "Array with names of simulator devices to use", # a short description of this parameter
                                       is_string: false,
                                       verify_block: proc do |value|
                                          raise "No languages for PrepareSnapfilesAction given, pass using `languages: ['en-US', 'ru-RU']`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :snapfile_template_path,
                                       env_name: "FL_PREPARE_SNAPFILES_TEMPLATE_PATH", # The name of the environment variable
                                       description: "path for template snapfile, to which info will be added", # a short description of this parameter
                                       default_value: "Snapfile-template"
                                      ),  
          FastlaneCore::ConfigItem.new(key: :screenshots_path,
                                       env_name: "FL_PREPARE_SNAPFILES_SCREENSHOTS_PATH", # The name of the environment variable
                                       description: "Base directory for screenshots, from where action will separate snapfiles through language dirs", # a short description of this parameter
                                       default_value: "screenshots-ui-test"
                                      ), 
		  FastlaneCore::ConfigItem.new(key: :ios_version,
                                       env_name: "FL_PREPARE_SNAPFILES_IOS_VERSION", # The name of the environment variable
                                       description: "Optional ios version to be added in generated snapfile as param", # a short description of this parameter
                                       default_value: ""
                                      ),                              
          
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['PREPARE_SNAPFILES_FILES_PATHS', 'Array with pathes to generated Snapfiles']
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["SemenovAlexander"]
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
		# for now we use this only on ios
        platform == :ios
      end
    end
  end
end
