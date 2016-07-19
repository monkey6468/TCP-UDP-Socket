//
//  Tool.m
//  UDPSocket_Rec
//
//  Created by ST on 16/5/20.
//  Copyright © 2016年 XWH. All rights reserved.
//

#import "Tool.h"
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>

@implementation Tool

#pragma mark - get device wifi IP

+ (NSString *)localWiFiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}
@end
