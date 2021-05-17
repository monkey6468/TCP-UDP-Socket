//
//  ViewController.m
//  TCPSocket_Send
//
//  Created by 肖伟华 on 16/4/24.
//  Copyright © 2016年 XWH. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
#import "Tool.h"
#import "Reachability.h"

@interface ViewController ()<GCDAsyncSocketDelegate>
{
    BOOL _bRunning;
}
@property (strong, nonatomic) GCDAsyncSocket *sendTcpSocket;

@property (weak, nonatomic) IBOutlet UILabel *labelIP;
@property (weak, nonatomic) IBOutlet UITextField *tfHost;
@property (weak, nonatomic) IBOutlet UITextField *tfPort;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UITextField *tfSend;

@property (weak, nonatomic) IBOutlet UITextView *tvRec;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"TCP Send";
    
    [self touchesEnded:nil withEvent:nil];
    
//    dispatch_queue_t dQueue = dispatch_queue_create("client tdp socket", NULL);
    self.sendTcpSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceNetWorkConnected:) name:@"netWork_connect_status" object:nil];
}
- (void)deviceNetWorkConnected:(NSNotification *)noti
{
    BOOL bNetStatus = [[noti object]boolValue];
    if (bNetStatus) {
        [self reconnnectTCP];
    }else
    {
        [self disconnectTcp];
    }
    self.labelIP.text = [Tool localWiFiIPAddress];

}
- (void)longConnectToSend
{
    if (_bRunning) {
        [self disconnectTcp];
    }else {
        [self reconnnectTCP];
    }
}
#pragma mark - 代理方法表示连接成功/失败 回调函数
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [sock readDataWithTimeout:-1 tag:100];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tvRec.text = @"连接成功";
    });
}
// 如果对象关闭了 这里也会调用
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"连接失败 %@", err);
    if (!err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tvRec.text = @"连接失败";
            [self setConnected:NO];
        });
    }else
    {
        [self disconnectTcp];
        [self setConnected:NO];
    }
}
#pragma mark - 消息发送成功 代理函数
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"消息发送成功");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tfSend.text = nil;
    });
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *ip = [sock connectedHost];
    uint16_t port = [sock connectedPort];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.tvRec.text) {
            self.tvRec.text = nil;
        }
    });
    
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"接收到服务器返回的数据 tcp [%@:%d] %@", ip, port, s);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tvRec.text = s;
    });
}
- (IBAction)sendMsg
{
    NSData *data = [self.tfSend.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.sendTcpSocket writeData:data withTimeout:-1 tag:100];
}
- (IBAction)onBtnConnect:(UIButton *)sender
{
    Reachability *reach = [Reachability reachabilityForLocalWiFi];
    if (reach.currentReachabilityStatus != ReachableViaWiFi) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"Wi-Fi is unavailable" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [self longConnectToSend];
}

- (void)disconnectTcp
{
    [self.sendTcpSocket disconnect];
    self.sendTcpSocket.delegate = nil;
}
- (void)reconnnectTCP
{
    self.sendTcpSocket.delegate = self;
    NSString *host = self.tfHost.text;
    uint16_t port = [self.tfPort.text intValue];
    NSError *error = nil;
    BOOL iRet = [self.sendTcpSocket connectToHost:host onPort:port error:&error];
    if (iRet) {
        NSLog(@"blind is Ok");
        [self setConnected:iRet];
    }
}
- (void)setConnected:(BOOL)connected
{
    _bRunning = connected;
    if (connected)
    {
        self.tfHost.enabled = NO;
        self.tfPort.enabled = NO;
        [self.connectBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
        [self.connectBtn setBackgroundColor:[UIColor greenColor]];
    }
    else
    {
        self.tfHost.enabled = YES;
        self.tfPort.enabled = YES;
        [self.connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
        [self.connectBtn setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)dealloc
{
    // 关闭套接字
    [self.sendTcpSocket disconnect];
    self.sendTcpSocket = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"netWork_connect_status" object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    NSString *ip = [Tool localWiFiIPAddress];
    self.labelIP.text = [NSString stringWithFormat:@"%@【update ip to touch】",[Tool localWiFiIPAddress]];
    self.tfHost.text = ip;
}
@end
