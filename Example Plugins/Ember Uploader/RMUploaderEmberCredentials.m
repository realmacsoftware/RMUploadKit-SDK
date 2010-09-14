//*******************************************************************************

// Copyright (c) 2010 Realmac Software

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// Created by Danny Greg on 14/9/2010

//*******************************************************************************

#import "RMUploaderEmberCredentials.h"

NSString *const RMEmberCredentialsUserNameKey = @"userName";
NSString *const RMEmberCredentialsFullNameKey = @"fullName";
NSString *const RMEmberCredentialsTokenKey = @"token";
NSString *const RMEmberCredentialsAvatarLocationKey = @"avatarLocation";
NSString *const RMEmberCredentialsDateRegistered = @"dateRegistered";
NSString *const RMEmberCredentialsTotalImageUploaded = @"totalImagesUploaded";
NSString *const RMEmberCredentialsCollectionsKey = @"collections";
NSString *const RMEmberCredentialsFollowerCountKey = @"followerCount";

@implementation RMUploaderEmberCredentials

@synthesize userName, fullName, token, avatarLocation, dateRegistered, totalImagesUploaded, collections, followerCount;

+ (NSSet *)_propertyKeys {
	return [NSSet setWithObjects:
			RMEmberCredentialsUserNameKey,
			RMEmberCredentialsFullNameKey,
			RMEmberCredentialsTokenKey,
			RMEmberCredentialsAvatarLocationKey,
			RMEmberCredentialsDateRegistered,
			RMEmberCredentialsTotalImageUploaded,
			RMEmberCredentialsFollowerCountKey,
			nil];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
	
	if ([key isEqualToString:RMUploadCredentialsDirtyKey]) {
		[keyPaths unionSet:[NSSet setWithObjects:
							RMEmberCredentialsUserNameKey,
							RMEmberCredentialsFullNameKey,
							RMEmberCredentialsTokenKey,
							RMEmberCredentialsAvatarLocationKey,
							RMEmberCredentialsDateRegistered,
							RMEmberCredentialsTotalImageUploaded,
							RMEmberCredentialsFollowerCountKey,
							nil]];
	}
	
	if ([key isEqualToString:RMUploadCredentialsUserIdentifierKey]) {
		[keyPaths addObject:RMEmberCredentialsUserNameKey];
	}
	
	return keyPaths;
}

- (id)initWithPropertyListRepresentation:(id)values
{
	id superRepresentation = [values objectForKey:@"super"];
	self = [super initWithPropertyListRepresentation:superRepresentation];
	if (!self)
		return nil;
	
	self.followerCount = [[values valueForKey:RMEmberCredentialsFollowerCountKey] unsignedIntegerValue];
	self.totalImagesUploaded = [[values valueForKey:RMEmberCredentialsTotalImageUploaded] unsignedIntegerValue];
	
	if ([values valueForKey:RMEmberCredentialsUserNameKey] != nil)
		self.userName = [values valueForKey:RMEmberCredentialsUserNameKey];
	
	if ([values valueForKey:RMEmberCredentialsFullNameKey] != nil)
		self.fullName = [values valueForKey:RMEmberCredentialsFullNameKey];
	
	if ([values valueForKey:RMEmberCredentialsTokenKey] != nil)
		self.token = [values valueForKey:RMEmberCredentialsTokenKey];
	
	if ([values valueForKey:RMEmberCredentialsAvatarLocationKey] != nil)
		self.avatarLocation = [NSURL URLWithString:[values valueForKey:RMEmberCredentialsAvatarLocationKey]];
	
	if ([values valueForKey:RMEmberCredentialsDateRegistered] != nil)
		self.dateRegistered = [values valueForKey:RMEmberCredentialsDateRegistered];
	
	return self;
}

- (id)propertyListRepresentation
{
	id superRepresentation = [super propertyListRepresentation];
	
	NSMutableDictionary *plist = [NSMutableDictionary dictionary];
	[plist setObject:superRepresentation forKey:@"super"];
	
	[plist setObject:[NSNumber numberWithUnsignedInteger:self.followerCount] forKey:RMEmberCredentialsFollowerCountKey];
	[plist setObject:[NSNumber numberWithUnsignedInteger:self.totalImagesUploaded] forKey:RMEmberCredentialsTotalImageUploaded];
	
	if (self.userName != nil)
		[plist setObject:self.userName forKey:RMEmberCredentialsUserNameKey]; 
	
	if (self.fullName != nil)
		[plist setObject:self.fullName forKey:RMEmberCredentialsFullNameKey];
	
	if (self.token != nil)
		[plist setObject:self.token forKey:RMEmberCredentialsTokenKey]; 
	
	if (self.avatarLocation != nil)
		[plist setObject:[self.avatarLocation absoluteString] forKey:RMEmberCredentialsAvatarLocationKey];
	
	if (self.dateRegistered != nil)
		[plist setObject:self.dateRegistered forKey:RMEmberCredentialsDateRegistered];
	
	return plist;
}

- (NSString *)userIdentifier {
	return self.userName;
}

@end
