//
//  MPSyncTestCase.m
//  MPSyncDemo
//
//  Created by yemingyu on 2019/2/15.
//  Copyright © 2019 alipay. All rights reserved.
//

#import "MPSyncTestCase.h"
#import <APLongLinkService/DTSyncInterface.h>
#import <MPMssAdapter/MPSyncInterface.h>
#import <mPaas/MPJSONKit.h>

#define SingleDeviceSync @"Single-Device-Sync"
#define GlobalDeviceSync @"Global-Device-Sync"
#define SingleUserSync @"Single-User-Sync"
#define GlobalUserSync @"Global-User-Sync"
#define GlobalUserSyncSession @"Global-User-Sync-Session"

@implementation MPSyncTestCase

+ (instancetype)sharedInstance
{
    static MPSyncTestCase *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MPSyncTestCase alloc] init];
    });
    return instance;
}

- (void)dealloc
{
    [MPSyncInterface removeSyncNotificationObserver:self];
}

+ (void)runAllTestCase
{
    // TODO: meta.config 加到工程中才行
    [self testUrlAddressConfig];

    // syncinit 后检测 connectStatus 是连接上的才对
    [self testInitSync];
    
//    [self testRegister];
    //  设备推 sync 包括指定和全局
//    [[MPSyncTestCase sharedInstance] testDeviceSync];
    
    //  用户Id推 sync 包括指定和全局
//    [[MPSyncTestCase sharedInstance] testUserSync];
    
    [self testDeviceId];
    
    // 手动操作: unRegister
    // 手动操作: Bind
    // 手动操作: UnBind
    
    // 其余都是服务端用例
}

#pragma mark - 检测 sync 配置

+ (void)testUrlAddressConfig
{
    // 读取 meta.config 然后和接口读出来的做对比
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"meta" ofType:@"config"];
    NSString *metaConfig = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //    NSDictionary *metaConfig = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
    NSData *jsonData = [metaConfig dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    NSString *appId = [dic objectForKey:@"appId"];
    NSString *appKey = [dic objectForKey:@"appKey"];
    NSString *workspaceId = [dic objectForKey:@"workspaceId"];
    NSString *syncserver = [dic objectForKey:@"syncserver"];
    NSString *syncport = [dic objectForKey:@"syncport"];
    
    NSString *sync_appId = [[DTSyncInterface sharedInstance] appId];
    NSString *sync_platform = [[DTSyncInterface sharedInstance] platform];
    NSString *sync_workspaceId = [[DTSyncInterface sharedInstance] workspaceId];
    NSString *sync_syncServer = [[DTSyncInterface sharedInstance] syncServer];
    int sync_syncPort = [[DTSyncInterface sharedInstance] syncPort];
    NSString *sync_appKey = [NSString stringWithFormat:@"%@_%@", sync_appId, sync_platform];
    
    assert([appId isEqualToString:sync_appId]);
    MPAdapterLog(@"MPAdapter", @"Sync", @"%@", @"Sync AppId 检测通过");
    assert([appKey isEqualToString:sync_appKey]);
    MPAdapterLog(@"MPAdapter", @"Sync", @"%@", @"Platform 检测通过");
    assert([workspaceId isEqualToString:sync_workspaceId]);
    MPAdapterLog(@"MPAdapter", @"Sync", @"%@", @"workspaceId 检测通过");
    assert([syncserver isEqualToString:sync_syncServer]);
    MPAdapterLog(@"MPAdapter", @"Sync", @"%@", @"syncserver 检测通过");
    assert([syncport intValue] == sync_syncPort);
    MPAdapterLog(@"MPAdapter", @"Sync", @"%@", @"syncport 检测通过");
}

+ (void)testInitSync
{
    [MPSyncInterface initSync];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MPSyncNetConnectType connectStatus = [MPSyncInterface connectStatus];
        assert(connectStatus == MPSyncNetConnectTypeConnected);
        MPAdapterLog(@"MPAdapter", @"Sync", @"%@", @"Sync初始化 连接成功 检测通过");
    });

}

+ (void)testDeviceId
{
    NSString *deviceId = [MPSyncInterface getSyncDeviceId];
    NSString *deviceId_again = [MPSyncInterface getSyncDeviceId];
    assert([deviceId isEqualToString:deviceId_again]);
    MPAdapterLog(@"MPAdapter", @"Sync", @"%@", @"DeviceId 保持不变 检测通过");
    MPAdapterLog(@"MPAdapter", @"Sync", @"%@: %@", @"DeviceId 为 ", deviceId);
}

- (BOOL)testDeviceSync
{
    BOOL registerSingleDeviceSync = [MPSyncInterface registerSyncBizWithName:SingleDeviceSync syncObserver:self selector:@selector(testRevSyncBizNotification:)];
    BOOL registerGlobalDeviceSync = [MPSyncInterface registerSyncBizWithName:GlobalDeviceSync syncObserver:self selector:@selector(testRevSyncBizNotification:)];

    // 测试用户一致性，正常应该收不到，除非 session 是正确配置
    BOOL registerGlobalUserSyncSession = [MPSyncInterface registerSyncBizWithName:GlobalUserSyncSession syncObserver:self selector:@selector(testRevSyncBizNotification:)];
    
    assert(registerSingleDeviceSync && registerGlobalDeviceSync && registerGlobalUserSyncSession);
    return registerSingleDeviceSync && registerGlobalDeviceSync && registerGlobalUserSyncSession;
}

- (BOOL)testUserSync
{
    BOOL registerSingleUserSync = [MPSyncInterface registerSyncBizWithName:SingleUserSync syncObserver:self selector:@selector(testRevSyncBizNotification:)];
    BOOL registerGlobalUserSync = [MPSyncInterface registerSyncBizWithName:GlobalUserSync syncObserver:self selector:@selector(testRevSyncBizNotification:)];
    assert(registerSingleUserSync && registerGlobalUserSync);
    return registerSingleUserSync && registerGlobalUserSync;
}

+ (void)testRegister
{
    //  设备推 sync 包括指定和全局
    BOOL registerDeviceSync = [[MPSyncTestCase sharedInstance] testDeviceSync];
    assert(registerDeviceSync);
    MPAdapterLog(@"MPAdapter", @"Sync", @"%@", @"Sync注册设备 检测通过");
    
    //  用户Id推 sync 包括指定和全局
    BOOL registerUserSync = [[MPSyncTestCase sharedInstance] testUserSync];
    assert(registerUserSync);
    
    MPAdapterLog(@"MPAdapter", @"Sync", @"%@", @"Sync注册User 检测通过");
}

+ (void)testUnRegister
{
    BOOL unRegisterSingleDeviceSync = [MPSyncInterface unRegisterSyncBizWithName:SingleDeviceSync syncObserver:[MPSyncTestCase sharedInstance]];
    BOOL unRegisterGlobalDeviceSync = [MPSyncInterface unRegisterSyncBizWithName:GlobalDeviceSync syncObserver:[MPSyncTestCase sharedInstance]];
    BOOL unRegisterSingleUserSync = [MPSyncInterface unRegisterSyncBizWithName:SingleUserSync syncObserver:[MPSyncTestCase sharedInstance]];
    BOOL unRegisterGlobalUserSync = [MPSyncInterface unRegisterSyncBizWithName:GlobalUserSync syncObserver:[MPSyncTestCase sharedInstance]];
    assert(unRegisterSingleDeviceSync && unRegisterGlobalDeviceSync && unRegisterSingleUserSync && unRegisterGlobalUserSync);
    MPAdapterLog(@"MPAdapter", @"Sync", @"%@", @"Sync去除注册 检测通过");
}

+ (void)testBindUser
{
    [MPSyncInterface bindUserWithSessionId:@"SESSION_DEMO"];
    MPAdapterLog(@"MPAdapter", @"Sync", @"%@", @"Sync Bind 用户 MPTestCase 和 SESSION_DEMO 完成");
}

+ (void)testUnBindUser
{
    [MPSyncInterface unBindUser];
    MPAdapterLog(@"MPAdapter", @"Sync", @"%@", @"Sync unBind 用户完成");
}

- (void)testRevSyncBizNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
//    NSLog(@"===Sync:%@", userInfo);
    dispatch_async(dispatch_get_main_queue(), ^{
        //业务数据处理
        AUNoticeDialog *alert = [[AUNoticeDialog alloc] initWithTitle:@"接收数据" message:[userInfo JSONString_mp] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        //回调 SyncSDK，表示业务数据已经处理
        [MPSyncInterface responseMessageNotify:userInfo];
    });
}

#pragma mark - MPLog

static void MPAdapterLog(NSString *tag, NSString *componentTag, NSString *format, ...)
{
    if (format == nil) {
        return;
    }
    
    va_list args;
    va_start(args, format);
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSString *formatString = [[NSString alloc] initWithFormat:@"[%@][%@]: %@",
                              tag,
                              componentTag,
                              logString];
#if DEBUG
    NSLog(@"%@", formatString);
#endif
}

@end
