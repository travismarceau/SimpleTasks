# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SimpleTasks' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for SimpleTasks
  pod 'RealmSwift'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            # Signing
            config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
        end
    end
end
