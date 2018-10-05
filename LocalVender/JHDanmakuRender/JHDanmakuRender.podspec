Pod::Spec.new do |s|
  s.name         = "JHDanmakuRender"
  s.version      = "2.0"
  s.summary      = "A danmaku rendering engine for iOS and OSX 一个iOS和OSX通用的弹幕渲染引擎"
  s.homepage     = "https://github.com/sunsx9316/JHDanmakuRender"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "jimHuang" => "sun_8434@163.com" }
  s.source       = { :git => "https://github.com/sunsx9316/JHDanmakuRender.git", :tag => s.version.to_s }

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.8"
  s.public_header_files = 'JHDanmakuRender/**/*.h'
  s.source_files  = "JHDanmakuRender/**/*.{h,m}"
  s.requires_arc = true
end
