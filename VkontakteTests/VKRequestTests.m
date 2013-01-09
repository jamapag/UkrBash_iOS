//
//  VKRequestTests.m
//  UkrBash
//
//  Created by Michail Grebionkin on 04.12.12.
//
//

#import "VKRequestTests.h"
#import "Vkontakte.h"
#import "VKXMLResponseParser.h"
#import "FBTestBlocker.h"

@implementation VKRequestTests

- (void)testVKRequest
{
    __block FBTestBlocker * testBlocker = [[FBTestBlocker alloc] init];
    
    Vkontakte * vkontakte = [[Vkontakte alloc] initWithAccessToken:@"" expirationDate:[NSDate date] userId:0];
    [vkontakte setResponseParser:[[[VKXMLResponseParser alloc] init] autorelease]];
    [vkontakte callMethod:@"wall.get" withParams:@{} handler:^(NSString * method, NSDictionary * result, NSError * error){
        STAssertNotNil(error, @"error != nil");
        STAssertEqualObjects(method, @"wall.get", @"method != 'wall.get'");
        
        [testBlocker signal];
    }];
    
    [testBlocker wait];
    [testBlocker release];
}

@end
