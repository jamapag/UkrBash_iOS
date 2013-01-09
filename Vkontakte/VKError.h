//
//  VKError.h
//  UkrBash
//
//  Created by Michail Grebionkin on 03.12.12.
//
//

#ifndef UkrBash_VKError_h
#define UkrBash_VKError_h

extern NSString * kVKErrorDomain;
extern NSString * kVKDataParserErrorObjectKey;
extern NSString * kVKConnectionErrorObjectKey;
extern NSString * kVKResponseErrorCodeKey;
extern NSString * kVKResponseErrorMessageKey;

typedef NS_ENUM(NSInteger, _VKErrorCode)
{
    // error codes described on http://vk.com/developers.php
    VKUnknownErrorCode = 1, // Unknown error occurred.
    VKApplicationDisabledErrorCode = 2, // Application is disabled. Enable your application or use test mode.
    
    VKIncorrectSignatureErrorCode = 4, // Incorrect signature.
    VKUserAuthorizationFailedErrorCode = 5, // User authorization failed.
    VKTooManyRequestsErrorCode = 6, // Too many requests per second.
    VKPermissionDeniedErrorCode = 7, // Permission to perform this action is denied by user.
    
    VKInternalServerErrorCode = 10, // Internal server error
    
    VKCaptchaRequiredErrorCode = 14, // Captcha is needed. See http://vk.com/developers.php?oid=-1&p=Ошибка%3A_Captcha_is_needed
    
    VKInvalidParamsErrorCode = 100, // One of the parameters specified was missing or invalid.
    
    VKInvalidUserIdErrorCode = 113, // Invalid user id (ids).
    
    VKInvalidGroupIdErrorCode = 125, // Invalid group id.
    
    VKFriendsListAccessDeniedErrorCode = 170, // Access to user's friends list denied.
    
    VKGroupsAccessDeniedErrorCode = 203, // Access to the group is denied.
    
    VKAddingPostDeniedErrorCode = 214, // Access to adding post denied.
    
    VKGroupsAccessDenied2ErrorCode = 260, // Access to the groups list is denied due to the user's privacy settings.
    
    VKTooFrequentlyErrorCode = 10005, // Too frequently.
    
    VKOperationDeniedErrorCode = 10007, // Operation denied by user.
    
    
    // custom error codes
    VKCanceledErrorCode = 100000, // canceled by user
    VKAccessDeniedErrorCode, // authorization access denied
    VKConnectionErrorCode, // connection error
    VKParseResponseErrorCode, // VKResponseParser error
    VKResponseErrorCode // VK server returns error
} VKErrorCode;

#endif
