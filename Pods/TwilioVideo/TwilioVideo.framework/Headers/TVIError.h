//
//  TVIError.h
//  TwilioVideo
//
//  Copyright © 2016 Twilio. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef TVIError_h
#define TVIError_h

FOUNDATION_EXPORT NSString *const kTVIErrorDomain;

/**
 * Enumeration indicating the errors that can be raised by the SDK
 */
typedef NS_ENUM (NSUInteger, TVIError)
{
    TVIErrorUnknown = 0,        ///< An unknown error has occurred.
    TVIErrorSignaling,          ///< An error occuring with signaling.
    TVIErrorInvalidAccessToken  ///< The provided access token is invalid.
};

#endif
