platform :ios, '15.0'

project 'RMQClient.xcodeproj'

target 'MemoryTest' do
  use_frameworks!
end

target 'RMQClient' do
  use_frameworks!

  pod "CocoaAsyncSocket", "~> 7.6"
  pod "JKVValue", "~> 1.3"

  target 'RMQClientIntegrationTests' do
  end

  target 'RMQClientTests' do
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'

      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = "NO"
    end
  end
end
