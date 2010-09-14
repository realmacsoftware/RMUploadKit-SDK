//
//  RMUploadDestinationViewController.h
//  RMUploadKit
//
//  Created by Keith Duncan on 24/09/2009.
//  Copyright 2009 Realmac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
	\file
 */

/*!
	\brief
	Post this once you have completed your work in <tt>-nextStage:</tt> to signal a change in the advancement status.
	
	\details
	If your validation succeeded, post it with an empty userInfo.
	If an error occurs, return it under the error <tt>RMUploadDestinationConfigurationViewControllerCompletionErrorKey</tt> to signal that the view cannot advance.
	
	If your error has domain RMUploadKitBundleIdentifier and code RMUploadPresetConfigurationViewControllerErrorValidation, the error isn't presented, the view doesn't advance and the 'next' button is re-enabled. Use this for a validation error. This error should be used in conjunction with <tt>-[RMUploadPresetConfigurationViewController highlightErrorInView:]</tt>.
 */
extern NSString *const RMUploadPresetConfigurationViewControllerDidCompleteNotificationName;
	/*!
		\brief
		An <tt>NSError</tt> object, included in the <tt>RMUploadPresetConfigurationViewControllerDidCompleteNotificationName</tt> <tt>userInfo</tt> dictionary.
	 */
	extern NSString *const RMUploadPresetConfigurationViewControllerDidCompleteErrorKey;

/*
 *	Keys
 */

extern NSString *const RMUploadPresetConfigurationViewControllerLocalisedAdvanceButtonTitleKey;

/*!
	\brief
	Base class for <tt>RMUploadCredentials</tt> and <tt>RMUploadPreset</tt> configuration view controllers.
	
	\details
	You view <b>must</b> be 287pt in width, there is no height restriction (within reason).
	Your subviews <b>should</b> have an appropriate autoresizing mask for the superview to be a different (larger) width.
 */
@interface RMUploadPresetConfigurationViewController : NSViewController

/*!
	\brief
	Observed and set as the 'next' button title.
	
	\details
	Intended for OAuth based credential view controllers so that they can title the button 'Authenticate' and change it to 'Confirm' after redirecting the user to the verification page in their browser.
 */
@property (readonly) NSString *localisedAdvanceButtonTitle;

/*!
	\brief
	Override this action message to perform any validation before proceeding. You <b>must</b> validate your credential/preset object here.
	
	Once you have completed your validation, post the <tt>RMUploadDestinationConfigurationViewControllerStageDidCompleteNotificationName</tt> notification to the <tt>+[NSNotificationCenter defaultCenter]</tt> on the main thread with self as the object.
	
	The default implementation simply posts the notification.
	
	If your validation returns an error include it in the notification dictionary.
	You can include a recovery attempter under the <tt>NSRecoveryAttempterErrorKey</tt> key.
		- If you include a recovery attempter, and recover from the error, configuration will continue as if no error had been returned in the first place.
		- If you include a recovery attempter, and don't recover from the error, configuration doesn't continue and the user is returned to the current configuration view controller.
 */
- (IBAction)nextStage:(id)sender;

/*
	View Controller Conveniences
	
		These will be called for you.
 */

- (void)viewWillDisappear:(BOOL)animated;

- (void)viewDidAppear:(BOOL)animated;

/*!
	\brief
	Highlights an error in, for example, a text field.
	
	\details
	The error will fade out after a short delay.
 */
- (void)highlightErrorInView:(NSView *)errorView;

/*!
	\brief
	Hides a previously present error arrow using <tt>-highlightErrorInView:</tt>.
 */
- (void)hideErrorArrow;

@end


@interface RMUploadPresetConfigurationViewController (Actions)

/*!
	\brief
	If implemented, a help button is shown in the configuration view.
 */
- (IBAction)showHelp:(id)sender;

@end
