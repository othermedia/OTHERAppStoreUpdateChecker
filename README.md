# OTHERAppStoreUpdateChecker #


The OTHERAppStoreUpdateChecker class provides a method that uses the iTunes App Store API to check if a version of the app with a different version number is available in the App Store.

__Example:__

	[OTHERAppStoreUpdateChecker checkForUpdatesWithAppleID:@"123456789" completionBlock:^(BOOL updateAvailable, NSDictionary *results, NSError *error) {
		
		if (error == nil && updateAvailable) {

			NSString *newVersionNumber = [results objectForKey:OTHERAppStoreUpdateCheckerVersionKey];
			NSString *whatsNew = [results objectForKey:OTHERAppStoreUpdateCheckerWhatsNewKey];
			NSString *appStoreURL = [results objectForKey:OTHERAppStoreUpdateCheckerAppStoreURLKey];
		}
	}];


