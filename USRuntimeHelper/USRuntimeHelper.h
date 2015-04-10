//
//  USRuntimeHelper.h
//  USRuntimeHelper
//
//  Created by Qihe Bian on 9/25/14.
//  Copyright (c) 2014 ufosky.com. All rights reserved.
//

#import <Foundation/Foundation.h>

void US_invokeInstanceMethod(id obj, NSString *selectorName, NSArray *arguments, void *returnValue);
void US_invokeClassMethod(Class cls, NSString *selectorName, NSArray *arguments, void *returnValue);
void US_invokeClassMethodByName(NSString *className, NSString *selectorName, NSArray *arguments, void *returnValue);
void US_swizzleInstanceMethod(Class c, SEL orig, SEL new);
void US_swizzleClassMethod(Class c, SEL orig, SEL new);
void US_replaceClassMethod(Class c, SEL sel, SEL backup, IMP imp);
void US_replaceInstanceMethod(Class c, SEL sel, SEL backup, IMP imp);
