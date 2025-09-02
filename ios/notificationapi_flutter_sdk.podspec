Pod::Spec.new do |s|
  s.name             = 'notificationapi_flutter_sdk'
  s.version          = '2.1.0'
  s.summary          = 'A Flutter plugin for integrating NotificationAPI push notifications.'
  s.description      = <<-DESC
A Flutter plugin for integrating NotificationAPI push notifications into your mobile app.
                       DESC
  s.homepage         = 'https://github.com/notificationapi-com/notificationapi-flutter-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'NotificationAPI' => 'support@notificationapi.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end 