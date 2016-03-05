//
//  UIFont+ArialAndHelveticaNeue.h
//  MaCherie
//
//  Created by Mathieu Skulason on 03/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (ArialAndHelveticaNeue)

// Printing fonts
+(void)printFonts;

// Arial
+(instancetype)arialBoldWithSize:(float)size;
+(instancetype)arialWithSize:(float)size;
+(instancetype)arialItalicWithSize:(float)size;
+(instancetype)arialBoldItalicWithSize:(float)size;


// Available iOS 7 for iPhone and iPad
+(instancetype)helveticaNeueWithSize:(float)size;
+(instancetype)helveticaNeueItalicWithSize:(float)size;
+(instancetype)helveticaNeueBoldWithSize:(float)size;
+(instancetype)helveticaNeueBoldItalicWithSize:(float)size;
+(instancetype)helveticaNeueMediumWitihSize:(float)size;
+(instancetype)helveticaNeueMediumItalicWithSize:(float)size;
+(instancetype)helveticaNeueLightWithSize:(float)size;
+(instancetype)helveticaNeueLightItalicWithSize:(float)size;

// Open sans
+(instancetype)openSansWithSize:(float)size;
+(instancetype)openSansItalicWithSize:(float)size;
+(instancetype)openSansBoldWithSize:(float)size;
+(instancetype)openSansBoldItalicWithSize:(float)size;
+(instancetype)openSansLightWithSize:(float)size;
+(instancetype)openSansLightItalicWithSize:(float)size;
+(instancetype)openSansMediumWithSize:(float)size;
+(instancetype)openSansMediumItalicWithSize:(float)size;
+(instancetype)openSansExtraBoldWithSize:(float)size;
+(instancetype)openSansExtraBoldItalicWithSize:(float)size;


// Maxwell
+(instancetype)maxwellWithSize:(float)size;
+(instancetype)maxwellBoldWithSize:(float)size;
+(instancetype)maxwellLightWithSize:(float)size;

@end
