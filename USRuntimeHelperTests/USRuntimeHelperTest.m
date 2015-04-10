//
//  USRuntimeHelperTest.m
//  USRuntimeHelper
//
//  Created by Qihe Bian on 9/25/14.
//  Copyright (c) 2014 ufosky.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "USRuntimeHelper.h"
#import <objc/runtime.h>

static NSDictionary *unserializeJSONP(id self, SEL _cmd, NSString *jsonp) {
    NSLog(@"%s jsonp:%@", __PRETTY_FUNCTION__, jsonp);
    NSMutableArray *args = [NSMutableArray array];
    id v = jsonp;
    if (!v) {
        v = [NSNull null];
    }
    [args addObject:v];
    void *buf;
    US_invokeClassMethod([self class], @"_unserializeJSONP:", args, &buf);
    NSDictionary *result = (__bridge id)buf;
    return result;
}

static NSDate *expireDateWithOffset(id self, SEL _cmd, NSInteger offset) {
    NSLog(@"%s offset:%ld", __PRETTY_FUNCTION__, (long)offset);
    NSMutableArray *args = [NSMutableArray array];
    NSNumber *v = [NSNumber numberWithInteger:offset];
    [args addObject:v];
    void *buf;
    US_invokeClassMethod([self class], @"_expireDateWithOffset:", args, &buf);
    NSDate *result = (__bridge id)buf;
    return result;
}

static int aintmethod(id self, SEL _cmd, int *a) {
    NSLog(@"%s a:%d", __PRETTY_FUNCTION__, *a);
    NSMutableArray *args = [NSMutableArray array];
    NSValue *v = [NSValue valueWithPointer:a];
    [args addObject:v];
    int result;
    US_invokeInstanceMethod(self, @"_aintmethod:", args, &result);
    return result;
}

static int *pointerResult(id self, SEL _cmd) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSMutableArray *args = [NSMutableArray array];
    int *result;
    US_invokeInstanceMethod(self, @"_pointerResult", args, &result);
    return result;

}
@interface USRuntimeHelperTest : XCTestCase

@end

@implementation USRuntimeHelperTest

+ (NSDictionary *)unserializeJSONP:(NSString *)jsonp {
    NSRange begin = [jsonp rangeOfString:@"(" options:NSLiteralSearch];
    NSRange end = [jsonp rangeOfString:@")" options:NSBackwardsSearch|NSLiteralSearch];
    BOOL parseFail = (begin.location == NSNotFound || end.location == NSNotFound || end.location - begin.location < 2);
    if (!parseFail)
    {
        NSString *json = [jsonp substringWithRange:NSMakeRange(begin.location + 1, (end.location - begin.location) - 1)];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:NULL];
        return dict;
    } else {
        return nil;
    }
}

+(NSDate*)expireDateWithOffset:(NSInteger)offset{
    //加上网络延迟的冗余
    offset-=20;
    
    NSDate *date=[NSDate dateWithTimeIntervalSinceNow:offset];
    return date;
}

+ (void)load {
  {
    SEL sel = NSSelectorFromString(@"unserializeJSONP:");
    SEL backup = NSSelectorFromString(@"_unserializeJSONP:");
    
    US_replaceClassMethod(self, sel, backup, (IMP)unserializeJSONP);
  }
  {
    SEL sel = NSSelectorFromString(@"expireDateWithOffset:");
    SEL backup = NSSelectorFromString(@"_expireDateWithOffset:");
    
    US_replaceClassMethod(self, sel, backup, (IMP)expireDateWithOffset);
  }
  {
    SEL sel = NSSelectorFromString(@"aintmethod:");
    SEL backup = NSSelectorFromString(@"_aintmethod:");
    
    US_replaceInstanceMethod(self, sel, backup, (IMP)aintmethod);
  }
  {
    SEL sel = NSSelectorFromString(@"pointerResult");
    SEL backup = NSSelectorFromString(@"_pointerResult");
    
    US_replaceInstanceMethod(self, sel, backup, (IMP)pointerResult);
  }
}

- (int)aintmethod:(int *)a {
    int result = *a * *a + 2;
    *a = 10000;
    return result;
}

- (int *)pointerResult {
    int *a = (int *)malloc(sizeof(int));
    *a = 18;
    return a;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSString *jsonp = @"callback( {\"client_id\":\"11111\",\"openid\":\"abcd\"} );";
    NSDictionary *dict = [[self class] unserializeJSONP:jsonp];
    NSLog(@"dict:%@", dict);
    XCTAssertEqual(dict.allKeys.count, 2);
    XCTAssertEqualObjects([dict objectForKey:@"client_id"], @"11111");
    XCTAssertEqualObjects([dict objectForKey:@"openid"], @"abcd");
    
    
    NSDate *date = [[self class] expireDateWithOffset:10000];
    NSLog(@"date:%@", date);
    
    int a = 8;
    int b = [self aintmethod:&a];
    NSLog(@"a:%d b:%d", a, b);
    XCTAssertEqual(a, 10000);
    XCTAssertEqual(b, 66);
    
    int *s = [self pointerResult];
    XCTAssertEqual(*s, 18);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
