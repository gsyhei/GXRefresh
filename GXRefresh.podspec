#
#  Be sure to run `pod spec lint GXRefresh.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name          = "GXRefresh"
  s.version       = "1.0.0"
  s.summary       = "Swift版的下拉刷新上拉加载，支持Gif、支持自定义刷新动画。"
  s.homepage      = "https://github.com/gsyhei/GXRefresh"
  s.license       = "MIT"
  s.author        = { "Gin" => "279694479@qq.com" }
  s.platform      = :ios, "9.0"
  s.swift_version = "4.0"
  s.source        = { :git => "https://github.com/gsyhei/GXRefresh.git", :tag => "1.0.0" }
  s.requires_arc  = true
  s.source_files  = "GXRefresh"
  s.frameworks    = "Foundation","UIKit"

end
