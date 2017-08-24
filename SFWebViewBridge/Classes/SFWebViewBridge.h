//
//  SFWebViewBridge.h
//  SFWebViewBridge
//
//  Created by 花菜 on 2017/8/23.
//  Copyright © 2017年 chriscaixx. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SFWebViewBridge : NSObject

/**
 快速创建桥

 @param webView 需要建立桥接的 webView
 @param delegate 桥接代理一般为webView所属控制器
 @return bridge
 */
+ (instancetype)bridgeWithWebView:(UIWebView *)webView delegate:(id<UIWebViewDelegate>)delegate;

/**
 调用不带参数的 JS 方法

 @param handlerName 方法名
 */
- (void)callHandler:(NSString*)handlerName;

/**
 调用带参数的 JS 方法

 @param handlerName 方法名
 @param parameter 参数,建议使用 NSDictionary类型
 */
- (void)callHandler:(NSString*)handlerName parameter:(id)parameter;

/**
 注册方法给 JS 调用
 建议只注册一个方法给 JS, 然后在 data 通过 JSON 对象的形式,在里面定义一个 requestCode 属性,通过该属性类调用 OC 对应的方法
 例如:
 
 [self.bridge registerHandler:@"javaScriptBridgeToOC" completion:^(id data) {
    [self dealWithData:data];
 }];
 - (void)dealWithData:(id)data {
    // 根据不同的功能号调用不同的具体方法
    switch([data[@"requestCode"] integerValue]) {
        case 0:{
        // 跳转新页面
            break;
        }
        case 1:{
        // 放回上一级页面
        break;
        }
        case 2:{
        // 其他功能
        break;
        }
    }
 }
 
 
 @param handlerName 方法名
 @param completion 完成回调
 */
- (void)registerHandler:(NSString*)handlerName completion:(void(^)(id data))completion;
@end
