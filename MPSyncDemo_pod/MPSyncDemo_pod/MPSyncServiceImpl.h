//
//  MPSyncServiceImpl.h
//  POCDemo_comm
//
//  Created by shifei.wkp on 2019/1/145.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPSyncService /*<DTService>*/

- (void)setDidReceiveSyncDataCallback:(void(^)(NSDictionary *))block;
- (void)bindUser;
- (void)unbindUser;

@end

@interface MPSyncServiceImpl : NSObject <MPSyncService>

@end
