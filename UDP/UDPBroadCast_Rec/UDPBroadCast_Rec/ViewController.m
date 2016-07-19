//
//  ViewController.m
//  UDPBroadCast_Rec
//
//  Created by 肖伟华 on 16/6/10.
//  Copyright © 2016年 XWH. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
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
    [self initUDP];

//    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(postIPAddress2Register) userInfo:nil repeats:YES];
}
- (BOOL)initUDP
{
    NSError *error = nil;
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    [self.udpSocket enableBroadcast:YES error:&error];if (error) {return NO;}
    [self.udpSocket bindToPort:PORT error:&error];if (error) {return NO;}
    [self.udpSocket beginReceiving:&error];if (error) {return NO;}
    [self.udpSocket joinMulticastGroup:GROUP error:&error];if (error) {return NO;}

    return YES;
}

#pragma mark
#pragma mark UDP Socket

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
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"%@",error);
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.labelLocalWifiIP.text = [Tool localWiFiIPAddress];
    self.labelRecIP.text = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
