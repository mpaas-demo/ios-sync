//
//  MPSyncTestCase.h
//  MPSyncDemo
//
//  Created by yemingyu on 2019/2/15.
//  Copyright © 2019 alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPSyncTestCase : NSObject

/*
{
    "result": {
        "name": "alipay TestCase",
        "age": "20",
        "vipInfo": {
            "level": "102",
            "expireTime": "1532599846111"
        }
    },
    "tips": "ok",
    "resultStatus": 1000
}
*/
// MPTestCase

+ (void)runAllTestCase;

+ (void)testRegister;

+ (void)testUnRegister;

+ (void)testBindUser;

+ (void)testUnBindUser;

@end

NS_ASSUME_NONNULL_END
