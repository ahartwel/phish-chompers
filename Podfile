# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Chompers' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Chompers
  pod 'Moya'
  pod 'ReactiveKit'
  pod 'Bond'
  pod 'PromiseKit'
  pod 'SnapKit'
  pod 'StreamingKit'
  pod 'TWRDownloadManager'
  pod 'ionicons'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'PinpointKit/Core'
  target 'ChompersTests' do
    inherit! :search_paths
    pod 'FBSnapshotTestCase'
    # Pods for testing
  end

  target 'ChompersUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'Diff' || target.name == 'Bond' || target.name == 'ReactiveKit'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
    end
end
