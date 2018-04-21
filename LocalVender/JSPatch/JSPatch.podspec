Pod::Spec.new do |s|

  s.name         = "JSPatch"
  s.version      = "1.7.3"
  s.summary      = "JSPatch bridge Objective-C and JavaScript. You can call any"  \
                   " Objective-C class and method in JavaScript by just" \
                   " including a small engine."

  s.description  = <<-DESC
                   JSPatch bridges Objective-C and JavaScript using the
                   Objective-C runtime. You can call any Objective-C class and
                   method in JavaScript by just including a small engine.
                   That makes the APP obtaining the power of script language:
                   add modules or replacing Objective-C codes to fix bugs dynamically.
                   DESC
  s.ios.deployment_target = '6.0'
  s.homepage     = "https://github.com/bang590/JSPatch"
  s.author       = { "bang" => "bang590@gmail.com" }
  s.platform     = :ios
  s.source       = { :git => '', :tag => s.version, :submodules => true }
  s.vendored_frameworks = 'JSPatch/JSPatchPlatform.framework'

end