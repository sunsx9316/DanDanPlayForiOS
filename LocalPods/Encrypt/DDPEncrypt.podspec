Pod::Spec.new do |s|

  s.name         = "DDPEncrypt"
  s.version      = "1.0"
  s.summary      = "dandanPlay Encrypt iOS SDK."
  s.homepage     = "http://www.dandanplay.com/"
  s.author       = { "jimHuang" => "sun_8434@163.com" }
  s.platform     = :ios
  s.source       = { :git => '', :tag => s.version, :submodules => true }
  s.vendored_frameworks = 'Encrypt/DanDanPlayEncrypt.framework'

end