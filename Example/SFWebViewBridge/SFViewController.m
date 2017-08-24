//
//  SFViewController.m
//  SFWebViewBridge
//
//  Created by chriscaixx on 08/23/2017.
//  Copyright (c) 2017 chriscaixx. All rights reserved.
//

#import "SFViewController.h"
#import "SFWebViewBridge.h"
#import "SFModel.h"
@interface SFViewController ()<SFWebViewBridgeDelegate>
@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) SFWebViewBridge * bridge;
@end

@implementation SFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
     NSString *path = [[NSBundle mainBundle] pathForResource:@"local.html" ofType:nil];
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"调用JS" style:UIBarButtonItemStyleDone target:self action:@selector(test1)];
    
    [self.bridge registerHandler:@"printHelloWorld" completion:^(id data) {
        NSLog(@"XCode 控制台输出--> %@",data);
    }];
    // 注意循环引用
    __weak typeof(self) wsf = self;
    [self.bridge registerHandler:@"javaScriptBridgeToOC" completion:^(id data) {
        [wsf dealWithData:data];
    }];

}

- (void)jumpToNext
{
    SFViewController * vc = [[SFViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)dealWithData:(id)data
{
    switch([data[@"requestCode"] integerValue]) {
        case 0:{
            // 跳转下一页
            [self jumpToNext];
            break;
        }
        case 1:{
            // 返回上一页
            [self.navigationController popViewControllerAnimated:YES];

            break;
        }
        case 2:{
            NSLog(@"其他功能");
            break;
        }
        default:break;
    }
}

- (void)test1
{
     [self.bridge callHandler:@"test1"];
}


- (void)test2
{
    NSDictionary * data = @{@"name":@"Cai", @"age":@"20"};
    
    [self.bridge callHandler:@"test2" parameter:data];
}

- (void)test3
{
    SFModel * model = [[SFModel alloc] init];
    model.name = @"Cai";
    [self.bridge callHandler:@"test2" parameter:model];
}


- (UIWebView *)webView
{
    if (!_webView)
    {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        [self.view addSubview:_webView];
        _webView.frame = self.view.bounds;
        _bridge = [SFWebViewBridge bridgeWithWebView:_webView delegate:self];
    }
    return _webView;
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}


- (void)dealloc
{
    NSLog(@"SFViewController 正确释放 --->  dealloc");
}

@end
