//
//  SFWebViewBridge.m
//  SFWebViewBridge
//
//  Created by 花菜 on 2017/8/23.
//  Copyright © 2017年 chriscaixx. All rights reserved.
//

#import "SFWebViewBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface SFWebViewBridge ()<UIWebViewDelegate>
@property (nonatomic, weak) id<UIWebViewDelegate> delegate;
@property (nonatomic, strong) JSContext * context;
@property (nonatomic, strong) NSMutableDictionary * messageHandlers;
@end
@implementation SFWebViewBridge
+ (instancetype)bridgeWithWebView:(UIWebView *)webView delegate:(id)delegate;
{
    SFWebViewBridge * bridge = [[SFWebViewBridge alloc] init];
    webView.delegate = bridge;
    bridge.delegate = delegate;
    return bridge;
}


- (void)callHandler:(NSString*)handlerName
{
    [self callHandler:handlerName parameter:nil];
}

- (void)callHandler:(NSString*)handlerName parameter:(id)parameter
{
    if (parameter != nil)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
        // 参数类型不能为自定义类型
        NSBundle *mainB = [NSBundle bundleForClass:[parameter class]];
        NSAssert(mainB != [NSBundle mainBundle], @"请使用合法的参数类型");
#pragma clang diagnostic pop
        return;
    }
    else
    {
        // 执行 JS
        [self.context evaluateScript:[NSString stringWithFormat:@"%@()",handlerName]];
        return;
    }
    
    NSString * jsonString = nil;
    // 将参数转为字符串
    if ([parameter isKindOfClass:[NSArray class]] | [parameter isKindOfClass:[NSDictionary class]])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:nil];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    else if ([parameter isKindOfClass:[NSString class]])
    {
        jsonString = parameter;
    }
    else
    {
       jsonString= [NSString stringWithFormat:@"%@",parameter];
    }
    // 拼接JS方法名与参数
    NSString * StringParameter = [NSString stringWithFormat:@"%@(%@)",handlerName,jsonString];
    // 执行 JS
    [self.context evaluateScript:StringParameter];
}




- (void)registerHandler:(NSString*)handlerName completion:(void (^)(id))completion
{
    self.messageHandlers[handlerName] = ^(id data) {
        // 回到主线程调用
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(data);
        });
    };
}

#pragma mark -
#pragma mark - ===== UIWebViewDelegate =====


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (_delegate && [_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
       return [_delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [_delegate webViewDidStartLoad:webView];
    }
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 获取 JSContext并赋值
    _context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // 添加所有注册的handler
    if (self.messageHandlers.count != 0)
    {
        __weak typeof(self) weakself = self;
        [self.messageHandlers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            weakself.context[key] = obj;
        }];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [_delegate webViewDidFinishLoad:webView];
    }
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [_delegate webView:webView didFailLoadWithError:error];
    }
}


- (NSMutableDictionary *)messageHandlers
{
    if (!_messageHandlers)
    {
        _messageHandlers = [[NSMutableDictionary alloc] init];
    }
    return _messageHandlers;
}

@end
