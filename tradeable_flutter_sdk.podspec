Pod::Spec.new do |s|
  s.name             = 'tradeable_flutter_sdk'
  s.version          = '1.0.4'
  s.summary          = 'Tradeable Flutter SDK Module'
  s.description      = 'Flutter module for Tradeable SDK that can be embedded in iOS apps'
  s.homepage         = 'https://github.com/deepakgrandhi/tradeable_flutter_sdk_module'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Deepak' => 'deepakgrandhi@gmail.com' }
  s.source           = { :git => 'https://github.com/Tradeable/tradeable_flutter_sdk_module.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  
  # This tells CocoaPods this is a Flutter module
  s.source_files = 'lib/**/*.dart'
  s.resource_bundles = {
    'tradeable_flutter_sdk' => ['lib/assets/**/*']
  }
  
  # Flutter dependencies
  s.dependency 'Flutter'
  
  # Platform configuration
  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
  
  s.swift_version = '5.0'
end