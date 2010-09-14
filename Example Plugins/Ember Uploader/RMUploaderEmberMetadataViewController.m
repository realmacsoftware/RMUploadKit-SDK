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

#import "RMUploaderEmberMetadataViewController.h"

#import "RMUploadKit/RMUploadKit.h"

#import "RMEmberContext.h"
#import "RMUploaderEmber.h"
#import "RMUploaderEmberTask.h"

#import "RMUploaderEmberConstants.h"
#import "RMUploaderEmberFunctions.h"

@interface RMUploaderEmberMetadataViewController () <RMUploadURLConnectionDelegate>
@property (assign) RMUploadURLConnection *imageTypesConnection;
@end

@implementation RMUploaderEmberMetadataViewController

@synthesize imageTypesPopupButton, imageTypesRefreshButton;
@synthesize imageTypesConnection=_imageTypesConnection;

- (void)loadView {
	[super loadView];
	
	[self refreshImageTypes:nil];
}

- (IBAction)imageTypeSelectionChanged:(id)sender {
	[[self representedObject] setValue:[[[self imageTypesPopupButton] selectedItem] representedObject] forKey:RMUploaderEmberMetadataImageTypeKey];
}

- (IBAction)refreshImageTypes:(id)sender {
	[[self imageTypesRefreshButton] setHidden:YES];
	
	RMEmberContext *context = [RMUploaderEmber newContextWithCredentials:nil];
	self.imageTypesConnection = [RMUploadURLConnection connectionWithRequest:[context requestImageTypes] delegate:self];
}

- (void)connection:(RMUploadURLConnection *)connection didFailWithError:(NSError *)error {
	NSString *errorLoadingButtonTitle = NSLocalizedStringFromTableInBundle(@"Error Loading…", nil, [NSBundle bundleWithIdentifier:RMUploaderEmberBundleIdentifier], @"RMEmberPresetConfigurationViewController error loading title");
	[[self imageTypesPopupButton] setTitle:errorLoadingButtonTitle];
	
	[[self imageTypesRefreshButton] setHidden:NO];
}

- (void)connection:(RMUploadURLConnection *)connection didCompleteWithData:(NSData *)data {
	NSError *parseError = nil;
	NSXMLDocument *responseDocument = [RMEmberContext parseResponse:data error:&parseError];
	
	if (responseDocument == nil) {
		[self connection:connection didFailWithError:parseError];
		return;
	}
	
	
	[[self imageTypesPopupButton] removeAllItems];
	
	NSMenu *imageTypesMenu = [[NSMenu alloc] init];
	
	NSArray *imageTypeNodes = [responseDocument nodesForXPath:@"//image_type" error:NULL];
	for (NSXMLNode *currentImageTypeNode in imageTypeNodes) {
		NSString *title = RMUploaderEmberStringValueForXPath(currentImageTypeNode, @"name", NULL);
		NSString *representedObject = RMUploaderEmberStringValueForXPath(currentImageTypeNode, @"id", NULL);
		if (title == nil || representedObject == nil) continue;
		
		NSMenuItem *currentImageTypeItem = [[NSMenuItem alloc] initWithTitle:title action:NULL keyEquivalent:@""];
		[currentImageTypeItem setRepresentedObject:representedObject];
		[imageTypesMenu addItem:currentImageTypeItem];
	}
	
	if ([[imageTypesMenu itemArray] count] == 0) {
		[self connection:connection didFailWithError:nil];
		return;
	}
	
	[[self imageTypesPopupButton] setMenu:imageTypesMenu];
	
	NSUInteger imageTypeValueIndex = NSNotFound;
	NSString *imageType = [[self representedObject] valueForKey:RMUploaderEmberMetadataImageTypeKey];
	if (imageType != nil) {
		NSArray *imageTypes = [[self imageTypesPopupButton] valueForKeyPath:@"itemArray.representedObject"];
		imageTypeValueIndex = [imageTypes indexOfObject:imageType];
	}
	if (imageTypeValueIndex == NSNotFound) {
		NSArray *defaultImageTypes = [responseDocument nodesForXPath:@"//image_type[default]" error:NULL];
		if ([defaultImageTypes count] == 1) {
			imageTypeValueIndex = [imageTypeNodes indexOfObject:RMUploaderEmberSafeObjectAtIndex(defaultImageTypes, 0)];
		}
	}
	if (imageTypeValueIndex == NSNotFound) {
		imageTypeValueIndex = 0;
	}
	[[self imageTypesPopupButton] selectItemAtIndex:imageTypeValueIndex];
	[self imageTypeSelectionChanged:nil];
	
	[[self imageTypesPopupButton] setEnabled:YES];
}

@end
