//
//  ___PROJECTNAME___Plugin.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "___PROJECTNAME___Plugin.h"

#import "___PROJECTNAME___Constants.h"

@implementation ___PROJECTNAME___Plugin

- (RMUploadPresetConfigurationViewController *)presetConfigurationViewControllerForPreset:(RMUploadPreset *)preset
{
	// Note: this can be your own subclass of NSViewController if you wish
	RMUploadPresetConfigurationViewController *controller = [[RMUploadPresetConfigurationViewController alloc] initWithNibName:@"PresetConfigurationView" bundle:[NSBundle bundleWithIdentifier:___PROJECTNAME___BundleIdentifier]];
	return controller;
}

@end
