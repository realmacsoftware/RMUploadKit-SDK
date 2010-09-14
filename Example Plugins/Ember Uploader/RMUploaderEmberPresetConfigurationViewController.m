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

#import "RMUploaderEmberPresetConfigurationViewController.h"

#import "RMUploadKit/RMUploadKit.h"

#import "RMEmberContext.h"
#import "RMUploaderEmber.h"
#import "RMUploaderEmberPreset.h"

#import "RMUploaderEmberConstants.h"
#import "RMUploaderEmberFunctions.h"

@interface RMUploaderEmberPresetConfigurationViewController ()
@property (retain) RMUploadURLConnection *privacyConnection;

@property (retain) RMUploadURLConnection *collectionsConnection;
@property (readwrite, assign, getter=isLoadingCollections) BOOL loadingCollections;
@property (assign) NSUInteger collectionsCount;

- (void)_loadingCollectionsConnectionDidComplete:(BOOL)success;

@property (retain) RMUploadURLConnection *newCollectionConnection;
@property (readwrite, assign, getter=isCreatingCollection) BOOL creatingCollection;

- (void)_newCollectionConnectionDidComplete:(BOOL)success;
- (BOOL)_parseCollectionElements:(NSArray *)elements merge:(BOOL)merge;

@property (retain) RMUploadURLConnection *categoriesConnection;
@end

@interface RMUploaderEmberPresetConfigurationViewController (Delegate) <RMUploadURLConnectionDelegate>

@end

#pragma mark -

@implementation RMUploaderEmberPresetConfigurationViewController

@dynamic representedObject;

@synthesize privacyPopupButton, privacyRefreshButton, privacyConnection=_privacyConnection;

@synthesize collectionsPopupButton, collectionsCount=_collectionsCount, collectionsRefreshButton;
@synthesize collectionsConnection=_collectionsConnection, loadingCollections=_loadingCollections;

@synthesize newCollectionTitleField, newCollectionButton, newCollectionSpinner;
@synthesize creatingCollection=_creatingCollection, newCollectionConnection=_newCollectionConnection;

@synthesize categoriesPopupButton, categoriesRefreshButton;
@synthesize categoriesConnection=_categoriesConnection;

#define LoadingLocalisedString NSLocalizedStringFromTableInBundle(@"Loading…", nil, [NSBundle bundleWithIdentifier:RMUploaderEmberBundleIdentifier], @"RMUploaderEmberPresetConfigurationViewController loading popup button name")
#define ErrorLoadingLocalisedString NSLocalizedStringFromTableInBundle(@"Error Loading…", nil, [NSBundle bundleWithIdentifier:RMUploaderEmberBundleIdentifier], @"RMEmberPresetConfigurationViewController error loading title")
#define NoneLocalizedString NSLocalizedStringFromTableInBundle(@"None", nil, [NSBundle bundleWithIdentifier:RMUploaderEmberBundleIdentifier], @"RMEmberPresetConfigurationViewController no privacy settings loaded popup button title")

- (void)loadView
{
	[super loadView];
	
	[self refreshPrivacy:nil];
	[self refreshCollections:nil];
	[self refreshCategories:nil];
}

- (IBAction)refreshPrivacy:(id)sender
{
	[[self privacyRefreshButton] setHidden:YES];
	
	[[self privacyPopupButton] setEnabled:NO];
	[[self privacyPopupButton] setTitle:LoadingLocalisedString];
	
	RMEmberContext *context = [RMUploaderEmber newContextWithCredentials:self.representedObject.authentication];
	self.privacyConnection = [RMUploadURLConnection connectionWithRequest:[context requestPrivacy] delegate:self];
}

- (IBAction)refreshCollections:(id)sender
{
	[[self collectionsRefreshButton] setHidden:YES];
	
	[[self collectionsPopupButton] setEnabled:NO];
	[[self collectionsPopupButton] setTitle:LoadingLocalisedString];
	
	RMEmberContext *context = [RMUploaderEmber newContextWithCredentials:self.representedObject.authentication];
	self.collectionsConnection = [RMUploadURLConnection connectionWithRequest:[context requestCollectionsForUsername:self.representedObject.authentication.userName] delegate:self];
	
	[self setLoadingCollections:YES];
}

- (IBAction)refreshCategories:(id)sender
{
	[[self categoriesRefreshButton] setHidden:YES];
	
	[[self categoriesPopupButton] setEnabled:NO];
	[[self categoriesPopupButton] setTitle:LoadingLocalisedString];
	
	RMEmberContext *context = [RMUploaderEmber newContextWithCredentials:self.representedObject.authentication];
	self.categoriesConnection = [RMUploadURLConnection connectionWithRequest:[context requestCategories] delegate:self];
}

#pragma mark -

- (IBAction)privacySelectionChanged:(id)sender
{
	self.representedObject.privacyLevel = [[[self privacyPopupButton] selectedItem] representedObject];
}

- (IBAction)collectionsSelectionChanged:(id)sender
{
	self.representedObject.collectionSlug = [[[self collectionsPopupButton] selectedItem] representedObject];
}

- (IBAction)categoriesSelectionChanged:(id)sender
{
	self.representedObject.categorySlug = [[[self categoriesPopupButton] selectedItem] representedObject];
}

- (IBAction)newCollection:(id)sender
{
	[[self newCollectionTitleField] validateEditing];
	
	BOOL (^validateTextField)(NSTextField *) = ^ (NSTextField *field) {
		if ([field stringValue] != nil && [[field stringValue] length] > 0) return YES;
		
		[self highlightErrorInView:field];
		return NO;
	};
	if (!validateTextField([self newCollectionTitleField])) return;
	
	[self setCreatingCollection:YES];
	
	RMEmberContext *context = [RMUploaderEmber newContextWithCredentials:self.representedObject.authentication];
	self.newCollectionConnection = [RMUploadURLConnection connectionWithRequest:[context requestCreateCollectionWithName:[[self newCollectionTitleField] stringValue]] delegate:self];
}

- (void)connection:(RMUploadURLConnection *)connection didFailWithError:(NSError *)error
{
	if (connection == self.privacyConnection) {
		[[self privacyPopupButton] setTitle:ErrorLoadingLocalisedString];
		[[self privacyPopupButton] setEnabled:NO];
		
		[[self privacyRefreshButton] setHidden:NO];
		return;
	}
	
	if (connection == self.collectionsConnection) {
		[self _loadingCollectionsConnectionDidComplete:NO];
		return;
	}
	
	if (connection == self.categoriesConnection) {
		[[self categoriesPopupButton] setTitle:ErrorLoadingLocalisedString];
		[[self categoriesPopupButton] setEnabled:NO];
		
		[[self categoriesRefreshButton] setHidden:NO];
		return;
	}
	
	if (connection == self.newCollectionConnection) {
		[self _newCollectionConnectionDidComplete:NO];
		return;
	}
}

static NSString * (^slugForCollection)(NSXMLElement *) = ^ (NSXMLElement *collectionElement) {
	return RMUploaderEmberStringValueForXPath(collectionElement, @"slug", NULL);
};

- (void)connection:(RMUploadURLConnection *)connection didCompleteWithData:(NSData *)data
{
	NSError *parseError = nil;
	NSXMLDocument *document = [RMEmberContext parseResponse:data error:&parseError];
	
	if (document == nil) {
		[self connection:connection didFailWithError:parseError];
		return;
	}
	
	if (connection == self.privacyConnection) {
		[[self privacyPopupButton] removeAllItems];
		
		NSMenu *privacyMenu = [[NSMenu alloc] init];
		
		NSArray *privacyNodes = [document nodesForXPath:@"//privacy_level" error:NULL];
		for (NSXMLNode *currentPrivacyNode in privacyNodes) {
			NSString *categoryTitle = RMUploaderEmberStringValueForXPath(currentPrivacyNode, @"name", NULL);
			NSString *representedObject = RMUploaderEmberStringValueForXPath(currentPrivacyNode, @"id", NULL);
			if (categoryTitle == nil || representedObject == nil) continue;
			
			NSMenuItem *currentPrivacyItem = [[NSMenuItem alloc] initWithTitle:categoryTitle action:NULL keyEquivalent:@""];
			[currentPrivacyItem setRepresentedObject:representedObject];
			[privacyMenu addItem:currentPrivacyItem];
		}
		
		if ([[privacyMenu itemArray] count] == 0) {
			[[self privacyPopupButton] setTitle:NoneLocalizedString];
			return;
		}
		
		[[self privacyPopupButton] setMenu:privacyMenu];
		
		NSInteger privacyValueIndex = -1;
		if (self.representedObject.privacyLevel != nil) {
			privacyValueIndex = [[self privacyPopupButton] indexOfItemWithRepresentedObject:self.representedObject.privacyLevel];
		}
		if (privacyValueIndex == -1) {
			NSArray *defaultNode = [document nodesForXPath:@"//privacy_level[default]" error:NULL];
			if ([defaultNode count] == 1) {
				privacyValueIndex = [privacyNodes indexOfObject:RMUploaderEmberSafeObjectAtIndex(defaultNode, 0)];
			}
		}
		if (privacyValueIndex == -1) {
			privacyValueIndex = 0;
		}
		[[self privacyPopupButton] selectItemAtIndex:privacyValueIndex];
		[self privacySelectionChanged:nil];
		
		[[self privacyPopupButton] setEnabled:YES];
		return;
	}
	
	if (connection == self.collectionsConnection) {
		[self _parseCollectionElements:[document nodesForXPath:@"//collection" error:NULL] merge:NO];
		
		[self _loadingCollectionsConnectionDidComplete:YES];
		return;
	}
	
	if (connection == self.categoriesConnection) {
		[[self categoriesPopupButton] removeAllItems];
		
		NSMenu *categoriesMenu = [[NSMenu alloc] init];
		[categoriesMenu setAutoenablesItems:NO];
		
		[categoriesMenu addItemWithTitle:NoneLocalizedString action:NULL keyEquivalent:@""];
		
		NSUInteger addedCategoriesCount = 0;
		
		for (NSXMLNode *categoryNode in [document nodesForXPath:@"/response/categories/category" error:NULL]) {
			NSString *categoryTitle = RMUploaderEmberStringValueForXPath(categoryNode, @"name", NULL);
			if (categoryTitle == nil) continue;
			
			// Add subcategories
			NSArray *subcategories = [categoryNode nodesForXPath:@"subcategories/subcategory" error:NULL];
			if (subcategories == nil || [subcategories count] < 1) continue;
			
			
			NSMutableArray *subcategoryItems = [NSMutableArray arrayWithCapacity:[subcategories count]];
			
			for (NSXMLNode *subcategoryNode in subcategories) {
				NSString *subcategoryTitle = RMUploaderEmberStringValueForXPath(subcategoryNode, @"name", NULL);
				NSString *subcategoryRepresentedObject = RMUploaderEmberStringValueForXPath(subcategoryNode, @"slug", NULL);
				if (subcategoryTitle == nil || subcategoryRepresentedObject == nil) continue;
				
				NSMenuItem *subcategoryItem = [[NSMenuItem alloc] initWithTitle:subcategoryTitle action:NULL keyEquivalent:@""];
				[subcategoryItem setRepresentedObject:subcategoryRepresentedObject];
				[subcategoryItem setIndentationLevel:1];
				[subcategoryItems addObject:subcategoryItem];
			}
			
			if ([subcategoryItems count] == 0) continue;
			
			
			if (addedCategoriesCount == 0) [categoriesMenu addItem:[NSMenuItem separatorItem]];
			addedCategoriesCount++;
			
			NSMenuItem *categoryItem = [[NSMenuItem alloc] initWithTitle:categoryTitle action:NULL keyEquivalent:@""];
			[categoryItem setEnabled:NO];
			[categoriesMenu addItem:categoryItem];
			
			for (NSMenuItem *currentSubcategoryItem in subcategoryItems) [categoriesMenu addItem:currentSubcategoryItem];
		}
		
		[[self categoriesPopupButton] setMenu:categoriesMenu];
		
		if (addedCategoriesCount != 0) {
			if (self.representedObject.categorySlug != nil) {
				NSInteger selectedCategoryIndex = [[self categoriesPopupButton] indexOfItemWithRepresentedObject:self.representedObject.categorySlug];
				[[self categoriesPopupButton] selectItemAtIndex:(selectedCategoryIndex != -1 ? selectedCategoryIndex : 0)];
				[self categoriesSelectionChanged:nil];
			}
			
			[[self categoriesPopupButton] setEnabled:YES];
		}
		
		return;
	}
	
	if (connection == self.newCollectionConnection) {
		NSArray *collectionElements = [document nodesForXPath:@"//collection[1]" error:NULL];
		if ([collectionElements count] == 0) {
			[self connection:connection didFailWithError:nil];
			return;
		}
		
		BOOL parsed = [self _parseCollectionElements:collectionElements merge:YES];
		
		if (parsed) {
			NSString *newCollectionSlug = slugForCollection([collectionElements objectAtIndex:0]);
			NSInteger newCollectionIndex = [[self collectionsPopupButton] indexOfItemWithRepresentedObject:newCollectionSlug];
			
			if (newCollectionIndex == -1) {
				[self connection:connection didFailWithError:nil];
				return;
			}
			[[self collectionsPopupButton] selectItemAtIndex:newCollectionIndex];
			[self collectionsSelectionChanged:nil];
		}
		
		[self _newCollectionConnectionDidComplete:parsed];
		return;
	}
}

- (void)_loadingCollectionsConnectionDidComplete:(BOOL)success {
	if (!success) {
		NSMenu *errorMenu = [[NSMenu alloc] init];
		[errorMenu addItemWithTitle:ErrorLoadingLocalisedString action:NULL keyEquivalent:@""];
		[[self collectionsPopupButton] setMenu:errorMenu];
		
		[[self collectionsPopupButton] setEnabled:NO];
		
		[[self collectionsRefreshButton] setHidden:NO];
	} else {
		[[self collectionsRefreshButton] setHidden:YES];
	}
	
	[self setLoadingCollections:NO];
}

- (void)_newCollectionConnectionDidComplete:(BOOL)success {
	NSURL *newCollectionButtonImageURL = [[NSBundle bundleWithIdentifier:RMUploaderEmberBundleIdentifier] URLForImageResource:@"add.png"];
	if (!success) newCollectionButtonImageURL = [[NSBundle bundleWithIdentifier:RMUploaderEmberBundleIdentifier] URLForImageResource:@"error.png"];
	[[self newCollectionButton] setImage:[[NSImage alloc] initWithContentsOfURL:newCollectionButtonImageURL]];
	
	if (success) {
		[[self newCollectionTitleField] setStringValue:@""];
	}
	
	[self setCreatingCollection:NO];
}

- (BOOL)_parseCollectionElements:(NSArray *)collectionElements merge:(BOOL)merge {
	static NSMenuItem * (^parseCollectionElement)(NSXMLElement *) = ^ NSMenuItem * (NSXMLElement *collectionElement) {
		NSString *collectionTitle = RMUploaderEmberStringValueForXPath(collectionElement, @"name", NULL);
		NSString *representedObject = slugForCollection(collectionElement);
		if (collectionTitle == nil || representedObject == nil) return nil;
		
		NSMenuItem *collectionItem = [[NSMenuItem alloc] initWithTitle:collectionTitle action:NULL keyEquivalent:@""];
		[collectionItem setRepresentedObject:representedObject];
		return collectionItem;
	};
	
	
	NSMenu *collectionsMenu = [[self collectionsPopupButton] menu];
	
	if (!merge || [self collectionsCount] == 0) {
		collectionsMenu = [[NSMenu alloc] init];
		[collectionsMenu addItemWithTitle:NoneLocalizedString action:NULL keyEquivalent:@""];
		[collectionsMenu addItem:[NSMenuItem separatorItem]];
		
		[self setCollectionsCount:0];
	}
	
	NSUInteger newCollectionsCount = [self collectionsCount];
	for (NSXMLElement *collectionElement in collectionElements) {
		NSMenuItem *collectionItem = parseCollectionElement(collectionElement);
		if (collectionItem == nil) continue;
		
		[collectionsMenu addItem:collectionItem];
		newCollectionsCount++;
	}
	
	BOOL parsedNewCollections = (newCollectionsCount != [self collectionsCount]);
	[self setCollectionsCount:newCollectionsCount];
	
	
	[[self collectionsPopupButton] setMenu:collectionsMenu];
	
	if ([self collectionsCount] != 0) {
		if (self.representedObject.collectionSlug != nil) {
			NSInteger selectedCollectionIndex = [[self collectionsPopupButton] indexOfItemWithRepresentedObject:self.representedObject.collectionSlug];
			[[self collectionsPopupButton] selectItemAtIndex:(selectedCollectionIndex != -1 ? selectedCollectionIndex : 0)];
			[self collectionsSelectionChanged:nil];
		}
	}
	[[self collectionsPopupButton] setEnabled:([self collectionsCount] != 0)];
	
	return parsedNewCollections;
}

#undef LoadingLocalisedString
#undef ErrorLoadingLocalisedString
#undef NoneLocalizedString

@end
