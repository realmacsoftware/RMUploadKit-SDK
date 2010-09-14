//
//  RMUploadErrors.h
//  RMUploadKit
//
//  Created by Keith Duncan on 05/08/2010.
//  Copyright 2010 Realmac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
	\brief
	These correspond to the <tt>RMUploadKitBundleIdentifier</tt> domain.
 */
enum {
	/* */
	RMUploadErrorUnknown = 0,
	
	/* [-100, -199] */
	// Note: re-enable configuration view buttons after validation failed, this error isn't presented
	RMUploadPresetConfigurationViewControllerErrorValidation = -100,
};
typedef NSInteger RMUploadKitErrorCode;
