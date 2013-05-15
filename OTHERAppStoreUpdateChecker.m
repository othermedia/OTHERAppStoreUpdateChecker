//
//  OTHERAppStoreUpdateChecker.m
//
//  Created by Adam Swinden on 15/05/2013.
//  Copyright (c) 2013 Other Media. All rights reserved.
//


#import "OTHERAppStoreUpdateChecker.h"


#pragma mark - Errors

NSString * const OTHERAppStoreUpdateCheckerErrorDomain = @"OTHERAppStoreUpdateCheckerErrorDomain";


#pragma mark - Results keys

NSString * const OTHERAppStoreUpdateCheckerAppStoreURLKey = @"OTHERAppStoreUpdateCheckerAppStoreURLKey";
NSString * const OTHERAppStoreUpdateCheckerWhatsNewKey = @"OTHERAppStoreUpdateCheckerWhatsNewKey";
NSString * const OTHERAppStoreUpdateCheckerVersionKey = @"OTHERAppStoreUpdateCheckerVersionKey";


@implementation OTHERAppStoreUpdateChecker


+ (void)checkForUpdatesWithAppleID:(NSString *)appleID completionBlock:(void (^)(BOOL updateAvailable, NSDictionary *results, NSError *error))completion {
	
	OTHERAppStoreUpdateChecker *checker = [OTHERAppStoreUpdateChecker new];
	[checker checkForUpdatesWithAppleID:appleID completionBlock:^(BOOL updateAvailable, NSDictionary *results, NSError *error) {
		
		if (completion) completion(updateAvailable, results, error);
	}];
}


- (void)checkForUpdatesWithAppleID:(NSString *)appleID completionBlock:(void (^)(BOOL updateAvailable, NSDictionary *results, NSError *error))completion {

	NSAssert(appleID, @"appleID must not be nil");
	NSAssert(appleID.length > 0, @"appleID must be a valid Apple App ID");
	
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", appleID]];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
		
		if (error) {
			
			NSError *returnError = [NSError errorWithDomain:OTHERAppStoreUpdateCheckerErrorDomain code:OTHERAppStoreUpdateCheckerConnectionError userInfo:@{NSLocalizedDescriptionKey: @"Connection to App Store failed", NSUnderlyingErrorKey: error}];
			if (completion) completion(NO, nil, returnError);
			
			return;
		}
		
		NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
		NSUInteger shortStatusCode = HTTPResponse.statusCode / 100;
		if (shortStatusCode == 4 || shortStatusCode == 5) {
			
			NSError *underlyingError = [NSError errorWithDomain:NSURLErrorDomain code:HTTPResponse.statusCode userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP %d received", HTTPResponse.statusCode]}];
			NSError *returnError = [NSError errorWithDomain:OTHERAppStoreUpdateCheckerErrorDomain code:OTHERAppStoreUpdateCheckerConnectionError userInfo:@{NSLocalizedDescriptionKey: @"Connection to App Store failed", NSUnderlyingErrorKey: underlyingError}];
			if (completion) completion(NO, nil, returnError);
			
			return;
		}
		
		NSError *JSONError = nil;
		NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
		if (JSONError) {
			
			NSError *returnError = [NSError errorWithDomain:OTHERAppStoreUpdateCheckerErrorDomain code:OTHERAppStoreUpdateCheckerConnectionError userInfo:@{NSLocalizedDescriptionKey: @"Connection to App Store failed", NSUnderlyingErrorKey: JSONError}];
			if (completion) completion(NO, nil, returnError);
			
			return;
		}
		
		NSArray *resultsList = [results objectForKey:@"results"];
		if ([resultsList isEqual:[NSNull null]]) resultsList = nil;
		
		NSDictionary *appDictionary = [resultsList lastObject];
		
		if (appDictionary == nil) {
			
			NSError *returnError = [NSError errorWithDomain:OTHERAppStoreUpdateCheckerErrorDomain code:OTHERAppStoreUpdateCheckerAppStoreError userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"App with ID %@ not found in App Store", appleID]}];
			if (completion) completion(NO, nil, returnError);
			
			return;
		}
		
		NSString *thisVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		NSString *availableVersion = [appDictionary objectForKey:@"version"];
		
		if (availableVersion && thisVersion && ![thisVersion isEqualToString:availableVersion]) {
			
			NSString *whatsNew = [appDictionary objectForKey:@"releaseNotes"];
			NSString *appStoreURL = [appDictionary objectForKey:@"trackViewUrl"];
			
			NSMutableDictionary *returnResults = [NSMutableDictionary dictionaryWithObject:availableVersion forKey:OTHERAppStoreUpdateCheckerVersionKey];
			if (whatsNew) [returnResults setObject:whatsNew forKey:OTHERAppStoreUpdateCheckerWhatsNewKey];
			if (appStoreURL) [returnResults setObject:appStoreURL forKey:OTHERAppStoreUpdateCheckerAppStoreURLKey];
			
			if (completion) completion(YES, returnResults, nil);
		}
		else {
			
			if (completion) completion(NO, nil, nil);
		}
	}];
}


@end
