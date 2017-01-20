source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'DiffHub' do
    pod 'Alamofire', '~> 4.0'
    pod 'SwiftyJSON'
    pod 'RealmSwift'
    pod 'Kingfisher', '~> 3.0'   
    pod 'AMScrollingNavbar'
    pod 'DateTools'
    pod 'NVActivityIndicatorView'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
