//
//  UBErrorsParser.m
//  UkrBash
//
//  Created by Maks Markovets on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UBErrorsParser.h"
#import "GDataXMLNode.h"

@implementation UBErrorsParser

static NSString *kName_Code = @"code";
static NSString *kName_Text = @"text";
static NSString *kName_Url = @"url";

- (NSDictionary *)parseErrorWithData:(NSData *)xmlData
{
    NSMutableDictionary *errorDictionary = [[NSMutableDictionary alloc] init];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    NSArray *errorElementsArray = [doc nodesForXPath:@"error" error:nil];
    if ([errorElementsArray count] == 0) {
        [doc release];
        [errorDictionary release];
        return nil;
    }
    GDataXMLElement *errorElement = [errorElementsArray objectAtIndex:0];
    
    NSArray *codesArray = [errorElement elementsForName:kName_Code];
    for (GDataXMLElement *codeElement in codesArray) {
        [errorDictionary setObject:[NSNumber numberWithInteger:codeElement.stringValue.integerValue] forKey:kName_Code];
    }
    NSArray *textsArray = [errorElement elementsForName:kName_Text];
    for (GDataXMLElement *textElement in textsArray) {
        [errorDictionary setObject:textElement.stringValue forKey:kName_Text];
    }
    NSArray *urlsArray = [errorElement elementsForName:kName_Url];
    for (GDataXMLElement *urlElement in urlsArray) {
        [errorDictionary setObject:urlElement.stringValue forKey:kName_Url];
    }
    [doc release];
    return [errorDictionary autorelease];
}

@end
