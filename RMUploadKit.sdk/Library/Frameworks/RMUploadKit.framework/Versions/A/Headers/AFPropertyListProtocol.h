//
//  AFPropertyListProtocol.h
//  AmberFoundation
//
//  Created by Keith Duncan on 11/03/2007.
//  Copyright 2007 thirty-three. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
	\file
 */

/*!
	\brief
	Checks if an object can be serialised into a plist, returning NO where attempting to serlialise will fail and raise exception.
	
	\details
	Collections are checked recursively.
 */
extern BOOL AFIsPlistObject(id object);

/*!
	\brief
	Defines an <tt>NSCoding</tt> like method pair. It is designed to produce developer-readable archives.
 */
@protocol AFPropertyList <NSObject>
- (id)initWithPropertyListRepresentation:(id)propertyListRepresentation;
- (id)propertyListRepresentation;
@end

/*!
	\brief
	
 */
@interface NSArray (AFPropertyList) <AFPropertyList>

@end

/*!
	\brief
	
 */
@interface NSDictionary (AFPropertyList) <AFPropertyList>

@end

/*!
	\brief
	
 */
@interface NSURL (AFPropertyList) <AFPropertyList>

@end

/*!
	\brief
	Returns a property list object which combines the <tt>-propertyListRepresentation</tt> of <tt>object</tt> and the data required to reinstantiate it.
	The archive can be reinstantiated using <tt>AFPropertyListRepresenationUnarchive</tt>.
 */
extern CFPropertyListRef AFPropertyListRepresentationArchive(id <AFPropertyList> object);

/*!
	\brief
	This function unarchives a property list archive, returned from <tt>AFPropertyListRepresentationArchive()</tt>, back into a live object.
 */
extern id <AFPropertyList> AFPropertyListRepresentationUnarchive(CFPropertyListRef propertyListArchive);
