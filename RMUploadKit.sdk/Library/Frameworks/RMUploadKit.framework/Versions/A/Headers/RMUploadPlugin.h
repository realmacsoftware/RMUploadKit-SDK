//***************************************************************************

// Copyright (C) 2009 Realmac Software Ltd
//
// These coded instructions, statements, and computer programs contain
// unpublished proprietary information of Realmac Software Ltd
// and are protected by copyright law. They may not be disclosed
// to third parties or copied or duplicated in any form, in whole or
// in part, without the prior written consent of Realmac Software Ltd.

// Created by Keith Duncan on 25/03/2009

//***************************************************************************

#import <Foundation/Foundation.h>

@class RMUploadPreset;
@class RMUploadCredentials;

@class RMUploadPresetConfigurationViewController;
@class RMUploadMetadataConfigurationViewController;

/*!
	\file
 */

/*
 *	Plugin Bundle Info.plist Keys
 */

/*!
	\brief
	Info.plist key, this key is <b>required</b>. The framework will only load the plugin iff the framework <tt>CFBundleVersion</tt> number is greater than or equal to the value of this key.
	
	The value of this key is an <tt>NSString</tt>.
 */
extern NSString *const RMUploadPluginBundleMinimumFrameworkBundleVersionKey;

/*!
	\brief
	Info.plist key, this key is <b>required</b>.
	
	This value of this key is either, a single <tt>NSString</tt>, or an <tt>NSArray</tt> of <tt>NSString</tt> objects, of your preset class names.
  */
extern NSString *const RMUploadPluginDestinationTypesKey;

/*!
	\brief
	Used by <tt>+[RMUploadCredentials serviceURL]</tt> to construct it's result.
 */
extern NSString *const RMUploadPluginServiceHostKey;
/*!
	\brief
	Used by <tt>+[RMUploadCredentials serviceURL]</tt> to construct it's result.
 */
extern NSString *const RMUploadPluginServiceUseSSLKey;

/*
 *	Keys
 */

extern NSString *const RMUploadPluginCredentialsKey;
extern NSString *const RMUploadPluginPresetsKey;

/*!
	\brief
	You uploader bundle principal class.
	
	This class is the go-between for your presets, credentials and configuration view controllers respectively.
	
	The methods which return an <tt>NSViewController</tt> have assertions performed on the return value, if any of these assertions fail, unless otherwise documented, an exception will be thrown:
		- the view controller's view <b>must not</b> have a superview.
	
	When returning a view controller, make no assumptions about how the view will be used. It may be in a sheet in one version, and a view hierarchy the next. You <b>must not</b> call any methods to deal with closing windows etc. always post the relevant notifications.
	
	\details
	A plugin is structured like this:
	
\code
RMUploadPlugin	<->>	RMUploadPreset
(RMUploadPlugin	<->>	RMUploadCredentials)
(RMUploadPreset	<<->	RMUploadCredentials)
\endcode
	
	A plugin owns many presets, and optionally, many credentials.
	A preset optionally, has credentials.
 */
@interface RMUploadPlugin : NSObject

/*!
	\brief
	Designated initialiser.
	
	\details
	Plugins may be initialised concurrently, no guarantees are made about their initialisation environment.
	
	\param bundle
	The instance of NSBundle representing the plugin wrapper.
 */
- (id)initWithBundle:(NSBundle *)bundle;

/*!
	\brief
	The bundle the plugin was initialised with.
	
	If your plugin requires access to any resources, this method is a helper to get access to the <tt>NSBundle</tt> instance for your plugin. 
 */
@property (readonly, retain) NSBundle *bundle;

/*!
	\brief
	<tt>RMUploadCredentials</tt> objects.
 */
@property (nonatomic, readonly, copy) NSSet *credentials;

/*!
	\brief
	<tt>RMUploadPreset</tt> objects.
 */
@property (nonatomic, readonly, copy) NSSet *presets;

/*!
	\brief
	This method is <b>required</b> if your preset returns a class from <tt>+[RMUploadPreset credentialsClass]</tt>.
	
	Used to return an <tt>NSViewController</tt> whose view allows the user to configure the credentials, such as the username/password and or a token.
	
	You <b>must not</b> configure the <tt>plugin<->>credentials</tt> relationship in this method, this will be done for you if required.
	
	\details
	The <tt>RMUploadCredentials</tt> object to configure is set as the <tt>representedObject</tt> property.
 */
- (RMUploadPresetConfigurationViewController *)credentialsConfigurationViewControllerForCredentials:(RMUploadCredentials *)credentials;

/*!
	\brief
	This method is <b>required</b>.
	Unless, your preset has configured an <tt>RMUploadCredentials</tt> object, and you have no preset configuration options, in which case this method is <b>optional</b>.
	
	\details
	The <tt>RMUploadPreset</tt> object to configure is set as the <tt>representedObject</tt> property.
 */
- (RMUploadPresetConfigurationViewController *)presetConfigurationViewControllerForPreset:(RMUploadPreset *)preset;

/*!
	\brief
	This method is <b>optional</b>.
	
	\details
	If your plugin supports additional file metadata, this view will be placed in your plugin's section of the metadata view.
	The <tt>representedObject</tt> will be a KVC container, the contents of which will be passed in the <tt>uploadInfo</tt> to upload tasks.
	There is no guarantee that the object you 'configure', and the object passed to your <tt>RMUploadTask</tt> will be the same, just that they will have the same values you set.
	
	If you do add keys to this container they <b>must</b> be namespaced to your plugin.
 */
- (RMUploadMetadataConfigurationViewController *)additionalMetadataViewControllerForPresetClass:(Class)presetClass;

@end
