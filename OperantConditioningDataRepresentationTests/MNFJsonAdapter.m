//
//  MENIGAAutomaticSerializer.m
//  MENIGAAutomaticJson
//
//  Created by Mathieu Grettir Skulason on 10/5/15.
//  Copyright © 2015 Mathieu Grettir Skulason. All rights reserved.
//

#import "MNFJsonAdapter.h"
#import "NSObject+MenigaRuntimeExtension.h"
#import "NSString+MNFExtension.h"

static NSString *JsonAdapterDomain = @"com.Meniga.JsonAdapter";

@implementation MNFJsonAdapter

#pragma mark - Public Deserialization Methods

+(id)objectOfClass:(Class)theClass jsonDict:(NSDictionary *)theJsonDict option:(MNFAdapterOption)theAdapterOptions error:(NSError *__autoreleasing *)theError {
    
    MNFJsonAdapter *tmpSerializer = [[[self class] alloc] init];
    
    return [tmpSerializer p_createInstanceFromClass:theClass jsonDict:theJsonDict propertyKeys:[tmpSerializer p_propertyKeysForClass:theClass option:theAdapterOptions error:theError]];
    
}

+(NSArray *)objectsOfClass:(Class)theClass jsonArray:(NSArray *)theJsonArray option:(MNFAdapterOption)theAdapterOptions error:(NSError *__autoreleasing *)theError {
    
    MNFJsonAdapter *tmpSerializer = [[[self class] alloc] init];
    
    return [tmpSerializer p_createInstancesForClass:theClass jsonArray:theJsonArray propertyKeys:[tmpSerializer p_propertyKeysForClass:theClass option:theAdapterOptions error:theError]];
}

+(void)refreshObject:(NSObject <MNFJsonAdapterDelegate> *)theModel withJsonDict:(NSDictionary *)theJsonDict option:(MNFAdapterOption)theAdapterOption error:(NSError *__autoreleasing *)theError {
    MNFJsonAdapter *tmpSerializer = [[[self class] alloc] init];
    
    [tmpSerializer p_refreshInstance:theModel jsonDict:theJsonDict propertyKeys:[tmpSerializer p_propertyKeysForClass:[theModel class] option:theAdapterOption error:theError] error:theError];
}

#pragma mark - Create the property list for the deserialization

-(NSDictionary *)p_propertyKeysForClass:(Class)theClass option:(MNFAdapterOption)theOption error:(NSError **)theError {
    
    // get all the property keys for the given class
    NSDictionary *propertyKeys = [self p_propertyKeyDictionaryAssociatedWithClass:theClass error:theError];
    
    
    // check if the class conforms to the serializer protocol to map values
    // or exclude values from the json
    
    id<MNFJsonAdapterDelegate> delegate = [[theClass alloc] init];
    
    if ([delegate respondsToSelector:@selector(propertiesToDeserialize)]) {
        propertyKeys = [self p_propertyDictFromSet:[delegate propertiesToDeserialize]];
    }
    else if ([delegate respondsToSelector:@selector(propertiesToIgnoreJsonDeserialization)]) {
        if ([delegate propertiesToIgnoreJsonDeserialization] != nil) {
            propertyKeys = [self p_removeIgnoredPropertiesInDictionary:propertyKeys ignoredProperties:[delegate propertiesToIgnoreJsonDeserialization] error:theError];
        }
    }
    
    if ([delegate respondsToSelector:@selector(jsonKeysMapToProperties)]) {
        if ([delegate jsonKeysMapToProperties] != nil) {
            propertyKeys = [self p_mapPropertyDictionaryKeys:propertyKeys mapDictionary:[delegate jsonKeysMapToProperties] error:theError];
        }
    }
    
    propertyKeys = [self p_updateOnlyDictionaryKeys:propertyKeys option:theOption];
    
    
    return propertyKeys;
    
}


#pragma mark - Private Inititalizers

-(NSArray *)p_createInstancesForClass:(Class)theClass jsonArray:(NSArray *)theJsonArray propertyKeys:(NSDictionary *)thePropertyKeys {
    
    NSMutableArray *arr = [NSMutableArray array];
    
    
    for (NSDictionary *dict in theJsonArray) {
        [arr addObject:[self p_createInstanceFromClass:theClass jsonDict:dict propertyKeys:thePropertyKeys]];
    }
    
    return arr;
}

-(id)p_createInstanceFromClass:(Class)theClass jsonDict:(NSDictionary *)theJsonDict propertyKeys:(NSDictionary *)thePropertyKeys {
    
    id <MNFJsonAdapterDelegate> delegate = [[theClass alloc] init];
    
    NSDictionary *dictionary = [[self class] p_createModelDictionaryWithModel:delegate jsonDict:theJsonDict propertyKeys:thePropertyKeys];
    
    
    id createdObject = [NSObject initWithClass:theClass modelDictionary:dictionary error:nil];
    
    return createdObject;
}
-(void)p_refreshInstance:(NSObject<MNFJsonAdapterDelegate> *)theModel jsonDict:(NSDictionary *)theJsonDict propertyKeys:(NSDictionary *)thePropertyKeys error:(NSError **)theError {
    
    NSDictionary *dictionary = [[self class] p_createModelDictionaryWithModel:theModel jsonDict:theJsonDict propertyKeys:thePropertyKeys];
    
    for (NSString *key in dictionary) {
        id value = dictionary[key];
        [theModel c_validateAndSetValue:value propertyKey:key error:theError];
    }
}
+(NSDictionary*)p_createModelDictionaryWithModel:(id)theModel jsonDict:(NSDictionary*)theJsonDict propertyKeys:(NSDictionary*)thePropertyKeys {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    
    NSDictionary *transformedDict = nil;
    
    if ([theModel respondsToSelector:@selector(propertyValueTransformers)]) {
        transformedDict = [theModel propertyValueTransformers];
    }
    
    for (NSString *jsonKey in theJsonDict) {
        
        id propertyName = [thePropertyKeys objectForKey:jsonKey];
        id jsonValue = theJsonDict[jsonKey];
        
        // check if the property exist
        if (propertyName != nil) {
            
            if (transformedDict != nil && [transformedDict objectForKey:propertyName] != nil && [[transformedDict objectForKey:propertyName] isKindOfClass:[NSValueTransformer class]] == YES) {
                NSValueTransformer *transformer = [transformedDict objectForKey:propertyName];
                jsonValue = [transformer transformedValue:jsonValue];
            }
            
            // get the json value and set it on the corresponding mapped or non mapped key
            // which will then be set on the object the key corresponds to the variable name.
            [mutableDictionary setObject:jsonValue forKey:propertyName];
            
        }
    }
    
    return [mutableDictionary copy];
}



#pragma mark - Public Serialization for objects

+(NSArray *)JSONArrayFromArray:(NSArray *)theModels option:(MNFAdapterOption)theAdapterOption error:(NSError *__autoreleasing *)theError {
    
    MNFJsonAdapter *automaticSerializer = [[MNFJsonAdapter alloc] init];
    
    NSDictionary *propertyKeys = [automaticSerializer p_createPropertyKeyDictionaryForObject:[theModels firstObject] option:theAdapterOption error:theError];
    
    NSMutableArray *jsonDictArray = [NSMutableArray array];
    
    for (id object in theModels) {
        NSDictionary *jsonDict = [automaticSerializer p_createPeropertyValueDictionaryForObject:object propertyDictionary:propertyKeys];
        if (jsonDict != nil) {
            [jsonDictArray addObject:jsonDict];
        }
    }
    
    return jsonDictArray;
    
}

+(NSDictionary *)JSONDictFromObject:(id<MNFJsonAdapterDelegate>)theModel option:(MNFAdapterOption)theAdapterOption error:(NSError **)theError {
    
    MNFJsonAdapter *automaticSerializer = [[MNFJsonAdapter alloc] init];
    
    return [automaticSerializer p_createJSONDictFromObject:theModel option:theAdapterOption error:theError];
    
}

+(NSData *)JSONDataFromObject:(id<MNFJsonAdapterDelegate>)theModel option:(MNFAdapterOption)theAdapterOption error:(NSError *__autoreleasing *)theError {
    
    MNFJsonAdapter *automaticSerializer = [[MNFJsonAdapter alloc] init];
    
    return [automaticSerializer p_createJSONDataFromObject:theModel option:theAdapterOption error:theError];
}

#pragma mark - Public convenience methods

+(NSData*)JSONDataFromDictionary:(NSDictionary *)theDictionary {
    NSData *data = [NSJSONSerialization dataWithJSONObject:theDictionary options:0 error:nil];
    return data;
}
+(id)objectFromJSONData:(NSData *)theJSONData {
    return [NSJSONSerialization JSONObjectWithData:theJSONData options:0 error:nil];
}


#pragma mark - Private Initializers


-(NSData *)p_createJSONDataFromObject:(id <MNFJsonAdapterDelegate>)theModel option:(MNFAdapterOption)theAdapterOption error:(NSError **)theError {
    
    NSDictionary *theDict = [self p_createJSONDictFromObject:theModel option:theAdapterOption error:theError];
    
    return [NSJSONSerialization dataWithJSONObject:theDict options:0 error:nil];
}

-(NSDictionary *)p_createJSONDictFromObject:(id <MNFJsonAdapterDelegate>)theModel option:(MNFAdapterOption)theAdapterOption error:(NSError **)theError {
    
    NSDictionary *propertyKeys = [self p_createPropertyKeyDictionaryForObject:theModel option:theAdapterOption error:theError];
    
    // now get the values of the properties and store them in an NSDictionary
    NSDictionary *newJsonDict = [self p_createPeropertyValueDictionaryForObject:theModel propertyDictionary:propertyKeys];
    
    
    return newJsonDict;
}


#pragma mark - Serialization Dictionary Helpers

-(NSDictionary *)p_createPropertyKeyDictionaryForObject:(id <MNFJsonAdapterDelegate>)theModel option:(MNFAdapterOption)theAdapterOption error:(NSError **)theError {
    NSDictionary *propertyKeys = [self p_propertyKeyDictionaryAssociatedWithClass:[theModel class] error:theError];
    
    // if we have properties to serialize make
    if ([theModel respondsToSelector:@selector(propertiesToSerialize)]) {
        propertyKeys = [self p_propertyDictFromSet:[theModel propertiesToSerialize]];
    }
    else if([theModel respondsToSelector:@selector(propertiesToIgnoreJsonSerialization)]) {
        
        if ([theModel propertiesToIgnoreJsonSerialization] != nil) {
            
            propertyKeys = [self p_removeIgnoredPropertiesInDictionary:propertyKeys ignoredProperties:[theModel propertiesToIgnoreJsonSerialization] error:theError];
        }
    }
    
    if ([theModel respondsToSelector:@selector(propertyKeysMapToJson)]) {
        if ([theModel propertyKeysMapToJson] != nil) {
            propertyKeys = [self p_mapPropertyKeyValues:propertyKeys mapDictionary:[theModel propertyKeysMapToJson] error:theError];
        }
    }
    
    propertyKeys = [self p_updateOnlyDictionaryValues:propertyKeys option:theAdapterOption];
    
    return propertyKeys;
}

-(NSDictionary *)p_createDictionaryForObject:(NSObject *)theModelObject withProperties:(NSSet *)theProperties {
    
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    for (NSString *currentProperty in theProperties) {
        
        id value = [theModelObject valueForKey:currentProperty];
        if (value != nil) {
            [mutableDict setValue:value forKey:currentProperty];
        }
        else {
            [mutableDict setValue:[NSNull null] forKey:currentProperty];
        }
        
    }
    
    return mutableDict;
}

/** Has to be an NSObject to be able to call value for key with a protocol. */
-(NSDictionary *)p_createPeropertyValueDictionaryForObject:(NSObject <MNFJsonAdapterDelegate> *)theModelObject propertyDictionary:(NSDictionary *)thePropertyDictionary {
    
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    
    
    NSDictionary *transformerDict = nil;
    
    if ([theModelObject respondsToSelector:@selector(propertyValueTransformers)]) {
        transformerDict = [theModelObject propertyValueTransformers];
    }
    
    for (NSString *currentProperty in thePropertyDictionary) {
        
        id value = [theModelObject valueForKey:currentProperty];
        
        if (transformerDict != nil && value != nil && [transformerDict valueForKey:currentProperty] != nil && [[transformerDict valueForKey:currentProperty] isKindOfClass:[NSValueTransformer class]] == YES) {
            NSValueTransformer *transformer = [transformerDict valueForKey:currentProperty];
            value = [transformer reverseTransformedValue:value];
        }
        
        if (value != nil) {
            [newDict setObject:value forKey:thePropertyDictionary[currentProperty]];
        }
        else {
            [newDict setObject:[NSNull null] forKey:thePropertyDictionary[currentProperty]];
        }
        
    }
    
    return newDict;
}

#pragma mark - NSDictionary Property Helpers for Mapping / Ignoring properties

-(NSDictionary *)p_propertyDictFromSet:(NSSet *)thePropertySet {
    
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    
    for (NSString *propertyName in thePropertySet) {
        
        [newDict setObject:propertyName forKey:propertyName];
        
    }
    
    return newDict;
}

- (NSDictionary *)p_propertyKeyDictionaryAssociatedWithClass:(Class)theClass error:(NSError **)theError {
    
    NSMutableDictionary *propertyDict = [NSMutableDictionary dictionary];
    
    [theClass c_enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        NSString *keyName = @(property_getName(property));
        if ([keyName isEqualToString:@"superclass"] == NO && [keyName isEqualToString:@"hash"] == NO && [keyName isEqualToString:@"debugDescription"] == NO && [keyName isEqualToString:@"description"] == NO) {
            [propertyDict setObject:keyName forKey:keyName];
        }
        else {
            
            if (theError != nil) {
                *theError = [NSError errorWithDomain:JsonAdapterDomain code:kMenigaJsonErrorRestrictedPropertyUsed userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"<MenigaJsonAdapterRestrictedPropertyError>", @"Key describing an error when the user uses properties that are used by its subclass which we cannot access and are therefor not allowed as it will cause a crash at runtime.") }];
            }
        }
        
    }];
    
    return propertyDict;
}

// maps a json field to a new property in the object, where the key is the properties name
-(NSDictionary *)p_mapPropertyDictionaryKeys:(NSDictionary *)thePropertyDictToMap mapDictionary:(NSDictionary *)theMapDictionary error:(NSError **)theError {
    
    NSMutableDictionary *dictionaryToReturn = [NSMutableDictionary dictionaryWithDictionary:thePropertyDictToMap];
    
    for (NSString *mapPropertyKey in theMapDictionary) {
        
        BOOL foundPropertyToMap = NO;
        
        for(NSString *propertyKey in thePropertyDictToMap) {
           
            if ([propertyKey isEqualToString:mapPropertyKey]) {
                // se the name of the dictionary key to the one of the json in the mapping
                // set its value to the property key value so we know which property the json key
                // corresponds to
                [dictionaryToReturn setObject:propertyKey forKey:theMapDictionary[mapPropertyKey]];
                [dictionaryToReturn removeObjectForKey:propertyKey];
                
                foundPropertyToMap = YES;
                
            }
            
        }
        
        if (foundPropertyToMap == NO && theError != nil) {
            *theError = [NSError errorWithDomain:JsonAdapterDomain code:kMenigaJsonErrorMapPropertyKeyNotFound userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"<MenigaJsonAdapterMapPropertyNotFoundKeyErrorPartOne>", @""), mapPropertyKey, NSLocalizedString(@"<MenigaJsonAdapterMapPropertyNotFoundKeyErrorPartTwo>", @"")] }];
        }
        
    }
    
    
    return dictionaryToReturn;
}

// maps the property key values to the new mapping to create the json
-(NSDictionary *)p_mapPropertyKeyValues:(NSDictionary *)thePropertyDict mapDictionary:(NSDictionary *)theMapDictionary error:(NSError **)theError {
    
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:thePropertyDict];
    
    for (NSString *mapPropertyKey in theMapDictionary) {
        
        BOOL foundPropertyToMap = NO;
        for (NSString *propertyKey in thePropertyDict) {
            if ([propertyKey isEqualToString:mapPropertyKey]) {
                [newDict setObject:theMapDictionary[mapPropertyKey] forKey:propertyKey];
                foundPropertyToMap = YES;
            }
            
        }
        
        if (foundPropertyToMap == NO) {
            *theError = [NSError errorWithDomain:JsonAdapterDomain code:kMenigaJsonErrorMapPropertyKeyNotFound userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"<MenigaJsonAdapterMapPropertyNotFoundKeyErrorPartOne>", @""), mapPropertyKey, NSLocalizedString(@"<MenigaJsonAdapterMapPropertyNotFoundKeyErrorPartTwo>", @"")] }];
        }
    }
    
    return newDict;
}

/** Removes properties in the ignored properties NSSet if they exist in the property dictionary. This serves
 the functionality to delete properties which we do not want to de/serialize. */
-(NSDictionary *)p_removeIgnoredPropertiesInDictionary:(NSDictionary *)thePropertyDict ignoredProperties:(NSSet *)thePropertiesToIgnore error:(NSError **)theError {
    
    NSMutableDictionary *dictionaryToReturn = [NSMutableDictionary dictionaryWithDictionary:thePropertyDict];
    
    for (NSString *ignoredPropertyKey in thePropertiesToIgnore) {
        
        BOOL foundIgnoredPropertyKey = NO;
        
        for (NSString *propertyKey in thePropertyDict) {
            if ([ignoredPropertyKey isEqualToString:propertyKey]) {
                foundIgnoredPropertyKey = YES;
                [dictionaryToReturn removeObjectForKey:propertyKey];
                
            }
        }
        
        
        if (foundIgnoredPropertyKey == NO && theError != nil) {
            *theError = [NSError errorWithDomain:JsonAdapterDomain code:kMenigaJsonErrorIgnoredPropertyKeyNotFound userInfo: @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"<MenigaJsonAdapterIgnoredPropertyKeyNotFoundErro>", @""), ignoredPropertyKey]} ];
        }
    }
    
    return dictionaryToReturn;
}


#pragma mark - Methods for updating the dictionary with option


-(NSDictionary *)p_updateOnlyDictionaryValues:(NSDictionary *)theDict option:(MNFAdapterOption)theAdapterOption {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    
    for (NSString *key in theDict) {
        
        NSString *dictValue = theDict[key];
        
        [newDict setObject:[dictValue c_stringWithOption:theAdapterOption] forKey:key];
        
    }
    
    return newDict;
}


-(NSDictionary *)p_updateOnlyDictionaryKeys:(NSDictionary *)theDict option:(MNFAdapterOption)theAdapterOption {
    
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    
    for (NSString *key in theDict) {
        
        NSString *dictValue = theDict[key];
        
        [newDict setObject:dictValue forKey:[key c_stringWithOption:theAdapterOption]];
        
    }
    
    return newDict;
}


/** Updates the dictionary keys and values  */
-(NSDictionary *)p_updateDictionaryKeysAndValues:(NSDictionary *)theDict option:(MNFAdapterOption)theAdapterOption {
    
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    
    for (NSString *key in theDict) {
        
        NSString *dictValue = theDict[key];
        
        [newDict setObject:[dictValue c_stringWithOption:theAdapterOption] forKey:[key c_stringWithOption:theAdapterOption]];
    }
    
    return newDict;
}

@end
