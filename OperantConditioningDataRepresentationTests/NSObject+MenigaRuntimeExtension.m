//
//  NSObject+RuntimeExtension.m
//  MENIGAAutomaticJson
//
//  Created by Mathieu Grettir Skulason on 10/5/15.
//  Copyright © 2015 Mathieu Grettir Skulason. All rights reserved.
//

#import "NSObject+MenigaRuntimeExtension.h"
#import <objc/runtime.h>

@implementation NSObject (RuntimeExtension)

+(instancetype)initWithClass:(Class)theClass modelDictionary:(NSDictionary *)theDictionary error:(NSError **)theError {
    
    Class someClass = theClass;
    
    id object = [[[someClass class] alloc] init];
    
    for (NSString *key in theDictionary) {
        
        id value = theDictionary[key];
        [object c_validateAndSetValue:value propertyKey:key error:theError];
        
    }
    
    return object;
}

+(void)c_enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
    [block copy];
    
    Class someClass = self;
    BOOL stop = NO;
    
    // compare the class names as we do not want to serialize the properties for the NSObject
    while (stop == NO && someClass != nil && strcmp(object_getClassName([NSObject class]), object_getClassName(someClass)) != 0) {
        
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(someClass, &count);
                
        for (int i = 0; i < count; i++) {
            block(properties[i], &stop);

            if (stop) {
                break;
            }
        }
        
        someClass = [someClass superclass];
        
    }
}

-(void)c_validateAndSetValue:(id)theValue propertyKey:(NSString *)thePropertyKey error:(NSError **)theError {
    
    
    if (theValue != nil) {
        if (theValue == [NSNull null]) {
            [self setValue:nil forKey:thePropertyKey];
        }
        else {
            [self setValue:theValue forKey:thePropertyKey];
        }
    }
}

@end
