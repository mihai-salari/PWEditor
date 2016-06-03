source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
use_frameworks!

pod 'Google-Mobile-Ads-SDK', '~> 7.0'
pod 'ECSlidingViewController', '~> 2.0.3'
pod 'SwiftyDropbox'
pod 'ICTextView', :git => "https://github.com/paveway/ICTextView.git", :branch => "master"
pod 'OneDriveSDK'
pod 'iCloudDocumentSync'
#pod 'box-ios-sdk'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

xcodeproj './PWEditor.xcodeproj'
