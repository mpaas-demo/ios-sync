//
//  MPSyncServiceImpl.m
//  POCDemo_comm
//
//  Created by shifei.wkp on 2019/1/145.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "MPSyncServiceImpl.h"
#import <mPaas/MPaaSInterface.h>

@interface MPSyncServiceImpl ()

@property (nonatomic, copy) void(^didReceiveSyncDataCallback)(NSDictionary *);

@end

@implementation MPSyncServiceImpl

- (void)setDidReceiveSyncDataCallback:(void (^)(NSDictionary *))block {
    _didReceiveSyncDataCallback = block;
}

- (void)start {
    [DTLongLinkBusiness syncInit];
    [self registerSyncBiz];
    [self bindUser];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)bindUser {
    NSString *userId = [MPaaSInterface sharedInstance].userId;
    if (userId.length > 0) {
        [DTLongLinkBusiness sendBindUser:userId sessionId:@"SESSION_DEMO"];
    }
}

- (void)unbindUser {
    [DTLongLinkBusiness sendUnBindUser];
}

// 注册业务标识
- (void)registerSyncBiz {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(revSyncBizNotification:) name:@"deviceSync" object:nil];
    [DTLongLinkBusiness hasRegisterNotificationWithBiz:@"deviceSync"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(revSyncBizNotification:) name:@"uidSync" object:nil];
    [DTLongLinkBusiness hasRegisterNotificationWithBiz:@"uidSync"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(revSyncBizNotification:) name:@"quanfaTest" object:nil];
    [DTLongLinkBusiness hasRegisterNotificationWithBiz:@"quanfaTest"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(revSyncBizNotification:) name:@"quanjuDevice" object:nil];
    [DTLongLinkBusiness hasRegisterNotificationWithBiz:@"quanjuDevice"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(revSyncBizNotification:) name:@"UCHAT" object:nil];
    [DTLongLinkBusiness hasRegisterNotificationWithBiz:@"UCHAT"];
    
}

- (void)revSyncBizNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"===Sync:%@", userInfo);
    dispatch_async(dispatch_get_main_queue(), ^{
        //业务数据处理
        if (self.didReceiveSyncDataCallback) {
            self.didReceiveSyncDataCallback(userInfo);
        }
        //回调 SyncSDK，表示业务数据已经处理
        [DTLongLinkBusiness responseMessageNotify:userInfo];
    });
}

@end
