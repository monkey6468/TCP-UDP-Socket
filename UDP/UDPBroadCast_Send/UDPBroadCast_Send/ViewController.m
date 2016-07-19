//
//  ViewController.m
//  UDPBroadCast_Send
//
//  Created by 肖伟华 on 16/6/10.
//  Copyright © 2016年 XWH. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "Common.h"
#import "Tool.h"

#define HOST @"255.255.255.255"
#define GROUP @"224.0.0.1"
#define PORT  5858

@interface ViewController ()<GCDAsyncUdpSocketDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelLocalWifiIP;
@property (weak, nonatomic) IBOutlet UILabel *labelRecIP;
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.labelLocalWifiIP.text = [Tool localWiFiIPAddress];
    self.udpSocket = [self setupUDP];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(postIPAddress2Register) userInfo:nil repeats:YES];
}
#pragma mark
#pragma mark Timer

- (void)postIPAddress2Register
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (![Common isConnectionAvailable])
        {
            [_udpSocket close];
            _udpSocket.delegate = nil;
            _udpSocket = nil;
            return;
        }
        
        if (!self.udpSocket)
        {
            self.udpSocket = [self setupUDP];
        }
        
        [self.udpSocket sendData:[[Common localWiFiIPAddress] dataUsingEncoding:NSUTF8StringEncoding] toHost:HOST port:PORT withTimeout:-1 tag:1];
    });
}
- (GCDAsyncUdpSocket *)setupUDP
{
    NSError *error = nil;
    GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    if (![socket bindToPort:PORT error:&error]) {return nil;}
    if (![socket enableBroadcast:YES error:&error]) {return nil;}
    if (![socket beginReceiving:&error]) {[socket close];return nil;}
    if (![socket joinMulticastGroup:GROUP  error:&error]) {return nil;}
    
    return socket;
}

#pragma mark
#pragma mark Udp Socket

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"Message didConnectToAddress: %@",[[NSString alloc]initWithData:address encoding:NSUTF8StringEncoding]);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    NSLog(@"Message didNotConnect: %@",error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"Message didNotSendDataWithTag: %@",error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *receive = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelRecIP.text = receive;
    });
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"Message didSendDataWithTag");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"Message withError: %@",error);
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.labelLocalWifiIP.text = [Tool localWiFiIPAddress];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
