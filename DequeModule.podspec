Pod::Spec.new do |s|
  s.name = 'DequeModule'
  s.version = '1.1.4'
  s.license = { :type => 'Apache 2.0', :file => 'LICENSE.txt' }
  s.summary = 'A DequeModule API for Swift.'
  s.homepage = 'https://github.com/apple/swift-collections'
  s.author = 'Apple Inc.'
  s.source = { :git => 'https://github.com/apple/swift-collections.git', :tag => s.version.to_s }
  s.module_name = 'DequeModule'

  s.swift_version = '5.9'
  s.cocoapods_version = '>= 1.10.0'

  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/DequeModule/**/*.swift'
  s.dependency 'InternalCollectionsUtilities'
end
