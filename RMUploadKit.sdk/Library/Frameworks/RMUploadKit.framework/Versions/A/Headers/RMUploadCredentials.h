//***************************************************************************

// Copyright (C) 2009 Realmac Software Ltd
//
// These coded instructions, statements, and computer programs contain
// unpublished proprietary information of Realmac Software Ltd
// and are protected by copyright law. They may not be disclosed
// to third parties or copied or duplicated in any form, in whole or
// in part, without the prior written consent of Realmac Software Ltd.

// Created by Keith Duncan on 26/03/2009

//***************************************************************************

#import <Foundation/Foundation.h>

#import "RMUploadKit/AFPropertyListProtocol.h"

@class RMUploadPlugin;
@class RMUploadPreset;

/*!
	\file
 */

extern NSString *const RMUploadCredentialsDirtyKey;

extern NSString *const RMUploadCredentialsUserIdentifierKey;

/*!
	\brief
	Represents a set of user credentials, most commonly for an account on a web service.
 */
@interface RMUploadCredentials : NSObject <AFPropertyList>

/*!
	\brief
	Initialise credentials from a serialised representation.
	
	We provide you with the representation that you return in <tt>propertyListRepresentation</tt> to hand off to the framework for saving.
 
	If you follow the <tt>propertyListRepresentation</tt> example implementation, be sure to pass only the superclass representation to the superclass inititializer.
	
	An example implementation would be:
\code
- (id)initWithPropertyListRepresentation:(id)values {
	id superRepresentation = [values objectForKey:@"super"];

	self = [super initWithPropertyListRepresentation:superRepresentation];
	if (self == nil) return nil;
	
	[self setProperty:[values objectForKey:@"myKey"]];
	
	return self;
}
\endcode
 
	\param values
	The property list representation that was returned from <tt>propertyListRepresentation</tt>.
 */
- (id)initWithPropertyListRepresentation:(id)values;

/*!
	\brief
	A representation of the instance that can be saved to a plist.
	
	In order to save accounts they will be turned into a plist, therefore here you need to return a representation of your object that can be saved safely into one. You must also call the super's implementation at the top of the method.
	
	It is essential that you include, and namespace the representation of the superclass. You <b>must not</b> assume the class of the superclass' representation, simply that it is suitable for inclusion in a property list written to disk.
	
	An example implementation would be:
\code
- (id)propertyListRepresentation {
	id superRepresentation = [super propertyListRepresentation];

	NSMutableDictionary *propertyListRepresentation = [NSMutableDictionary dictionary];
	[propertyListRepresentation setObject:superRepresentation forKey:@"super"];

	[propertyListRepresentation setValue:[self property] forKey:@"myKey"];

	return propertyListRepresentation;
}
\endcode
 */
- (id)propertyListRepresentation;

/*!
	\brief
	The plugin that the account belongs to. This is a to-one relationship.
 */
@property (readonly, assign) RMUploadPlugin *plugin;

/*!
	\brief
	Overriding this is <b>required</b>, an exception will be thrown if not implemented by your subclass.
	This should be a string which is meaningful to the user, suitable for showing them as a later authentication choice.
	
	\details
	You should use their username or email address, depending on how they login.
	Avoid using their name, the user may have more than one account on your web service.
 */
@property (readonly) NSString *userIdentifier;

@end
