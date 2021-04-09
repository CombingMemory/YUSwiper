#
#  Be sure to run `pod spec lint YUSwiper.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "YUSwiper"
  spec.version      = "1.1.0"
  spec.summary      = "一个可以设置整页滑动宽度的轮播图"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!

  spec.description  = <<-DESC
  一个可以设置整页滑动宽度的轮播图
                   DESC

  spec.homepage     = "https://github.com/CombingMemory/YUSwiper"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "lvyi" => "956167738@qq.com" }
  spec.source       = { :git => "https://github.com/CombingMemory/YUSwiper.git", :tag => "#{spec.version}" }
  spec.source_files = "Classes/**/*"


  spec.platform = :ios, "6.0"
  spec.requires_arc = true


end
