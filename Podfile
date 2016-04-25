source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
use_frameworks!

pod 'Google-Mobile-Ads-SDK', '~> 7.0'
pod 'ECSlidingViewController', '~> 2.0.3'
pod 'SwiftyDropbox'
pod 'ICTextView', :git => "https://github.com/paveway/ICTextView.git", :branch => "master"
pod 'OneDriveSDK'

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

target 'PWEditorTests' do
    testing_pods
end

xcodeproj './PWEditor.xcodeproj'
