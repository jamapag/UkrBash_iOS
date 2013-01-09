//
//  VkontakteTests.m
//  VkontakteTests
//
//  Created by Michail Grebionkin on 03.12.12.
//
//

#import "VKURLParserTests.h"
#import "VKURLParser.h"

@implementation VKURLParserTests

- (void)setUp
{
    // Set-up code here.
    [super setUp];
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void)testResponseParserNoParamsURL
{
    NSUInteger expectedCount = 0;
    NSDictionary * params = nil;
    
    params = [VKURLParser dictionaryParamsFromURL:[NSURL URLWithString:@"https://oauth.vk.com/blank.html?"]];
    STAssertNotNil(params, @"params != NULL");
    STAssertEquals([params count], expectedCount, @"[params count] != 0");

    params = [VKURLParser dictionaryParamsFromURL:[NSURL URLWithString:@"https://oauth.vk.com/blank.html#"]];
    STAssertNotNil(params, @"params != NULL");
    STAssertEquals([params count], expectedCount, @"[params count] != 0");
    
    params = [VKURLParser dictionaryParamsFromURL:[NSURL URLWithString:@"https://oauth.vk.com/blank.html"]];
    STAssertNotNil(params, @"params != NULL");
    STAssertEquals([params count], expectedCount, @"[params count] != 0");
}

/**
 * Input: https://oauth.vk.com/blank.html#error=access_denied&error_reason=user_denied&error_description=User%20denied%20your%20request
 * Output:
 * {
 *  'error' : 'access_denied',
 *  'error_reason' : 'user_denied',
 *  'error_description' : 'User denied your request'
 * }
 */
- (void)testResponseParserRegularURL
{
    NSDictionary * params = [VKURLParser dictionaryParamsFromURL:[NSURL URLWithString:@"https://oauth.vk.com/blank.html#error=access_denied&error_reason=user_denied&error_description=User%20denied%20your%20request"]];
    
    STAssertNotNil([params objectForKey:@"error"], @"'error' key should be setted");
    STAssertEqualObjects([params objectForKey:@"error"], @"access_denied", @"'error' != 'access_denied'");
    
    STAssertNotNil([params objectForKey:@"error_reason"], @"'error_reason' key should be setted");
    STAssertEqualObjects([params objectForKey:@"error_reason"], @"user_denied", @"'error_reason' != 'user_denied'");

    STAssertNotNil([params objectForKey:@"error_description"], @"'error_description' key should be setted");
    STAssertEqualObjects([params objectForKey:@"error_description"], @"User denied your request", @"'error_description' != 'User denied your request'");
}

/**
 * Input: https://oauth.vk.com/blank.html?error=access_denied&error_reason=user_denied&error_description=#test
 * Output:
 * {
 *  'error' : 'access_denied',
 *  'error_reason' : 'user_denied',
 *  'error_description' : null,
 *  'test' : null
 * }
 */
- (void)testResponseParserQueryAndFragment
{
    NSDictionary * params = [VKURLParser dictionaryParamsFromURL:[NSURL URLWithString:@"https://oauth.vk.com/blank.html?error=access_denied&error_reason=user_denied&error_description=#test"]];
    
    NSUInteger expectedCount = 4;
    STAssertEquals([params count], expectedCount, @"[params count] != 4");

    STAssertNotNil([params objectForKey:@"error"], @"'error' key should be setted");
    STAssertEqualObjects([params objectForKey:@"error"], @"access_denied", @"'error' != 'access_denied'");
    
    STAssertNotNil([params objectForKey:@"error_reason"], @"'error_reason' key should be setted");
    STAssertEqualObjects([params objectForKey:@"error_reason"], @"user_denied", @"'error_reason' != 'user_denied'");
    
    STAssertNotNil([params objectForKey:@"error_description"], @"'error_description' key should be setted");
    STAssertEqualObjects([params objectForKey:@"error_description"], [NSNull null], @"'error_description' != NULL");

    STAssertNotNil([params objectForKey:@"test"], @"'test' key should be setted");
    STAssertEqualObjects([params objectForKey:@"test"], [NSNull null], @"'test' != NULL");
}

/**
 * Input: https://oauth.vk.com/blank.html?error=access_denied&error_reason=user_denied&error_description=
 * Output:
 * {
 *  'error' : 'access_denied',
 *  'error_reason' : 'user_denied',
 *  'error_description' : null
 * }
 */
- (void)testResponseParserNullValues
{
    NSDictionary * params = [VKURLParser dictionaryParamsFromURL:[NSURL URLWithString:@"https://oauth.vk.com/blank.html?error=access_denied&error_reason=user_denied&error_description="]];
    
    STAssertNotNil([params objectForKey:@"error"], @"'error' key should be setted");
    STAssertEqualObjects([params objectForKey:@"error"], @"access_denied", @"'error' != 'access_denied'");
    
    STAssertNotNil([params objectForKey:@"error_reason"], @"'error_reason' key should be setted");
    STAssertEqualObjects([params objectForKey:@"error_reason"], @"user_denied", @"'error_reason' != 'user_denied'");
    
    STAssertNotNil([params objectForKey:@"error_description"], @"'error_description' key should be setted");
    STAssertEqualObjects([params objectForKey:@"error_description"], [NSNull null], @"'error_description' != NULL");
}

/**
 * Input: https://oauth.vk.com/blank.html#error=access_denied&error_reason=user_denied&error_description=&
 * Output:
 * {
 *  'error' : 'access_denied',
 *  'error_reason' : 'user_denied',
 *  'error_description' : null
 * }
 */
- (void)testResponseParserParamsCount
{
    NSDictionary * params = [VKURLParser dictionaryParamsFromURL:[NSURL URLWithString:@"https://oauth.vk.com/blank.html#error=access_denied&error_reason=user_denied&error_description=&"]];
    
    NSUInteger expectedCount = 3;
    STAssertEquals([params count], expectedCount, @"[params count] != 3");
    
    STAssertNil([params objectForKey:@""], @"unexpected param");
    
    STAssertNotNil([params objectForKey:@"error"], @"'error' key should be setted");
    STAssertEqualObjects([params objectForKey:@"error"], @"access_denied", @"'error' != 'access_denied'");
    
    STAssertNotNil([params objectForKey:@"error_reason"], @"'error_reason' key should be setted");
    STAssertEqualObjects([params objectForKey:@"error_reason"], @"user_denied", @"'error_reason' != 'user_denied'");
    
    STAssertNotNil([params objectForKey:@"error_description"], @"'error_description' key should be setted");
    STAssertEqualObjects([params objectForKey:@"error_description"], [NSNull null], @"'error_description' != NULL");
}

@end
