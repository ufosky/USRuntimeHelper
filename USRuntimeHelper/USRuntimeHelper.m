//
//  USRuntimeHelper.m
//  USRuntimeHelper
//
//  Created by Qihe Bian on 9/25/14.
//  Copyright (c) 2014 ufosky.com. All rights reserved.
//

#import "USRuntimeHelper.h"

#include <objc/runtime.h>

static void US_invokeMethod(id obj, Method m, NSArray *arguments, void *returnValue) {
    char *returnType = method_copyReturnType(m);
    SEL sel = method_getName(m);
    if ([obj respondsToSelector:sel]) {
        NSMethodSignature *signature  = [obj methodSignatureForSelector:sel];
        NSInvocation      *invocation = [NSInvocation invocationWithMethodSignature:signature];
        unsigned int count = method_getNumberOfArguments(m);
        [invocation setTarget:obj];                    // index 0 (hidden)
        [invocation setSelector:sel];                  // index 1 (hidden)
        void **argLocs = malloc(sizeof(void *) * (count - 2));
        
        for (int i = 2; i < count; ++i) {
            int j = i - 2;
            id arg = [arguments objectAtIndex:j];
            char *argumentType = method_copyArgumentType(m, i);
            if (arg == [NSNull null]) {
                void *v = NULL;
                argLocs[j] = malloc(sizeof(v));
                memcpy(argLocs[j], &v, sizeof(v));
                [invocation setArgument:argLocs[j] atIndex:i];
                continue;
            }
            switch (*argumentType) {
                case '@': {
                    argLocs[j] = malloc(sizeof(arg));
                    memcpy(argLocs[j], (void*)(&arg), sizeof(arg));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 'B': {
                    NSNumber *num = (NSNumber *)arg;
                    bool v = [num boolValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 'c': {
                    NSNumber *num = (NSNumber *)arg;
                    char v = [num charValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 's': {
                    NSNumber *num = (NSNumber *)arg;
                    short v = [num shortValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 'i': {
                    NSNumber *num = (NSNumber *)arg;
                    int v = [num intValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 'l': {
                    NSNumber *num = (NSNumber *)arg;
                    long v = [num longValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 'q': {
                    NSNumber *num = (NSNumber *)arg;
                    long long v = [num longLongValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 'd': {
                    NSNumber *num = (NSNumber *)arg;
                    double v = [num doubleValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 'f': {
                    NSNumber *num = (NSNumber *)arg;
                    float v = [num floatValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 'C': {
                    NSNumber *num = (NSNumber *)arg;
                    unsigned char v = [num unsignedCharValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 'S': {
                    NSNumber *num = (NSNumber *)arg;
                    unsigned short v = [num unsignedShortValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 'I': {
                    NSNumber *num = (NSNumber *)arg;
                    unsigned int v = [num unsignedIntValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 'L': {
                    NSNumber *num = (NSNumber *)arg;
                    unsigned long v = [num unsignedLongValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case 'Q': {
                    NSNumber *num = (NSNumber *)arg;
                    unsigned long long v = [num unsignedLongLongValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                case '^': {
                    NSValue *value = (NSValue *)arg;
                    void *v = [value pointerValue];
                    argLocs[j] = malloc(sizeof(v));
                    memcpy(argLocs[j], (void*)&v, sizeof(v));
                    [invocation setArgument:argLocs[j] atIndex:i];
                }
                    break;
                default: {
                    argLocs[j] = NULL;
                }
                    break;
            }
            free(argumentType);
        }
        [invocation invoke];
        for (int i = 2; i < count; ++i) {
            int j = i - 2;
            if (argLocs[j]) {
                free(argLocs[j]);
            }
        }
        free(argLocs);
        if (returnValue) {
            switch (*returnType) {
                case 'v': {
                    memset(returnValue, 0, sizeof(void *));
                }
                    break;
                default: {
                    [invocation getReturnValue:returnValue];
                }
                    break;
            }
        }
    } else {
        if (returnValue) {
            memset(returnValue, 0, sizeof(void *));
        }
    }
    free(returnType);
}

void US_invokeInstanceMethod(id obj, NSString *selectorName, NSArray *arguments, void *returnValue) {
    SEL sel = NSSelectorFromString(selectorName);
    Method m = class_getInstanceMethod([obj class], sel);
    US_invokeMethod(obj, m, arguments, returnValue);
}

void US_invokeClassMethod(Class cls, NSString *selectorName, NSArray *arguments, void *returnValue) {
    SEL sel = NSSelectorFromString(selectorName);
    Method m = class_getClassMethod(cls, sel);
    US_invokeMethod(cls, m, arguments, returnValue);
}

void US_invokeClassMethodByName(NSString *className, NSString *selectorName, NSArray *arguments, void *returnValue) {
    Class cls = NSClassFromString(className);
    US_invokeClassMethod(cls, selectorName, arguments, returnValue);
}

void US_swizzleInstanceMethod(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig,
                       method_getImplementation(newMethod),
                       method_getTypeEncoding(newMethod))){
        class_replaceMethod(c, new,
                            method_getImplementation(origMethod),
                            method_getTypeEncoding(origMethod));
    }else{
        method_exchangeImplementations(origMethod, newMethod);
    }
}

void US_swizzleClassMethod(Class c, SEL orig, SEL new) {
    Method origMethod = class_getClassMethod(c, orig);
    Method newMethod = class_getClassMethod(c, new);
    c = object_getClass((id)c);
    if(class_addMethod(c, orig,
                       method_getImplementation(newMethod),
                       method_getTypeEncoding(newMethod))){
        class_replaceMethod(c, new,
                            method_getImplementation(origMethod),
                            method_getTypeEncoding(origMethod));
    }else{
        method_exchangeImplementations(origMethod, newMethod);
    }
}

void US_replaceClassMethod(Class c, SEL sel, SEL backup, IMP imp) {
  Class metac = object_getClass(c);
  SEL oldSel = sel;
  SEL newSel = backup;
  Method m = class_getClassMethod(metac, oldSel);
  NSMutableString *types = [[NSMutableString alloc] init];
  char buf[20];
  method_getReturnType(m, buf, sizeof(buf));
  [types appendFormat:@"%s", buf];
//  const char *typestr = method_getTypeEncoding(m);
  uint n = method_getNumberOfArguments(m);
  for (int i = 0; i < n; ++i) {
    method_getArgumentType(m, i, buf, sizeof(buf));
    [types appendFormat:@"%s", buf];
  }
  //ret,self,_cmd,args...
//  NSString *types = [NSString stringWithFormat:@"%s%@%s", @encode(BOOL), @"@:@@", "^"];
  BOOL success = class_addMethod(metac, newSel, imp, [types UTF8String]);
  US_swizzleClassMethod(c, oldSel, newSel);
}

void US_replaceInstanceMethod(Class c, SEL sel, SEL backup, IMP imp) {
  Class metac = c;
  SEL oldSel = sel;
  SEL newSel = backup;
  Method m = class_getInstanceMethod(metac, oldSel);
  NSMutableString *types = [[NSMutableString alloc] init];
  char buf[20];
  method_getReturnType(m, buf, sizeof(buf));
  [types appendFormat:@"%s", buf];
  //  const char *typestr = method_getTypeEncoding(m);
  uint n = method_getNumberOfArguments(m);
  for (int i = 0; i < n; ++i) {
    method_getArgumentType(m, i, buf, sizeof(buf));
    [types appendFormat:@"%s", buf];
  }
  //ret,self,_cmd,args...
  //  NSString *types = [NSString stringWithFormat:@"%s%@%s", @encode(BOOL), @"@:@@", "^"];
  BOOL success = class_addMethod(metac, newSel, imp, [types UTF8String]);
  US_swizzleInstanceMethod(c, oldSel, newSel);
}
