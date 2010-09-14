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

#import "RMUploaderEmberCredentialsConfigurationViewController.h"

#import "RMUploadKit/RMUploadKit.h"

#import "RMEmberContext.h"
#import "RMUploaderEmber.h"
#import "RMUploaderEmberCredentials.h"

#import "RMUploaderEmberConstants.h"
#import "RMUploaderEmberFunctions.h"

@interface RMUploaderEmberCredentialsConfigurationViewController ()
@property (readwrite, assign, getter=isAuthenticating) BOOL authenticating;
@property (assign) RMUploadURLConnection *loginConnection;
@end

@interface RMUploaderEmberCredentialsConfigurationViewController (Delegate) <RMUploadURLConnectionDelegate>

@end

@implementation RMUploaderEmberCredentialsConfigurationViewController

@dynamic representedObject;

@synthesize loginUsernameField, loginPasswordField;

@synthesize authenticating=_authenticating;
@synthesize loginConnection=_loginConnection;

- (IBAction)nextStage:(id)sender {
	BOOL (^validateTextField)(NSTextField *) = ^ (NSTextField *field) {
		[field validateEditing];
		if ([field stringValue] != nil && [[field stringValue] length] > 0) return YES;
		
		[self highlightErrorInView:field];
		
		NSDictionary *validationNotificationInfo = [NSDictionary dictionaryWithObjectsAndKeys:
													[NSError errorWithDomain:RMUploadKitBundleIdentifier code:RMUploadPresetConfigurationViewControllerErrorValidation userInfo:nil], RMUploadPresetConfigurationViewControllerDidCompleteErrorKey,
													nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:RMUploadPresetConfigurationViewControllerDidCompleteNotificationName object:self userInfo:validationNotificationInfo];
		
		return NO;
	};
	if (!validateTextField([self loginUsernameField])) return;
	if (!validateTextField([self loginPasswordField])) return;
	
	
	RMEmberContext *context = [RMUploaderEmber newContextWithCredentials:nil];
	[self setLoginConnection:[RMUploadURLConnection connectionWithRequest:[context requestLoginWithUsername:[[self loginUsernameField] stringValue] password:[[self loginPasswordField] stringValue]] delegate:self]];
	
	[self setAuthenticating:YES];
}

@end

@implementation RMUploaderEmberCredentialsConfigurationViewController (Delegate)

- (void)connection:(RMUploadURLConnection *)connection didFailWithError:(NSError *)error
{
	NSDictionary *notificationInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  error, RMUploadPresetConfigurationViewControllerDidCompleteErrorKey,
									  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:RMUploadPresetConfigurationViewControllerDidCompleteNotificationName object:self userInfo:notificationInfo];
	
	[self setAuthenticating:NO];
}

- (void)connection:(RMUploadURLConnection *)connection didCompleteWithData:(NSData *)data
{
	NSError *responseDocumentError = nil;
	NSXMLDocument *responseDocument = [RMEmberContext parseResponse:data error:&responseDocumentError];
	
	if (responseDocument == nil) {
		NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								   NSLocalizedStringFromTableInBundle(@"Cannot login to Ember", nil, [NSBundle bundleWithIdentifier:RMUploaderEmberBundleIdentifier], @"RMUploaderEmberCredentialsConfigurationViewController login error description"), NSLocalizedDescriptionKey,
								   NSLocalizedStringFromTableInBundle(@"Please check your credentials and try again.", nil, [NSBundle bundleWithIdentifier:RMUploaderEmberBundleIdentifier], @"RMUploaderEmberCredentialsConfigurationViewController login error recovery suggestion"), NSLocalizedFailureReasonErrorKey,
								   responseDocumentError, NSUnderlyingErrorKey,
								   nil];
		NSError *failError = [NSError errorWithDomain:RMUploaderEmberBundleIdentifier code:0 userInfo:errorInfo];
		
		[self connection:connection didFailWithError:failError];
		return;
	}
	
	[self.representedObject setToken:RMUploaderEmberStringValueForXPath(responseDocument, @"/response/user/user_token", NULL)];
	[self.representedObject setUserName:RMUploaderEmberStringValueForXPath(responseDocument, @"/response/user/username", NULL)];
	[self.representedObject setFullName:RMUploaderEmberStringValueForXPath(responseDocument, @"/response/user/fullname", NULL)];
	[self.representedObject setDateRegistered:[NSDate dateWithTimeIntervalSince1970:[RMUploaderEmberStringValueForXPath(responseDocument, @"/response/user/created", NULL) integerValue]]];
	[self.representedObject setAvatarLocation:[NSURL URLWithString:RMUploaderEmberStringValueForXPath(responseDocument, @"/response/user/avatars/avatar[size='l']", NULL)]];
	[self.representedObject setTotalImagesUploaded:[RMUploaderEmberStringValueForXPath(responseDocument, @"/response/user/total_images", NULL) integerValue]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RMUploadPresetConfigurationViewControllerDidCompleteNotificationName object:self];
	
	[self setAuthenticating:NO];
}

@end
