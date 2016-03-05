//
//  NSObject+RuntimeExtension.h
//  MENIGAAutomaticJson
//
//  Created by Mathieu Grettir Skulason on 10/5/15.
//  Copyright © 2015 Mathieu Grettir Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (MenigaRuntimeExtension)

/** Instantiates an object of any class type with a dictionary of values. */
+(instancetype)initWithClass:(Class)theClass modelDictionary:(NSDictionary *)theDictionary error:(NSError **)theError;

/** Returns all the objective-c runtiem properties associated with the class. The Stop variable is used to stop the enumeration of the object. */
+(void)c_enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block;

/** Checks the value is nil and sets the property to Null in that case. No other checks are currently done in this method. Used to populate the objects properties in the convenience method initWithModelDictionary: . */
-(void)c_validateAndSetValue:(id)theValue propertyKey:(NSString *)thePropertyKey error:(NSError **)theError;

@end
