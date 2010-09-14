//***************************************************************************

// Copyright (C) 2009 Realmac Software Ltd
//
// These coded instructions, statements, and computer programs contain
// unpublished proprietary information of Realmac Software Ltd
// and are protected by copyright law. They may not be disclosed
// to third parties or copied or duplicated in any form, in whole or
// in part, without the prior written consent of Realmac Software Ltd.

// Created by Danny Greg on 06/08/2010. 

//***************************************************************************

#import <Cocoa/Cocoa.h>

//***************************************************************************

/*!
	\file
 */

/*
	\brief
	Used in the parameter dictionaries of a POST request, for the filename. (<tt>NSString</tt>)
	This can be omitted if the parameter is not file data.
 */
extern NSString *const RMPOSTFilenameKey;

/*!
	\brief
	Used to specify a "Content-Type" in a POST request, for the parameter.
	This is only used for if the parameter dictionary also contains a value for <tt>RMPOSTFilenameKey</tt>, otherwise the MIME is implied 'text/plain'.
 */
extern NSString *const RMPOSTContentTypeKey;

/*!
	\brief
	Used in the parameter dictionaries of a POST request, for the data itself.
	This <b>must not</b> be omitted from the parameter dictionary.
	The value can be an <tt>NSData</tt>, <tt>NSString</tt>, <tt>NSURL</tt> or <tt>NSNumber</tt> object.
 */
extern NSString *const RMPOSTDataKey;

/*!
	\brief
	Used in the parameter dictionaries of a POST request, for the fieldname.
	This <b>must not</b> be omitted from the parameter dictionary.
 */
extern NSString *const RMPOSTFieldNameKey;

//***************************************************************************

/*!
	\brief
	Provides convenience methods for generating <tt>NSURLRequest</tt> objects, for common web service 
 */
@interface NSURLRequest (RMUploadAdditions)

/*!
	\brief
	Builds a GET request from the URL and parameters provided.
	
	The parameters are appended to the end of the URL as a query string.
	
	\param parameters
	<tt>NSDictionary</tt> expecting key/value pairs of strings, where each key/value pair is for a key in the web service that you are sending to.
	You can pass <tt>+[NSNull null]</tt> for the value if it has none.
	
	\param URL
	The base URL for the request.
 */
+ (NSURLRequest *)getRequestWithParameters:(NSDictionary *)parameters toURL:(NSURL *)URL;

/*!
	\brief
	Builds a POST request from the URL and parameters provided.
	
	Useful for simple POST requests that do not require files.
	
	This encodes the parameters, sets the body of the request and sets the 'Content-Type' header.
	
	\param parameters
	<tt>NSDictionary</tt> of key/value pairs.
	Unlike <tt>+getRequestWithParameters:</tt> the value does not have to be an <tt>NSString</tt>, it can be any class of object supported by <tt>RMPOSTDataKey</tt>.
	
	\param URL
	The base URL for the request.
 */
+ (NSURLRequest *)postRequestWithParameters:(NSDictionary *)parameters toURL:(NSURL *)URL;

/*!
	\brief
	Build a POST request for uploading a file.
	You build up an <tt>NSArray</tt> of parameter <tt>NSDictionary</tt> objects containing the keys described below to describe the data sent for each field in the request.
	
	\param parameters
	<tt>NSArray</tt> of <tt>NSDictionary</tt> objects containing:
		<tt>RMPOSTFilenameKey</tt>
		<tt>RMPOSTDataKey</tt>
		<tt>RMPOSTFieldNameKey</tt>
	
	\param URL
	The base URL for the request.
 */
+ (NSURLRequest *)filePostRequestWithParameters:(NSArray *)parameters toURL:(NSURL *)URL;

@end
