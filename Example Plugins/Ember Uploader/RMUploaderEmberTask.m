//***************************************************************************

// Copyright (C) 2009 Realmac Software Ltd
//
// These coded instructions, statements, and computer programs contain
// unpublished proprietary information of Realmac Software Ltd
// and are protected by copyright law. They may not be disclosed
// to third parties or copied or duplicated in any form, in whole or
// in part, without the prior written consent of Realmac Software Ltd.

// Created by Danny Greg on 27/7/2009 

//***************************************************************************

#import "RMUploaderEmberTask.h"

#import "RMUploadKit/RMUploadKit.h"

#import "RMUploaderEmber.h"
#import "RMUploaderEmberCredentials.h"
#import "RMUploaderEmberPreset.h"
#import "RMEmberContext.h"

#import "RMUploaderEmberConstants.h"
#import "RMUploaderEmberFunctions.h"

NSString *const RMUploaderEmberMetadataImageTypeKey = @"emberImageType";
NSString *const RMUploaderEmberMetadataImageRatingKey = @"emberImageRating";

@interface RMUploaderEmberTask () <RMUploadURLConnectionDelegate>
@property (readonly) RMUploaderEmberPreset *destination;

@property (assign) RMEmberContext *context;

enum {
	RMUploaderEmberTaskStateNone,
	RMUploaderEmberTaskStateRequestUpload,
	RMUploaderEmberTaskStateRequestSetMetadata,
};
typedef NSUInteger RMUploaderEmberTaskState;
@property (assign) NSUInteger state;

- (void)_continueUpload;

- (void)_requestUpload;
@property (retain) RMUploadURLConnection *uploadConnection;
@property (copy) NSString *imageIdentifier;

- (void)_requestSetMetadata;
@property (assign) NSMutableSet *metadataConnections;

- (void)_completeWithError:(NSError *)error;
- (void)_postCompletionNotification;
@end

@implementation RMUploaderEmberTask

@dynamic destination;

@synthesize context=_context;

@synthesize state=_state;

@synthesize uploadConnection=_uploadConnection;
@synthesize imageIdentifier=_imageIdentifier;

@synthesize metadataConnections=_metadataConnections;

- (void)upload {
	[self setContext:[RMUploaderEmber newContextWithCredentials:[[self destination] authentication]]];
	
	[self _continueUpload];
}

- (void)cancel {
	@synchronized (self) {
		[super cancel];
		
		[[self uploadConnection] cancel];
		[[self metadataConnections] makeObjectsPerformSelector:@selector(cancel)];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RMUploadTaskDidCompleteNotificationName object:self];
}

- (void)_continueUpload {
	@synchronized (self) {
		if ([self isCancelled]) return;
		
		switch ([self state]) {
			case RMUploaderEmberTaskStateNone:;
				[self setState:RMUploaderEmberTaskStateRequestUpload];
				[self _requestUpload];
				return;
			case RMUploaderEmberTaskStateRequestUpload:;
				[self setState:RMUploaderEmberTaskStateRequestSetMetadata];
				[self _requestSetMetadata];
				return;
			case RMUploaderEmberTaskStateRequestSetMetadata:;
				[self _postCompletionNotification];
				return;
		}
	}
}

- (void)_requestUpload {
	NSURLRequest *uploadRequest = [[self context] requestUpload:[self.uploadInfo valueForKey:RMUploadFileURLKey]
													   withName:[self.uploadInfo valueForKey:RMUploadFileTitleKey]
													description:[self.uploadInfo valueForKey:RMUploadFileDescriptionKey]
														   tags:[self.uploadInfo valueForKey:RMUploadFileTagsKey]
														   date:[self.uploadInfo valueForKey:RMUploadFileOriginalDateKey]
													originalURL:[self.uploadInfo valueForKey:RMUploadFileOriginalURLKey]
														 rating:[self.uploadInfo valueForKey:RMUploaderEmberMetadataImageRatingKey]
													  imageType:[self.uploadInfo valueForKey:RMUploaderEmberMetadataImageTypeKey]
														privacy:self.destination.privacyLevel];
	[self setUploadConnection:[RMUploadURLConnection connectionWithRequest:uploadRequest delegate:self]];
}

- (void)connection:(RMUploadURLConnection *)connection uploadProgressed:(float)currentProgress {
	NSDictionary *notificationInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithDouble:currentProgress], RMUploadTaskProgressCurrentKey,
									  [NSNumber numberWithDouble:1.], RMUploadTaskProgressTotalKey,
									  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:RMUploadTaskDidReceiveProgressNotificationName object:self userInfo:notificationInfo];
}

- (void)connection:(RMUploadURLConnection *)connection didFailWithError:(NSError *)error {
	[self _completeWithError:error];
}

- (void)connection:(RMUploadURLConnection *)connection didCompleteWithData:(NSData *)data {
	NSError *responseDocumentError = nil;
	NSXMLDocument *responseDocument = [RMEmberContext parseResponse:data error:&responseDocumentError];
	
	if (responseDocument == nil) {
		[self _completeWithError:responseDocumentError];
		return;
	}
	
	NSError *newImageIdentifierError = nil;
	NSString *newImageIdentifier = RMUploaderEmberStringValueForXPath(responseDocument, @"response/item/token", &newImageIdentifierError);
	
	if (newImageIdentifier == nil) {
		[self connection:connection didFailWithError:nil];
		return;
	}
	
	[self setImageIdentifier:newImageIdentifier];
	
	
	NSError *locationXPathError = nil;
	NSString *imageLocation = RMUploaderEmberStringValueForXPath(responseDocument, @"/response/item/permalink", &locationXPathError);
	
	NSDictionary *notificationInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									  [NSURL URLWithString:imageLocation], RMUploadTaskResourceLocationKey,
									  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:RMUploadTaskDidFinishTransactionNotificationName object:self userInfo:notificationInfo];
	
	
	[self _continueUpload];
}

- (void)_requestSetMetadata {
	[self setMetadataConnections:[NSMutableSet set]];
	
	void (^checkForCompletion)(void) = ^ {
		if ([[self metadataConnections] count] != 0) return;
		
		[self _continueUpload];
	};
	
	void (^addMetadataConnectionForRequest)(NSURLRequest *) = ^ (NSURLRequest *request) {
		__block RMUploadURLConnection *connection = nil;
		connection = [RMUploadURLConnection connectionWithRequest:request completionBlock:^ (NSData *responseData, NSError *error) {
			NSError *responseDocumentError = nil;
			NSXMLDocument *responseDocument = [RMEmberContext parseResponse:responseData error:&responseDocumentError];
			
			if (responseDocument == nil) {
				NSDictionary *notificationInfo = [NSDictionary dictionaryWithObjectsAndKeys:
												  responseDocumentError, RMUploadTaskErrorKey,
												  nil];
				[[NSNotificationCenter defaultCenter] postNotificationName:RMUploadTaskDidFinishTransactionNotificationName object:self userInfo:notificationInfo];
			}
			
			[[self metadataConnections] removeObject:connection];
			checkForCompletion();
		}];
		[[self metadataConnections] addObject:connection];
	};
	
	if ([[self destination] collectionSlug] != nil) {
		addMetadataConnectionForRequest([[self context] requestAddImage:[self imageIdentifier] toCollection:[[self destination] collectionSlug]]);
	}
	if ([[self destination] categorySlug] != nil) {
		addMetadataConnectionForRequest([[self context] requestSubmitImage:[self imageIdentifier] toCategory:[[self destination] categorySlug]]);
	}
	
	checkForCompletion();
}

- (void)_completeWithError:(NSError *)error {
	if (error == nil) {
		NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								   nil];
#warning complete this error
		error = [NSError errorWithDomain:RMUploaderEmberBundleIdentifier code:0 userInfo:errorInfo];
	}
	
	NSDictionary *notificationInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  error, RMUploadTaskErrorKey,
									  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:RMUploadTaskDidFinishTransactionNotificationName object:self userInfo:notificationInfo];
	
	[self _postCompletionNotification];
}

- (void)_postCompletionNotification {
	[[NSNotificationCenter defaultCenter] postNotificationName:RMUploadTaskDidCompleteNotificationName object:self];
}

@end
