#!/usr/bin/env ruby

require 'xcodeproj'

# Path to the Xcode project
project_path = File.expand_path('../Runner.xcodeproj', __FILE__)
project = Xcodeproj::Project.open(project_path)

# Get the Runner target
runner_target = project.targets.find { |t| t.name == 'Runner' }

unless runner_target
  puts "❌ Runner target not found"
  exit 1
end

puts "📝 Modifying Xcode build settings for Firebase..."

# Apply settings to all configurations
runner_target.build_configurations.each do |config|
  puts "  Configuring: #{config.name}"
  
  # Set deployment target
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
  
  # Add header search paths for Firebase
  current_paths = config.build_settings['HEADER_SEARCH_PATHS'] || []
  current_paths = [current_paths].flatten.compact
  
  new_paths = [
    '$(PODS_ROOT)/Headers/Public',
    '$(PODS_ROOT)/FirebaseCore/Sources',
    '$(PODS_ROOT)/FirebaseAuth/Sources'
  ]
  
  new_paths.each do |path|
    current_paths << path unless current_paths.include?(path)
  end
  
  config.build_settings['HEADER_SEARCH_PATHS'] = current_paths
  
  # Add framework search paths
  current_fw_paths = config.build_settings['FRAMEWORK_SEARCH_PATHS'] || []
  current_fw_paths = [current_fw_paths].flatten.compact
  
  current_fw_paths << '$(PODS_ROOT)/Firebase' unless current_fw_paths.include?('$(PODS_ROOT)/Firebase')
  
  config.build_settings['FRAMEWORK_SEARCH_PATHS'] = current_fw_paths
  
  # CRITICAL: Allow non-modular includes in framework modules
  config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  
  # Module configuration
  config.build_settings['DEFINES_MODULE'] = 'YES'
  
  # Disable bitcode
  config.build_settings['ENABLE_BITCODE'] = 'NO'
  
  # Preprocessor definitions
  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= '$(inherited)'
end

# Save the project
project.save

puts "✅ Xcode project settings modified successfully"
