//
//  DSMultipartFormDocument.h
//  Courier
//
//  Created by Keith Duncan on 29/04/2010.
//  Copyright 2010 Realmac Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RMUploadKit/RMUploadAvailability.h"

#if RMUPLOADKIT_FRAMEWORK_VERSION_MAX_ALLOWED >= RMUPLOADKIT_FRAMEWORK_VERSION_3
/*!
	\brief
	Base class for multipart documents.
 */
@interface RMUploadMultipartDocument : NSObject

@end
#endif // RMUPLOADKIT_FRAMEWORK_VERSION_MAX_ALLOWED >= RMUPLOADKIT_FRAMEWORK_VERSION_3

/*!
	\brief
	This format is described in RFC 2388 <a href="http://tools.ietf.org/html/rfc2388">http://tools.ietf.org/html/rfc2388</a>.
	
	\details
	The order you add values in is unpreserved.
 */
@interface RMUploadMultipartFormDocument : 
#if RMUPLOADKIT_FRAMEWORK_VERSION_MAX_ALLOWED >= RMUPLOADKIT_FRAMEWORK_VERSION_3
	RMUploadMultipartDocument
#else
	NSObject
#endif

/*!
	\brief
	Returns the value associated with a given fieldname.
 */
- (NSString *)valueForField:(NSString *)fieldname;

/*!
	\brief
	The fieldname should be unique per document, setting a value for an existing fieldname will overwrite the previous value.
	
	\details
	This will clear any files added to the same fieldname.
	
	\param value
	Can be nil, will remove existing value.
	
	\param fieldname
	Cannot be nil.
 */
- (void)setValue:(NSString *)value forField:(NSString *)fieldname;

/*!
	\brief
	Unordered collection of previously added URLs using <tt>-addFileByReferencingURL:withFilename:toField:</tt>.
 */
- (NSSet *)fileLocationsForField:(NSString *)fieldname;

/*!
	\brief
	Form documents support multiple files per-fieldname.
	
	\details
	Multiple files per fieldname are supported.
	This will clear any string values set for the same fieldname.
	
	\param filename
	This is optional, excluding it will use the last path component.
	
	\param fieldname
	To leave the 'name' value blank in the generated document, pass <tt>+[NSNull null]</tt> for the fieldname.
 */
- (void)addFileByReferencingURL:(NSURL *)location withFilename:(NSString *)filename toField:(NSString *)fieldname;

/*!
	\brief
	Serialise the field values into a data object.
	
	\param contentTypeRef
	This is the MIME type of the output. It contains the generated multipart boundary.
	
	\returns
	Returns NO if any of the file parts cannot be loaded.
	Returns YES on success.
 */
- (BOOL)getFormData:(NSData **)dataRef contentType:(NSString **)contentTypeRef;

@end

#if RMUPLOADKIT_FRAMEWORK_VERSION_MAX_ALLOWED >= RMUPLOADKIT_FRAMEWORK_VERSION_3
/*!
	\brief
	This format is described in RFC 2387 <a href="http://tools.ietf.org/html/rfc2387">http://tools.ietf.org/html/rfc2387</a>.
	Though it ommits support for the 'start' and 'type' parameters of the 'Content-Type' header.
	
	\details
	The order you add data in is unpreserved.
 */
@interface RMUploadMultipartRelatedDocument : RMUploadMultipartDocument

/*!
	\brief
	Designated Initialiser.
 */
- (id)init;

/*!
	\brief
	If your document is referrential, use this initialiser to specify the index content identifier.
 */
- (id)initWithStartContentIdentifier:(NSString *)startContentIdentifier;

/*!
	\brief
	The data will appear in the serialised document.
	
	\param contentType
	Defaults to 'application/octet-stream' if nil.
	
	\param contentIdentifier
	Pass nil to omit the 'Content-ID' header.
	A contentIdentifier must be unique per document, adding another part with the same content identifer will throw an exception.
 */
- (void)addPartWithData:(NSData *)data withContentType:(NSString *)contentType forContentIdentifier:(NSString *)contentIdentifier;

/*!
	\brief
	The content type is inferred.
	
	\param contentIdentifier
	Pass nil to omit the 'Content-ID' header.
	A contentIdentifier must be unique per document, adding another part with the same content identifer will throw an exception.
 */
- (void)addPartByReferencingContentsOfURL:(NSURL *)location forContentIdentifier:(NSString *)contentIdentifier;

/*!
	\brief
	Removes a previously added part for the content identifier.
 */
- (void)removePartForContentIdentifier:(NSString *)contentIdentifier;

/*!
	\brief
	Serialise the document into a data object.
	
	\param contentTypeRef
	This is the MIME tpye of the output./ It contains the generated multipart boundary.
 */
- (BOOL)getData:(NSData **)dataRef contentType:(NSString **)contentTypeRef;

@end
#endif // RMUPLOADKIT_FRAMEWORK_VERSION_MAX_ALLOWED >= RMUPLOADKIT_FRAMEWORK_VERSION_3
