#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint carp_movesense_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'carp_movesense_flutter'
  s.version          = '0.1.0'
  s.summary          = 'CARP Movesense Flutter Plugin'
  s.description      = <<-DESC
CARP Movesense Flutter plugin. macOS registers typed Pigeon channels and
returns unsupported errors because no macOS Movesense MDS binary is bundled.
                       DESC
  s.homepage         = 'https://carp.dk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Copenhagen Research Platform' => 'support@carp.dk' }

  s.source           = { :path => '.' }
  s.source_files = 'carp_movesense_flutter/Sources/carp_movesense_flutter/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'carp_movesense_flutter_privacy' => ['carp_movesense_flutter/Sources/carp_movesense_flutter/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
