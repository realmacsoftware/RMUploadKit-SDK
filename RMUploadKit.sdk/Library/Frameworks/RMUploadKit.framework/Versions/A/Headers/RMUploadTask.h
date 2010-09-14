//***************************************************************************

// Copyright (C) 2009 Realmac Software Ltd
//
// These coded instructions, statements, and computer programs contain
// unpublished proprietary information of Realmac Software Ltd
// and are protected by copyright law. They may not be disclosed
// to third parties or copied or duplicated in any form, in whole or
// in part, without the prior written consent of Realmac Software Ltd.

// Created by Danny Greg on 25/3/2009 

//***************************************************************************

#import <Cocoa/Cocoa.h>

@class RMUploadPreset;
@class RMUploadCredentials;

/*!
	\file
 */

/*
	Notifications
 */

/*!
	\brief
	Allows you to update the status text outside of the established notification pattern.
	
	The <tt>userInfo</tt> dictionary should contain the <tt>RMUploadTaskStatusInfoKey</tt>.
 */
extern NSString *const RMUploadTaskUpdateStatusTextNotificationName;

/*!
    \brief
	An upload task should post this notification whenever it receives a progress update. If this is never posted, the framework will assume an indeterminate upload is taking place.
	This notification <b>must</b> be posted using the <tt>+[NSNotificationCenter defaultCenter]</tt> object. The object for the notification is the <tt>RMUploadTask</tt> posting the notification.
		The object for the notification should be the <tt>RMUploadTask</tt> posting the notification.
		The userinfo dictionary should also contain the following keys and values:
			
			<tt>RMUploadTaskProgressTotalKey</tt> : This should remain the same throughout the upload. (<tt>+[NSNumber numberWithDouble:]</tt>)
			<tt>RMUploadTaskProgressCurrentKey</tt> : The amount of progress that has already happened, this can be measured by any unit you like but should be the same as the one used for <tt>RMUploadTaskProgressTotalKey</tt>. (<tt>+[NSNumber numberWithDouble:]</tt>)
*/
extern NSString *const RMUploadTaskDidReceiveProgressNotificationName;

	extern NSString *const RMUploadTaskProgressTotalKey;
	extern NSString *const RMUploadTaskProgressCurrentKey;

/*!
    \brief
	An upload task should post this whenever it has finished uploading each object to the target. <b>Not</b> when it has completed.
	This notification <b>must</b> be posted using the <tt>+[NSNotificationCenter defaultCenter]</tt> object. The object for the notification is the <tt>RMUploadTask</tt> posting the notification.
	
	The <tt>userInfo</tt> dictionary should also contain the following keys:
		<tt>RMUploadTaskResourceLocationKey</tt> : where the data was uploaded to. (<tt>NSURL</tt>)
		<tt>RMUploadTaskErrorKey</tt> : an <tt>NSError</tt> object, indicating what when wrong with the upload. (<tt>NSError</tt>)
	
	A single task might initiate more than one transaction, a task may post several of these.
	You may post this notification to indicate additional errors, such as failure to add a photo to a group or photoset.
*/
extern NSString *const RMUploadTaskDidFinishTransactionNotificationName;

	extern NSString *const RMUploadTaskResourceLocationKey;
	extern NSString *const RMUploadTaskErrorKey;

/*!
    \brief
	The upload task should post this once it has at least attempted to perform it's transactions.
	This will vary from task to task, for instance an example Flickr task will first first attempt to upload the image, if that fails it will post the completion notification including the error.
	If the upload completed it may then attempt to add the image to a group or photoset, these may fail; but don't indicate that the upload failed completely.
	
	This notification <b>must</b> be posted using the <tt>+[NSNotificationCenter defaultCenter]</tt> object. The object for the notification is the <tt>RMUploadTask</tt> posting the notification.
	This notification doesn't indicate that the task <em>succeeded</em> just that it completed.
	
	This notification <b>must</b> also be posted once you have cancelled.
*/
extern NSString *const RMUploadTaskDidCompleteNotificationName;

/*!
	\brief
	An <tt>NSString</tt>, it can be passed in the <tt>userInfo</tt> dictionary of any task notification.
	This may be displayed in the interface to let the user know what's happening.
	Pass <tt>+[NSNull null]</tt> to clear the previous message.
	The value should be localised.
 */
extern NSString *const RMUploadTaskStatusInfoKey;

/*
	File Constants
 */

/*!
	\brief
	The URL of the file to be uploaded. (<tt>NSURL</tt>)
 */
extern NSString *const RMUploadFileURLKey;

/*!
	\brief
	The title of the file to be uploaded. (<tt>NSString</tt>)
 */
extern NSString *const RMUploadFileTitleKey;

/*!
	\brief
	The date that the file to be uploaded was originally created. (<tt>NSDate</tt>)
 */
extern NSString *const RMUploadFileOriginalDateKey;

/*!
	\brief
	If the file represents a web site in some form, this key is that URL. (<tt>NSURL</tt>)
 */
extern NSString *const RMUploadFileOriginalURLKey;

/*!
	\brief
	The user's description of the file. (<tt>NSString</tt>)
 */
extern NSString *const RMUploadFileDescriptionKey;

/*!
	\brief
	Tags associated with the file. (<tt>NSArray</tt> of <tt>NSString</tt> objects)
 */
extern NSString *const RMUploadFileTagsKey;

/*
	Task Object
 */

/*!
	\brief
	An upload task encapsulates an upload transaction with the target destination. This includes not only the upload of the file itself, but also any additional transactions with the destination to set any relevant metadata.
	
	All upload tasks must implement the <tt>upload</tt> method. It is called by the when it is this task's turn to upload.
	
	The object is expected to notify the framework with <tt>RMUploadTaskDidReceiveProgressNotificationName</tt>, <tt>RMUploadTaskFinishedUploadingNotificationName</tt> and <tt>RMUploadTaskDidCompleteNotificationName</tt> notifications.
*/
@interface RMUploadTask : NSObject

/*!
    \brief
	Designated Initialiser.
	
    \param destination
	The <tt>RMUploadPreset</tt> which should be used for configuration and <tt>RMUploadCredentials</tt> should they be needed.
	
	\param uploadInfo
	The data and metadata to upload. It is the plugin's responsibiltiy to check for nil values and what keys the object contains. It contains any keys set in your metadata view and any of the following default keys:
	
		- <tt>RMUploadFileURLKey</tt> : The location of the file to be uploaded on disk. (<tt>NSURL</tt>)
		- <tt>RMUploadTitleKey</tt> : The title of the file to be uploaded. (<tt>NSString</tt>)
		- <tt>RMUploadOriginalDateKey</tt> : This is the date when the image was taken/snapped/modified. For example, in Flickr's "date taken" field you would pass this value. (<tt>NSDate</tt>)
		- <tt>RMUploadOriginalURLKey</tt> : If the file is a websnap, this will be passed as the URL of where the websnap was taken. (<tt>NSURL</tt>)
		- <tt>RMUploadDescriptionKey</tt> : Any additional comments provided by the user. Such as the "description" field in LittleSnapper. (<tt>NSString</tt>)
		- <tt>RMUploadTagsKey</tt> : Tags associated with the file. (<tt>NSArray</tt> of <tt>NSString</tt> objects.)
*/
- (id)initWithPreset:(RMUploadPreset *)destination uploadInfo:(id)uploadInfo;

/*!	
	\brief
	The <tt>destination</tt> passed to the initialiser.
 */
@property (readonly) RMUploadPreset *destination;

/*!
	\brief
	The <tt>uploadInfo</tt> passed to the initialiser.
	Values should be obtained using <tt>-[NSObject valueForKey:]</tt>.
 */
@property (readonly) id uploadInfo;

/*!
    \brief
	The central method to the class.
	
	Ensure, that you are posting the correct notifications. 
	
	A thread local run loop will be available when this method is called, you <b>should</b> use <tt>+[NSRunLoop currentRunLoop]</tt> and are highly discouraged from scheduling on the main run loop or creating your own background thread.
	Avoid libraries that create background threads or perform synchronous networking.
	You <b>must not</b> recursively service the run loop.
 */
- (void)upload;

/*!
    \brief
	This should immediately cease any uploading that the task is performing.
	You are <em>strongly</em> encouraged to override this method and teardown your connections.
	
	If overridden, ensure you call <tt>super</tt>, and then post the <tt>RMUploadTaskDidCompleteNotificationName</tt> notification once you have completed your teardown.
*/
- (void)cancel;

/*!
	\brief
	Set when the <tt>-cancel</tt> message is received.
 */
@property (readonly, getter=isCancelled) BOOL cancelled;

@end
