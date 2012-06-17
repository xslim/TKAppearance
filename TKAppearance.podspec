Pod::Spec.new do |s|
  s.name     = 'TKAppearance'
  s.version  = '0.0.1'
  s.platform = :ios
  s.license = 'MIT'
  s.summary  = 'iOS Lib to mimic Apples UIAppearance thing on iOS 4'
  s.homepage = 'https://github.com/xslim/TKAppearance'
  s.authors   = {
    'Taras Kalapun' => 'http://kalapun.com'
  }
  s.source   = { :git => 'git://github.com/xslim/TKAppearance.git' }
  s.source_files = '*.{h,m}'
  s.requires_arc = false
end
