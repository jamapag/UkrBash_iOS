//
//  VKJsonResponseParserTests.m
//  VkontakteTests
//
//  Created by maks on 22.04.14.
//
//

#import "VKJsonResponseParserTests.h"
#import "VKJsonResponseParser.h"

@interface VKJsonResponseParserTests()
{
    VKJsonResponseParser *parser;
}

@end

@implementation VKJsonResponseParserTests

- (void)setUp
{
    [super setUp];
    
    parser = [[VKJsonResponseParser alloc] init];
}

- (void)tearDown
{
    [parser release];
    [super tearDown];
}

/**
 * Test of parsing typical error response.
 * @see TestsData/error_response_example.json
 */
- (void)testErrorResponseParsing
{
    NSError *error = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"error_response_example" ofType:@"json"];
    NSData *inputData = [NSData dataWithContentsOfFile:path];
    STAssertNotNil(inputData, @"test data not loaded");
    
    NSDictionary *results = [parser dictionaryFromData:inputData error:&error];
    STAssertNil(error, @"error == nil");
    STAssertNotNil(results, @"results == nil");
    STAssertNotNil([results objectForKey:@"error"], @"error not set");
    STAssertTrue([[results objectForKey:@"error"] isKindOfClass:[NSDictionary class]], @"error is not a dictionary");
    
    NSDictionary *resultsError = [results objectForKey:@"error"];
    STAssertNotNil([resultsError objectForKey:@"error_code"], @"error_code not set");
    STAssertNotNil([resultsError objectForKey:@"error_msg"], @"error_msg not set");
    STAssertNotNil([resultsError objectForKey:@"request_params"], @"request_params not set");
}

/**
 * Test of parsing typical success response with list data.
 * Example data from wall.get documentation example.
 * @see http://vk.com/dev/wall.get
 * @see TestsData/success_response_example_list.json
 */
- (void)testSuccessResponseListParsing
{
    NSError *error = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"success_response_example_list" ofType:@"json"];
    NSData *inputData = [NSData dataWithContentsOfFile:path];
    STAssertNotNil(inputData, @"test data not loaded");
    
    NSDictionary *results = [parser dictionaryFromData:inputData error:&error];
    STAssertNil(error, @"error != nil");
    STAssertNotNil(results, @"results == nil");
    
    NSDictionary * response = [results objectForKey:@"response"];
    STAssertNotNil(response, @"response == nil");
    STAssertNotNil([response objectForKey:@"count"], @"response[count] == nil");
    STAssertTrue([[response objectForKey:@"items"] isKindOfClass:[NSArray class]], @"response[items] not an array");
    STAssertTrue([[response objectForKey:@"items"] count] != 0, @"response[items] is empty");
    STAssertTrue([[[response objectForKey:@"items"] objectAtIndex:0] isKindOfClass:[NSDictionary class]], @"response[items][0] not a dictionary");
}

/**
 * Test of parsing typical success response with not list data.
 * Example data from notes.getById documentation example.
 * @see http://vk.com/dev/notes.getById
 * @see TestsData/success_response_example_not_list.json
 */
- (void)testSuccessResponseNotListParsing
{
    NSError * error = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"success_response_example_not_list" ofType:@"json"];
    NSData * inputData = [NSData dataWithContentsOfFile:path];
    STAssertNotNil(inputData, @"test data not loaded");
    
    NSDictionary * results = [parser dictionaryFromData:inputData error:&error];
    STAssertNil(error, @"error != nil");
    STAssertNotNil(results, @"results == nil");
    
    NSDictionary * response = [results objectForKey:@"response"];
    STAssertNotNil(response, @"response == nil");
    STAssertTrue([[response objectForKey:@"title"] isEqualToString:@"Title was there"], @"response[title] is wrong");
}

@end
