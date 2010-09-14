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

#import "RMUploaderEmberPreset.h"

#import "RMUploaderEmberCredentials.h"
#import "RMUploaderEmberTask.h"

static NSString *const RMEmberPresetPrivacyKey = @"privacyLevel";
static NSString *const RMEmberPresetCollectionKey = @"collectionSlug";
static NSString *const RMEmberPresetCategoryKey = @"categorySlug";

@implementation RMUploaderEmberPreset

@dynamic authentication;

@synthesize privacyLevel=_privacyLevel, collectionSlug=_collectionSlug, categorySlug=_categorySlug;

+ (Class)credentialsClass {
	return [RMUploaderEmberCredentials class];
}

+ (NSString *)localisedName {
	return @"Ember";
}

+ (Class)uploadTaskClass {
	return [RMUploaderEmberTask class];
}

+ (NSURL *)serviceURL {
	return [[NSURL alloc] initWithScheme:@"http" host:@"api.emberapp.com" path:@"/"];
}

+ (NSString *)autoselectTrayImageKey {
	return @"ember";
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
	
	if ([key isEqualToString:RMUploadPresetDirtyKey]) {
		[keyPaths addObjectsFromArray:[NSArray arrayWithObjects:
									   RMEmberPresetPrivacyKey,
									   RMEmberPresetCollectionKey,
									   RMEmberPresetCategoryKey,
									   nil]
		 ];
	}
	
	return keyPaths;
}

- (id)initWithPropertyListRepresentation:(id)values {
	id superRepresentation = [values objectForKey:@"super"];
	
	self = [super initWithPropertyListRepresentation:superRepresentation];
	if (self == nil) return nil;
	
	self.privacyLevel = [[values valueForKey:RMEmberPresetPrivacyKey] copy];
	
	if ([values valueForKey:RMEmberPresetCollectionKey] != nil)
		self.collectionSlug = [[values valueForKey:RMEmberPresetCollectionKey] copy];
	
	if ([values valueForKey:RMEmberPresetCategoryKey] != nil)
		self.categorySlug = [[values valueForKey:RMEmberPresetCategoryKey] copy];
	
	return self;
}

- (id)propertyListRepresentation {
	id superRepresentation = [super propertyListRepresentation];
	
	NSMutableDictionary *plist = [NSMutableDictionary dictionary];
	[plist setObject:superRepresentation forKey:@"super"];
	[plist setValue:self.privacyLevel forKey:RMEmberPresetPrivacyKey];
	
	[plist setValue:self.collectionSlug forKey:RMEmberPresetCollectionKey]; 
	
	[plist setValue:self.categorySlug forKey:RMEmberPresetCategoryKey];
	
	return plist;
}

- (NSSet *)acceptedTypes {
	NSMutableSet *acceptedtypes = [[super acceptedTypes] mutableCopy];
	[acceptedtypes addObject:(id)kUTTypeJPEG];
	[acceptedtypes addObject:(id)kUTTypeGIF];
	[acceptedtypes addObject:(id)kUTTypePNG];
	return acceptedtypes;
}

@end
