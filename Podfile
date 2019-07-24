# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

inhibit_all_warnings!
use_modular_headers!

abstract_target 'DDPlay_Target' do
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    # use_frameworks!
    
    # Pods for DanDanPlayForiOS
    
    
    # pod 'JHDanmakuRender', :path => 'LocalPods/JHDanmakuRender'
    pod 'YYUtility', :path => 'LocalPods/YYUtility'
    
    pod 'AFNetworking'
    pod 'Masonry'
    pod 'YYModel'
    pod 'YYWebImage'
    pod 'YYCategories'
    pod 'MJRefresh'
    pod 'MBProgressHUD'
    pod 'JHDanmakuRender'
    pod 'UITableView+FDTemplateLayoutCell'
    pod 'RATreeView'
    pod 'WMPageController'
    pod 'IQKeyboardManager'
    pod 'DZNEmptyDataSet'
    pod 'NKOColorPickerView'
    pod 'YYKeyboardManager'
    pod 'MGSwipeTableCell'
    # pod 'UITextView+Placeholder'
    pod 'iCarousel'
    
    

    target 'DDPlay' do
    pod 'TOSMBClient', '~> 1.0.5'
    pod 'CocoaHTTPServer'
    pod 'MobileVLCKit', '3.3.0'
    pod 'WCDB'

    # 集成新浪微博
    pod 'UMengUShare/Social/ReducedSina'
    # 集成QQ
    pod 'UMengUShare/Social/ReducedQQ'
    # 集成微信
    pod 'UMengUShare/Social/WeChat'

    # 友盟统计
    pod 'UMengAnalytics'
    pod 'Bugly'
    #内存泄露检测
    pod 'MLeaksFinder', :configurations => ['Debug'] 
    pod 'DDPEncrypt', :path => 'LocalPods/Encrypt'
    end

    target 'DDPlay_Review' do
    pod 'CocoaLumberjack'
    pod 'MobileVLCKit', '3.3.0'
    pod 'WCDB'

    # 集成新浪微博
    pod 'UMengUShare/Social/ReducedSina'
    # 集成QQ
    pod 'UMengUShare/Social/ReducedQQ'
    # 集成微信
    pod 'UMengUShare/Social/WeChat'

    # 友盟统计
    pod 'UMengAnalytics'
    pod 'Bugly'
    #内存泄露检测
    pod 'MLeaksFinder', :configurations => ['Debug'] 
    pod 'DDPEncrypt', :path => 'LocalPods/Encrypt'
    end

    target 'DDPlay_ToMac' do
    pod 'CocoaLumberjack'
    end
end
