source 'https://github.com/CocoaPods/Specs'
platform :ios, '11.0'
use_frameworks!

target 'PersonalVPN' do
  pod 'TunnelKit'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'Swinject'
  pod 'lottie-ios'
  pod 'Amplitude-iOS'
  pod 'SwiftyStoreKit'
  pod 'Alamofire'
end

target 'PVPN-NE' do
  pod 'TunnelKit'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
