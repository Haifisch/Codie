//
//  ShareKitSombreroConfig.m
//  QuickResponse
//
//  Created by Haifisch on 10/25/13.
//  Copyright (c) 2013 Haifisch. All rights reserved.
//

#import "ShareKitSombreroConfig.h"

@implementation ShareKitSombreroConfig
- (NSString*)appName {
	return @"QuickResponse";
}

- (NSString*)appURL {
	return @"http://gokulabs.com";
}
- (NSString*)twitterConsumerKey {
	return @"oKXHA9QIgDJManfrPIGjw";
}

- (NSString*)twitterSecret {
	return @"XnESKqucPiNFRNlDgnzAETzce4BQCSrzmaMqp3cYgg";
}
// You need to set this if using OAuth, see note above (xAuth users can skip it)
- (NSString*)twitterCallbackUrl {
	return @"http://gokulabs.com";
}
@end
