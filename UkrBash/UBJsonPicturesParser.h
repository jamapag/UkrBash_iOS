//
//  UBJsonPicturesParser.h
//  UkrBash
//
//  Created by maks on 16.04.14.
//
//

#import "UBParser.h"

@interface UBJsonPicturesParser : UBParser

- (NSArray *)parsePicturesWithData:(NSData *)jsonData;

@end
