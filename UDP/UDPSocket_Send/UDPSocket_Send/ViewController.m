//
//  ViewController.m
//  UDPSocket_Send
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
@property (weak, nonatomic) IBOutlet UITextField *txfPeerIP;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UITextField *txfSend;
@property (weak, nonatomic) IBOutlet UITextView *txvRecv;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.labelIP.text = [Tool localWiFiIPAddress];
    self.asyncSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.navigationItem.title = @"UDP Send";
}

- (IBAction)btnConnect_Action:(UIButton *)sender {
    if (_bRunning)
    {
        [self.asyncSocket close];
        [self setConnected:NO];
    }
    else
    {
        if (!self.txfPeerIP.text || !self.textPort.text) return;
        if ([self.asyncSocket connectToHost:self.txfPeerIP.text onPort:[self.textPort.text intValue] error:nil])
        {
            NSLog(@"UDP connectToHost is ok");
            [self setConnected:YES];
        }
    }

}
- (IBAction)btnSend_Action:(UIButton *)sender {
    if (self.txfSend.text && _bRunning) {
        NSData *data = [self.txfSend.text dataUsingEncoding:NSUTF8StringEncoding];
        [self.asyncSocket sendData:data withTimeout:-1 tag:-1];
        self.txfSend.text = @"";
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

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    self.labelIP.text = [Tool localWiFiIPAddress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
