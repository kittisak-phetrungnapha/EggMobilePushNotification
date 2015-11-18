#
# Be sure to run `pod lib lint EggMobilePushNotification.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "EggMobilePushNotification"
  s.version          = "0.9.0"
  s.summary          = "The library that provides an application is integrated with True Push Notification service."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = "This CocoaPod provides the ability to use a True Push Notification service that maybe subscribe, unsubscribe and accept incoming push notification in log."

  s.homepage         = "https://github.com/csnu17/EggMobilePushNotification"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Kittisak Phetrungnapha" => "cs.sealsoul@gmail.com" }
  s.source           = { :git => "https://github.com/csnu17/EggMobilePushNotification.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.resource_bundles = {
    'EggMobilePushNotification' => ['Pod/Assets/*.png']
  }

  s.source_files = 'Pod/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
