//
//  ___PROJECTNAME___Preset.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "___PROJECTNAME___Preset.h"

#import "___PROJECTNAME___UploadTask.h"
#import "___PROJECTNAME___Constants.h"

@implementation ___PROJECTNAME___Preset

+ (NSString *)localisedName
{
	return @"___PROJECTNAME___";
}

+ (Class)uploadTaskClass
{
	return [___PROJECTNAME___UploadTask class];
}

/*
+ (Class)credentialsClass
{
	return [___PROJECTNAME___Credentials class];
}
*/

- (id)initWithPropertyListRepresentation:(id)values
{
	id superRepresentation = [values objectForKey:@"super"];
	self = [super initWithPropertyListRepresentation:superRepresentation];
	if (self == nil) return nil;
	
	// Note: set any properties from the values container
	
	return self;
}

- (id)propertyListRepresentation
{
	id superRepresentation = [super propertyListRepresentation];
	
	NSMutableDictionary *plist = [NSMutableDictionary dictionary];
	[plist setObject:superRepresentation forKey:@"super"];
	
	// Note: set any properties into the values container
	
	return plist;
}

@end
