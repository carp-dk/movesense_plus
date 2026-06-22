#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint carp_movesense_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'carp_movesense_flutter'
  s.version          = '0.1.0'
  s.summary          = 'CARP Movesense Flutter Plugin'
  s.description      = <<-DESC
A flutter plugin with direct wrapper around the Movesense SDK.
                       DESC
  s.homepage         = 'https://carp.dk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Copenhagen Research Platform' => 'support@carp.dk' }
  s.source           = { :path => '.' }
  s.source_files = 'carp_movesense_flutter/Sources/carp_movesense_flutter/**/*'
  s.vendored_frameworks = 'carp_movesense_flutter/Vendor/MovesenseMDS.xcframework'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.frameworks = 'CoreBluetooth', 'CoreFoundation'
  s.libraries = 'c++', 'z'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'carp_movesense_flutter_privacy' => ['carp_movesense_flutter/Sources/carp_movesense_flutter/PrivacyInfo.xcprivacy']}
end
