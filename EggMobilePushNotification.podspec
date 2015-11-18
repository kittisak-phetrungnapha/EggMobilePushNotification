#
# Be sure to run 'pod lib lint EggMobilePushNotification.podspec' to ensure this is a
# valid spec before submitting.

Pod::Spec.new do |s|
  s.name             = "EggMobilePushNotification"
  s.version          = "0.9.2"
  s.summary          = "The library that provides an application is integrated with True Push Notification service."
  s.description      = "This CocoaPod provides the ability to use a True Push Notification service that maybe subscribe, unsubscribe and accept incoming push notification in log."
  s.homepage         = "https://github.com/csnu17/EggMobilePushNotification"
  s.license          = 'MIT'
  s.author           = { "Kittisak Phetrungnapha" => "cs.sealsoul@gmail.com" }
  s.source           = { :git => "https://github.com/csnu17/EggMobilePushNotification.git", :tag => s.version.to_s }
  s.social_media_url = 'https://www.facebook.com/SealSoul'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.resource_bundles = {
    'EggMobilePushNotification' => ['Pod/Assets/*.png']
  }

  s.source_files = 'Pod/Classes/**/*'
#s.public_header_files = 'Pod/Classes/EggMobilePushNotification.h'
  s.frameworks = 'SystemConfiguration'
end
