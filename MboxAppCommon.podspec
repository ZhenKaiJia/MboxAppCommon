#
# Be sure to run `pod lib lint MboxAppCommon.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'MboxAppCommon'
    s.version          = '0.0.2'
    s.summary          = '公共组件'

    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!

    s.description      = '存放一些项目学习中经常会用到的一些公共方法'

    s.homepage         = 'https://github.com/ZhenKaiJia/MboxAppCommon.git'

    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = 'ZhenKaiJia'
    s.source           = { :git => 'https://github.com/ZhenKaiJia/MboxAppCommon.git', :tag => s.version.to_s }

    s.ios.deployment_target = '8.0'
    s.source_files = 'MboxAppCommon/Classes/**/*'
    s.swift_version = '4.0'

    # s.resource_bundles = {'AppCommonDDDD' => ['MboxAppCommon/Assets/*.png']}

    # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'CHTCollectionViewWaterfallLayout'
end
