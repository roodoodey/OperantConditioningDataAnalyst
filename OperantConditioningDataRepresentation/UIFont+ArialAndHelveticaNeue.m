//
//  UIFont+ArialAndHelveticaNeue.m
//  MaCherie
//
//  Created by Mathieu Skulason on 03/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "UIFont+ArialAndHelveticaNeue.h"

@implementation UIFont (ArialAndHelveticaNeue)

#pragma mark -
#pragma mark Print Fonts

+(void)printFonts
{
    for (NSString *fontFamilyName in [UIFont familyNames]) {
        NSLog(@"Family name: %@", fontFamilyName);
        NSArray *names = [UIFont fontNamesForFamilyName:fontFamilyName];
        NSLog(@"Font names: %@", names);
    }
}

#pragma mark -
#pragma mark Arial Font

+(instancetype)arialBoldWithSize:(float)size
{
    return [UIFont fontWithName:@"Arial-BoldMT" size:size];
}

+(instancetype)arialWithSize:(float)size
{
    return [UIFont fontWithName:@"ArialMT" size:size];
}

+(instancetype)arialItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"Arial-ItalicMT" size:size];
}

+(instancetype)arialBoldItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"Arial-BoldItalicMT" size:size];
}

#pragma mark -
#pragma mark Helvetica Neue

+(instancetype)helveticaNeueWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+(instancetype)helveticaNeueItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Italic " size:size];
}

+(instancetype)helveticaNeueBoldWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

+(instancetype)helveticaNeueBoldItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:size];
}

+(instancetype)helveticaNeueMediumWitihSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Medium " size:size];
}

+(instancetype)helveticaNeueMediumItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:size];
}

+(instancetype)helveticaNeueLightWithSize:(float)size
{
    return [UIFont fontWithName:@"" size:size];
}

+(instancetype)helveticaNeueLightItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"" size:size];
}


#pragma mark - Open Sans


+(instancetype)openSansWithSize:(float)size
{
    return [UIFont fontWithName:@"OpenSans" size:size];
}

+(instancetype)openSansItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"OpenSans-Italic" size:size];
}

+(instancetype)openSansBoldWithSize:(float)size
{
    return [UIFont fontWithName:@"OpenSans-Bold" size:size];
}

+(instancetype)openSansBoldItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"OpenSans-BoldItalic" size:size];
}

+(instancetype)openSansLightWithSize:(float)size
{
    return [UIFont fontWithName:@"OpenSans-Light" size:size];
}

+(instancetype)openSansLightItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"OpenSansLight-Italic" size:size];
}

+(instancetype)openSansMediumWithSize:(float)size
{
    return [UIFont fontWithName:@"OpenSans-Semibold" size:size];
}

+(instancetype)openSansMediumItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"OpenSans-SemiboldItalic" size:size];
}

+(instancetype)openSansExtraBoldWithSize:(float)size
{
    return [UIFont fontWithName:@"OpenSans-Extrabold" size:size];
}

+(instancetype)openSansExtraBoldItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"OpenSans-ExtraboldItalic" size:size];
}


#pragma mark - Maxwell

+(instancetype)maxwellWithSize:(float)size
{
    return [UIFont fontWithName:@"MAXWELLREGULAR" size:size];
}

+(instancetype)maxwellBoldWithSize:(float)size
{
    return [UIFont fontWithName:@"MAXWELLBOLD" size:size];
}

+(instancetype)maxwellLightWithSize:(float)size
{
    return [UIFont fontWithName:@"MAXWELL" size:size];
}



@end
