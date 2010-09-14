//***************************************************************************

// Copyright (C) 2009 Realmac Software Ltd
//
// These coded instructions, statements, and computer programs contain
// unpublished proprietary information of Realmac Software Ltd
// and are protected by copyright law. They may not be disclosed
// to third parties or copied or duplicated in any form, in whole or
// in part, without the prior written consent of Realmac Software Ltd.

// Created by Danny Greg on 24/7/2009 

//***************************************************************************

#import <Cocoa/Cocoa.h>

#import "RMUploadKit/RMUploadAvailability.h"

/*!
	\file
 */

//***************************************************************************

typedef void (^RMUploadURLConnectionCompletionBlock)(NSData *responseData, NSError *responseError);

//***************************************************************************

@protocol RMUploadURLConnectionDelegate;

/**
	\brief
	A replacement for <tt>NSURLConnection</tt>, wrapping it with a different API. 
	
	It uses a similar delegate system as NSURLConnection but provides different information as you go.
*/
@interface RMUploadURLConnection : NSObject

/*!
	\brief
	Convenience constructor.
 */
+ (RMUploadURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id <RMUploadURLConnectionDelegate>)delegate;

/*!
	\brief
	Convenience constructor.
 */
+ (RMUploadURLConnection *)connectionWithRequest:(NSURLRequest *)request completionBlock:(RMUploadURLConnectionCompletionBlock)completionBlock;

/*!
	\brief
	The connection's delegate.
 */
@property (assign) id delegate;

/*!
	\brief
	A block called when the connection completes, either successfully or unsuccessfully.
	
	\details
	Both this block and the delegate method <tt>-connection:didFailWithError:</tt> or <tt>-connection:didCompleteWithData:</tt> are invoked on connection completion.
 */
@property (copy) RMUploadURLConnectionCompletionBlock completionBlock;

/*!
	\brief
	Set to YES when the connection has finished or has received an error.
 */
@property (readonly) BOOL completed;

/*!
	\brief
	Convenience property to associate any userInfo, handy for delegate callbacks.
 */
@property (retain) id userInfo;

/*!
	\brief
	Sends the provided request, the delegate will begin to receive notifications.
	
	\param request
	An <tt>NSURLRequest</tt> that you wish to send.
*/
- (void)sendURLRequest:(NSURLRequest *)request;

/*!
	\brief
	Cancels the connection.
	
	\details
	The <tt>delegate</tt> will not receive any further callbacks.
	The <tt>completionBlock</tt> will not be invoked.
*/
- (void)cancel;

@end

/*!
	\brief
	The delegate for <tt>RMUploadURLConnection</tt>.
*/
@protocol RMUploadURLConnectionDelegate <NSObject>

 @optional

/*!
	\brief
	Called periodically as a download progresses.
	
	\param connection
	The <tt>RMUploadURLConnection</tt> sending the message.
	
	\param currentProgress
	The current progress, between 0.0 and 1.0.
 */
- (void)connection:(RMUploadURLConnection *)connection downloadProgressed:(float)currentProgress;

/*!
	\brief
	Called periodically as an upload progresses.
	
	\param connection
	The <tt>RMUploadURLConnection</tt> sending the message.
	
	\param currentProgress
	The current progress, between 0.0 and 1.0.
 */
- (void)connection:(RMUploadURLConnection *)connection uploadProgressed:(float)currentProgress;

 @required

/*!
	\brief
	Sent if the connection fails, providing an NSError with the cause.
	
	\param connection
	The <tt>RMUploadURLConnection</tt> sending the message.
	
	\param error
	An <tt>NSError</tt> object representing the error that caused the connection to fail.
 */
- (void)connection:(RMUploadURLConnection *)connection didFailWithError:(NSError *)error;

/*!
	\brief
	Sent once the connection completes successfully.
	
	\param connection
	The <tt>RMUploadURLConnection</tt> sending the message.
	
	\param data
	The response <tt>NSData</tt> returned by the server.
 */
- (void)connection:(RMUploadURLConnection *)connection didCompleteWithData:(NSData *)data;

 @optional

/**
	\brief
	Behaves identically to the <tt>NSURLConnection</tt> delegate equivalent.
 */
- (void)connection:(RMUploadURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

/** 
	\brief
	Behaves identically to the <tt>NSURLConnection</tt> delegate equivalent.
 */
- (void)connection:(RMUploadURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end


/*!
	\brief
	These methods are deprecated and <b>should not</b> be used.
 */
@interface RMUploadURLConnection (RMUploadDeprecated)

/*!
	\brief
	This method is deprecated, use <tt>+[NSURLRequest getRequestWithParameters:toURL:]</tt> instead.
 */
- (void)sendGetRequestWithParameters:(NSDictionary *)params toURL:(NSURL *)url RMUPLOADKIT_DEPRECATED_ATTRIBUTE;

/*!
	\brief
	This method is deprecated, use <tt>+[NSURLRequest filePostRequestWithParameters:toURL:]</tt> instead.
 */
- (void)sendFilePostRequestWithParameters:(NSArray *)params toURL:(NSURL *)url RMUPLOADKIT_DEPRECATED_ATTRIBUTE;

/*!
	\brief
	This method is deprecated, use <tt>+[NSURLRequest postRequestWithParameters:toURL:]</tt> instead.
 */
- (void)sendPostRequestWithParameters:(NSDictionary *)params toURL:(NSURL *)url RMUPLOADKIT_DEPRECATED_ATTRIBUTE;

@end
