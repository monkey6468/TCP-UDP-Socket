//
//  Common.m
//  UDPBroadCast_Send
//
//  Created by ST on 16/6/13.
//  Copyright © 2016年 XWH. All rights reserved.
//

#import "Common.h"
#import "Reachability.h"

@implementation Common
+ (BOOL)isConnectionAvailable
{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            NSLog(@"3G");
            break;
    }
    return isExistenceNetwork;
    
}
@end
