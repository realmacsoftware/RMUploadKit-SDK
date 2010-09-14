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

#import "RMUploaderEmber.h"

#import "RMEmberContext.h"
#import "RMUploaderEmberCredentials.h"
#import "RMUploaderEmberPreset.h"

#import "RMUploaderEmberCredentialsConfigurationViewController.h"
#import "RMUploaderEmberPresetConfigurationViewController.h"
#import "RMUploaderEmberMetadataViewController.h"

#import "RMUploaderEmberConstants.h"

@implementation RMUploaderEmber

+ (RMEmberContext *)newContextWithCredentials:(RMUploaderEmberCredentials *)credentials
{
	NSString *serviceHost = nil;
#if DEBUG
	serviceHost = @"http://development.api.emberapp.com";
#else
	serviceHost = @"https://api.emberapp.com";
#endif
	
	NSString *APIKey = YOUR_EMBER_API_KEY;
	
	RMEmberContext *context = [[RMEmberContext alloc] initWithServiceURL:[NSURL URLWithString:serviceHost] APIKey:APIKey];
	[context authenticateWithToken:[credentials token]];
	return context;
}

- (RMUploadPresetConfigurationViewController *)credentialsConfigurationViewControllerForCredentials:(RMUploadCredentials *)credentials
{
	RMUploaderEmberCredentialsConfigurationViewController *viewController = [[RMUploaderEmberCredentialsConfigurationViewController alloc] initWithNibName:@"CredentialsConfigurationView" bundle:[NSBundle bundleWithIdentifier:RMUploaderEmberBundleIdentifier]];
	return viewController;
}

- (RMUploadPresetConfigurationViewController *)presetConfigurationViewControllerForPreset:(RMUploadPreset *)preset
{
	RMUploaderEmberPresetConfigurationViewController *viewController = [[RMUploaderEmberPresetConfigurationViewController alloc] initWithNibName:@"PresetConfigurationView" bundle:[NSBundle bundleWithIdentifier:RMUploaderEmberBundleIdentifier]];
	return viewController;
}

- (RMUploadMetadataConfigurationViewController *)additionalMetadataViewControllerForPresetClass:(Class)presetClass
{
	RMUploaderEmberMetadataViewController *viewController = [[RMUploaderEmberMetadataViewController alloc] initWithNibName:@"MetadataView" bundle:[NSBundle bundleWithIdentifier:RMUploaderEmberBundleIdentifier]];
	return viewController;
}

@end
