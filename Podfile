# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
inhibit_all_warnings!
def pods
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
    pod 'SwiftLint'
end

target 'Chompers' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
	pods
  # Pods for Chompers

  target 'ChompersUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'ChompersDev' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
	pods
  # Pods for ChompersDev
  target 'ChompersTests' do
      inherit! :search_paths
      pod 'FBSnapshotTestCase'
      # Pods for testing
  end
end
