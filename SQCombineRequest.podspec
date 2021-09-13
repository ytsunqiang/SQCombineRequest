#
# Be sure to run `pod lib lint SQCombineRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SQCombineRequest'
  s.version          = '1.0.1'
  s.summary          = '网络封装库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ytsunqiang/SQCombineRequest'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.author           = { 'sunqiang' => 'ytsunqiang0319@163.com' }
  s.source           = { :git => 'https://github.com/ytsunqiang/SQCombineRequest.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.subspec 'SQCombineRequestCombine' do |aa|
     aa.source_files = 'SQCombineRequest/Combine/**/**'
  end
  
  s.subspec 'SQCombineRequestNetTool' do |aa|
     aa.dependency 'AFNetworking'
     aa.source_files = 'SQCombineRequest/NetTool/**/**'
     aa.dependency 'SQCombineRequest/SQCombineRequestCombine'
     aa.pod_target_xcconfig  = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'SQCOMBINEREQUESTNETTOOL=1'
     }
  end
  s.default_subspec = 'SQCombineRequestNetTool'
  s.xcconfig = {
    'USER_HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Headers/Public"/**'
  }
 
end
