//*******************************************************************************

// Copyright (c) 2010 Realmac Software

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// Created by Danny Greg on 14/9/2010

//*******************************************************************************

#import <Foundation/Foundation.h>

extern NSString *const RMEmberErrorDomain;

/*!
	@brief
	
 */
@interface RMEmberContext : NSObject

- (id)initWithServiceURL:(NSURL *)serviceURL APIKey:(NSString *)APIKey;
- (void)authenticateWithToken:(NSString *)authenticationToken;

+ (NSXMLDocument *)parseResponse:(NSData *)response error:(NSError **)errorRef;

- (NSURLRequest *)requestLoginWithUsername:(NSString *)username password:(NSString *)password;

- (NSURLRequest *)requestUpload:(NSURL *)imageLocation withName:(NSString *)name description:(NSString *)description tags:(NSArray *)tags date:(NSDate *)date originalURL:(NSURL *)originalURL rating:(NSNumber *)rating imageType:(NSString *)imageType privacy:(NSString *)privacy;

- (NSURLRequest *)requestPrivacy;
- (NSURLRequest *)requestImageTypes;

- (NSURLRequest *)requestCollectionsForUsername:(NSString *)userIdentifier;
- (NSURLRequest *)requestCreateCollectionWithName:(NSString *)name;
- (NSURLRequest *)requestAddImage:(NSString *)imageIdentifier toCollection:(NSString *)collectionIdentifier;

- (NSURLRequest *)requestCategories;
- (NSURLRequest *)requestSubmitImage:(NSString *)imageIdentifier toCategory:(NSString *)categoryIdentifier;

@end
