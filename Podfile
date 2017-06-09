source 'http://git.qianbaoqm.com/mobileios/QBSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
workspace 'QBBaseProjectFrame'
use_frameworks!

abstract_target 'abstract_project_frame' do
    #框架使用(勿删)
    pod 'QBNetworking'
    pod 'Masonry'
    pod 'ReactiveObjC'
    pod 'QBNavBarCustom'
    pod 'WebViewJavascriptBridge'
    pod 'QBCategories'
    #根据不同工程选择合适的pod
    pod 'QBRefresh/Refresh_T3'
    
    #网络
    pod 'SDWebImage'

    #UI
    pod 'SVProgressHUD'
    pod 'SDCycleScrollView'
    pod 'MJRefresh'
    pod 'IQKeyboardManager'
    pod 'DZNEmptyDataSet'
    
    #工具
    pod 'BlocksKit'

    #热更新
    pod 'JSPatch'

    target 'QBBaseProjectFrame' do
        project 'QBBaseProjectFrame/QBBaseProjectFrame.xcodeproj'
    end
    
end
