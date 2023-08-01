
Pod::Spec.new do |s|
  s.name             = 'sfmc_flutter'
  s.version          = '1.0.0'
  s.summary          = 'Salesforce Marketing Cloud for Flutter'
  s.description      = <<-DESC
Flutter plugin for integrating Salesforce Marketing Cloud in Flutter apps, for both iOS and Android.
                       DESC
  s.homepage         = 'http://dribba.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'alex@dribba.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'MarketingCloudSDK', '8.0.13'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
