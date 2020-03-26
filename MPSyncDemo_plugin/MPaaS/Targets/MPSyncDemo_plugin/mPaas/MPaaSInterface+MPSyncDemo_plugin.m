//
//  MPaaSInterface+MPSyncDemo_plugin.m
//  MPSyncDemo_plugin
//
//  Created by 夜禹 on 2019/03/26.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "MPaaSInterface+MPSyncDemo_plugin.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation MPaaSInterface (MPSyncDemo_plugin)

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
