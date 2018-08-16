#
# Be sure to run `pod lib lint XVIEWAvdioManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XVIEWAvdioManager'
  s.version          = '0.1.8'
  s.summary          = '音视频相关，包含录音，上传视频'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/xiaheng666/XVIEWAvdioManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xiaheng666' => 'key@xiaheng.net' }
  s.source           = { :git => 'git@github.com:xiaheng666/XVIEWAvdioManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'XVIEWAvdioManager/Classes/**/*','XVIEWAvdioManager/Classes/**/**/*','XVIEWAvdioManager/Classes/**/**/**/*','XVIEWAvdioManager/Classes/**/**/**/**/*'
  
  #   s.resource_bundles = {
  # 'XVIEWAvdioManager' => ['XVIEWAvdioManager/Assets/*@2x.png','XVIEWAvdioManager/Assets/*@3x.png']
  #}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
s.dependency 'StreamingKit', '=0.1.29'# 音视频
s.dependency 'LameTool', '~> 0.0.2'    # 音视频
s.dependency 'Masonry'   # 音视频
end
