//
//  ViewController.m
//  UDPSocket_Rec
//
//  Created by ST on 16/5/19.
//  Copyright © 2016年 XWH. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "Tool.h"

@interface ViewController ()
{
    BOOL _bRunning;
}
@property (strong, nonatomic) GCDAsyncUdpSocket *asyncSocket;

@property (weak, nonatomic) IBOutlet UILabel *labelIP;
@property (weak, nonatomic) IBOutlet UITextField *textPort;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (weak, nonatomic) IBOutlet UITextView *tvRecv;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.labelIP.text = [Tool localWiFiIPAddress];
    self.asyncSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.navigationItem.title = @"UDP Rec";
}

- (IBAction)onBtnConnect:(UIButton *)sender {
    if (_bRunning)
    {
        [self.asyncSocket close];
        [self setConnected:NO];
    }
    else
    {
        if (self.textPort.text == nil) return;
        if ([self.asyncSocket bindToPort:[self.textPort.text intValue] error:nil])
        {
            [self.asyncSocket beginReceiving:nil];
            NSLog(@"blind is Ok");
            [self setConnected:YES];
        }
    }
}
- (void)setConnected:(BOOL)connected
{
    _bRunning = connected;
    if (connected)
    {
        [self.btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
        [self.btnConnect setBackgroundColor:[UIColor greenColor]];
    }
    else
    {
        [self.btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
        [self.btnConnect setBackgroundColor:[UIColor whiteColor]];
    }
}

#pragma mark Socket Delegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"接收到tcp [%@:%d] %@", host, port, s);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tvRecv.text = s;
    });
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    self.labelIP.text = [Tool localWiFiIPAddress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
