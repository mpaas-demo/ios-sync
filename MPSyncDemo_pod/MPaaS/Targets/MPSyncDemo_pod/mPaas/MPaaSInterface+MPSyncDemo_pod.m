//
//  MPaaSInterface+MPSyncDemo_pod.m
//  MPSyncDemo_pod
//
//  Created by yemingyu on 2019/03/25. All rights reserved.
//

#import "MPaaSInterface+MPSyncDemo_pod.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation MPaaSInterface (MPSyncDemo_pod)

- (BOOL)enableSettingService
{
    return NO;
}

- (NSString *)userId
{
    return @"MPTestCase";
}

@end

#pragma clang diagnostic pop

