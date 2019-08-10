Pod::Spec.new do |s|
  s.name         = 'YYUtility'
  s.summary      = 'A collection of iOS components.'
  s.version      = '1.1.0'
  s.authors      = { 'ibireme' => 'ibireme@gmail.com' }
  s.social_media_url = 'http://blog.ibireme.com'
  s.homepage     = 'https://github.com/ibireme/YYKit'
  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  s.source       = { :git => 'http://team.aicoin.net.cn/lab/Huangjian/YYKit_modify.git', :tag => s.version.to_s }
  
  s.requires_arc = true
  s.source_files = 'YYUtility/**/*.{h,m}'
  s.public_header_files = 'YYUtility/**/*.{h}'

  s.libraries = 'z', 'sqlite3'
  s.frameworks = 'UIKit', 'CoreFoundation', 'CoreText', 'CoreGraphics', 'CoreImage', 'QuartzCore', 'ImageIO', 'Accelerate', 'MobileCoreServices', 'SystemConfiguration'

end
