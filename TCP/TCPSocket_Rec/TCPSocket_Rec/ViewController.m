//
//  ViewController.m
//  TCPSocket_Rec
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
@property (strong, nonatomic) GCDAsyncSocket *serverSocket;
@property (strong, nonatomic) NSMutableArray *allClientArray;
@property (weak, nonatomic) IBOutlet UILabel *labelIP;
@property (weak, nonatomic) IBOutlet UITextField *tfPort;
@property (weak, nonatomic) IBOutlet UIButton *btnConect;
@property (weak, nonatomic) IBOutlet UITextView *tvRec;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.labelIP.text = [Tool localWiFiIPAddress];
    self.allClientArray = [NSMutableArray array];
    
    dispatch_queue_t dQueue = dispatch_queue_create("My socket queue", NULL);
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    self.navigationItem.title = @"TCP Rec";

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

- (IBAction)onBtnConnect:(id)sender {
    Reachability *reach = [Reachability reachabilityForLocalWiFi];
    if (reach.currentReachabilityStatus != ReachableViaWiFi) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"Wi-Fi is unavailable" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (_bRunning) {
        [self disconnectTcp];
    }else {
        [self reconnnectTCP];
    }
}
- (void)disconnectTcp
{
    [self.serverSocket disconnect];
    self.serverSocket.delegate = nil;
    [self setConnected:NO];
}
- (void)reconnnectTCP
{
    NSError *err;
    self.serverSocket.delegate = self;
    BOOL b = [self.serverSocket acceptOnPort:[self.tfPort.text intValue] error:&err];
    if (b) {
        NSLog(@"blind is Ok");
        [self setConnected:YES];
    }
}
#pragma mark - 代理方法 接收到一个请求
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSString *ip = [newSocket connectedHost];
    uint16_t port = [newSocket connectedPort];

    [self.allClientArray addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:200];
    NSString *s = [NSString stringWithFormat:@"IP:%@,PORT:%d  connected:%lu!",ip,port,(unsigned long)self.allClientArray.count];
    NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
    [newSocket writeData:data withTimeout:60 tag:300];
    
    NSString *strDidnew = [NSString stringWithFormat:@"new socket IP: %@, Port: %d ,count:%lu", ip, port,(unsigned long)self.allClientArray.count];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tvRec.text = strDidnew;
    });
}
#pragma mark - 接收到数据代理函数
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *ip = [sock connectedHost];
    uint16_t port = [sock connectedPort];
    
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"接收到tcp [%@:%d] %@", ip, port, s);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tvRec.text = [NSString stringWithFormat:@"IP:%@,PORT:%d  connected:%lu ,context:%@",ip,port,(unsigned long)self.allClientArray.count ,s];
    });
    NSString *s2 = [NSString stringWithFormat:@"你发的数据是:%@", s];
    NSData *databack = [s2 dataUsingEncoding:NSUTF8StringEncoding];
    [sock writeData:databack withTimeout:60 tag:400];
    
    [sock readDataWithTimeout:-1 tag:200];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (err) {
        [self.allClientArray removeObject:sock];
    }else{
        [self.allClientArray removeAllObjects];
        [self.serverSocket disconnect];
        self.serverSocket.delegate = nil;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tvRec.text = [NSString stringWithFormat:@"失去连接 %lu ,err:%@", (unsigned long)self.allClientArray.count,err];
    });
}

- (void)setConnected:(BOOL)connected
{
    _bRunning = connected;
    if (connected)
    {
        self.tfPort.enabled = NO;
        [self.btnConect setTitle:@"Disconnect" forState:UIControlStateNormal];
        [self.btnConect setBackgroundColor:[UIColor greenColor]];
    }
    else
    {
        self.tfPort.enabled = YES;
        [self.btnConect setTitle:@"Connect" forState:UIControlStateNormal];
        [self.btnConect setBackgroundColor:[UIColor whiteColor]];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    self.labelIP.text = [Tool localWiFiIPAddress];
}

- (void)dealloc
{
    [self.serverSocket disconnect];
    self.serverSocket = nil;

    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"netWork_connect_status" object:nil];
}
@end
