//
//  OTHERAppStoreUpdateChecker.h
//
//  Created by Adam Swinden on 15/05/2013.
//  Copyright (c) 2013 Other Media. All rights reserved.
//


#import <Foundation/Foundation.h>


#pragma mark - Errors

extern NSString * const OTHERAppStoreUpdateCheckerErrorDomain;

typedef NS_ENUM(NSInteger, OTHERAppStoreUpdateCheckerError) {
	OTHERAppStoreUpdateCheckerConnectionError	= 1,
	OTHERAppStoreUpdateCheckerAppStoreError		= 2
};

#pragma mark - Results keys

/**
 The App Store URL for the app.
 */
extern NSString * const OTHERAppStoreUpdateCheckerAppStoreURLKey;
/**
 The What's New text for the new version of the app.
 */
extern NSString * const OTHERAppStoreUpdateCheckerWhatsNewKey;
/**
 The version number of the new version of the app.
 */
extern NSString * const OTHERAppStoreUpdateCheckerVersionKey;


/**
 The OTHERAppStoreUpdateChecker class provides a method that uses the iTunes App Store API to check if a version of the app with a
 different version number is available in the App Store.
 */
@interface OTHERAppStoreUpdateChecker : NSObject


#if NS_BLOCKS_AVAILABLE

/**
 Checks the iTunes App Store API for a given Apple ID to find versions of the app with a different version number.
 
 This method uses the value stored against CFBundleShortVersionString in the App Info.plist to determine if a new version is available.
 If the App Store API request is successful, the updateAvailble parameter of the completion block will be set depending on if a new
 version is available. If a new version is available, the results paramter of the completion block will contain a dictionary of values
 providing the new version number, App Store URL and What's New text. If the request fails, the results paramter will be nil and the
 error paramter will contain information about the failure.
 
 @param appleID The unique Apple ID for the app. This can be found in iTunes Connect. Must not be nil.
 @param completion A block that will be called when the method has finished contacting the App Store API.
 */
+ (void)checkForUpdatesWithAppleID:(NSString *)appleID completionBlock:(void (^)(BOOL updateAvailable, NSDictionary *results, NSError *error))completion NS_AVAILABLE(10_7, 5_0);;

#endif


@end
