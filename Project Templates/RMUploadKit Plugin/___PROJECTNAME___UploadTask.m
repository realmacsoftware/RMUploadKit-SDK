//
//  ___PROJECTNAME___UploadTask.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "___PROJECTNAME___UploadTask.h"

#import "___PROJECTNAME___Constants.h"

@implementation ___PROJECTNAME___UploadTask

- (id)initWithPreset:(RMUploadPreset *)destination uploadInfo:(id)uploadInfo
{	
	self = [super initWithPreset:destination uploadInfo:uploadInfo];
	if (self == nil) return nil;
	
	
	
	return self;
}

- (void)upload
{
	@synchronized (self) {
		if ([self isCancelled]) return;
		
		// Note: start upload connection…
	}
}

- (void)cancel
{
	@synchronized (self) {
		[super cancel];
		
		// Note: cancel upload connection…
		
		[[NSNotificationCenter defaultCenter] postNotificationName:RMUploadTaskDidCompleteNotificationName object:self];
	}
}

@end
