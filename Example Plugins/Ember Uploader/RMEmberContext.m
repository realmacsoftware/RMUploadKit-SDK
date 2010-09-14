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

#import "RMEmberContext.h"

#import "RMUploaderEmberFunctions.h"

NSString *const RMEmberErrorDomain = @"com.realmacsoftware.ember";

@interface RMEmberContext ()
@property (copy) NSURL *serviceURL;
@property (copy) NSString *APIKey;
@property (copy) NSString *authenticationToken;
@end

@interface RMEmberContext (Private)
- (NSURLRequest *)_multipartRequestForURL:(NSURL *)URL withParameters:(NSDictionary *)parameters;
- (NSString *)_queryForParameters:(NSDictionary *)parameters;
@end 

@implementation RMEmberContext : NSObject

@synthesize serviceURL=_serviceURL;
@synthesize APIKey=_APIKey;
@synthesize authenticationToken=_authenticationToken;

- (id)initWithServiceURL:(NSURL *)serviceURL APIKey:(NSString *)APIKey {
	NSParameterAssert(serviceURL != nil);
	NSParameterAssert(APIKey != nil);
	
	self = [self init];
	if (self == nil) return nil;
	
	_serviceURL = [serviceURL copy];
	_APIKey = [APIKey copy];
	
	return self;
}

- (void)authenticateWithToken:(NSString *)authenticationToken {
	[self setAuthenticationToken:authenticationToken];
}

+ (NSXMLDocument *)parseResponse:(NSData *)response error:(NSError **)errorRef {
	if (response == nil) {
		if (errorRef != NULL) {
			NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									   nil];
			*errorRef = [NSError errorWithDomain:RMEmberErrorDomain code:0 userInfo:errorInfo];
		}
		return nil;
	}
	
	NSXMLDocument *responseDocument = [[NSXMLDocument alloc] initWithData:response options:0 error:errorRef];
	if (responseDocument == nil) return nil;
	
	if ([RMUploaderEmberStringValueForXPath(responseDocument, @"/response/status[1]", NULL) isEqualToString:@"FAIL"]) {
		if (errorRef != NULL) {
			NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									   RMUploaderEmberStringValueForXPath(responseDocument, @"/response/errors[1]", NULL), NSLocalizedDescriptionKey,
									   nil];
			*errorRef = [NSError errorWithDomain:RMEmberErrorDomain code:0 userInfo:errorInfo];
		}
		return nil;
	}
	
	return responseDocument;
}

- (NSURLRequest *)requestLoginWithUsername:(NSString *)username password:(NSString *)password {
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								[self APIKey], @"api_key",
								username, @"username",
								password, @"password",
								nil];
	return [self _multipartRequestForURL:[NSURL URLWithString:@"/users/request_user_token" relativeToURL:[self serviceURL]] withParameters:parameters];
}

- (NSURLRequest *)requestUpload:(NSURL *)imageLocation withName:(NSString *)name description:(NSString *)description tags:(NSArray *)tags date:(NSDate *)date originalURL:(NSURL *)originalURL rating:(NSNumber *)rating imageType:(NSString *)imageType privacy:(NSString *)privacy {
	NSParameterAssert([self authenticationToken] != nil);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"/images/create" relativeToURL:[self serviceURL]]];
	[request setHTTPMethod:@"POST"];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	[parameters setObject:[self APIKey] forKey:@"api_key"];
	[parameters setObject:[self authenticationToken] forKey:@"user_token"];
	[parameters setValue:name forKey:@"name"];
	[parameters setValue:description forKey:@"description"];
	[parameters setValue:[tags componentsJoinedByString:@","] forKey:@"tags"];
	[parameters setValue:privacy forKey:@"privacy_level_id"];
	[parameters setValue:imageType forKey:@"image_type_id"];
	[parameters setValue:[[NSNumber numberWithDouble:[date timeIntervalSince1970]] stringValue] forKey:@"date_taken"];
	[parameters setValue:[originalURL absoluteString] forKey:@"url"];
	[parameters setValue:[rating stringValue] forKey:@"rating"];
	
	
	RMUploadMultipartFormDocument *formDocument = [[RMUploadMultipartFormDocument alloc] init];
	
	[parameters enumerateKeysAndObjectsUsingBlock:^ (id key, id obj, BOOL *stop) {
		[formDocument setValue:obj forField:key];
	}];
	
	[formDocument addFileByReferencingURL:imageLocation withFilename:nil toField:@"file"];
	
	NSData *bodyData = nil; NSString *contentType = nil;
	[formDocument getFormData:&bodyData contentType:&contentType];
	
	[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:bodyData];
	
	return request;
}

- (NSURLRequest *)requestPrivacy {
	NSString *requestString = @"/privacy/index.xml";
	
	if ([self APIKey] != nil && [self authenticationToken] != nil) {
		NSString *query = [self _queryForParameters:[NSDictionary dictionaryWithObjectsAndKeys:
													 [self APIKey], @"api_key",
													 [self authenticationToken], @"user_token",
													 nil]
						   ];
		requestString = [requestString stringByAppendingString:query];
	}
	
	return [NSURLRequest requestWithURL:[NSURL URLWithString:requestString relativeToURL:[self serviceURL]]];
}

- (NSURLRequest *)requestImageTypes {
	return [NSURLRequest requestWithURL:[NSURL URLWithString:@"/image_types/index.xml" relativeToURL:[self serviceURL]]];
}

- (NSURLRequest *)requestCollectionsForUsername:(NSString *)userIdentifier {
	NSParameterAssert([self authenticationToken] != nil);
	
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								[self APIKey], @"api_key",
								[self authenticationToken], @"user_token",
								nil];
	NSString *query = [self _queryForParameters:parameters];
	
	NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"/users/view/%@/collections/index", userIdentifier] relativeToURL:[self serviceURL]];
	requestURL = [NSURL URLWithString:[[requestURL absoluteString] stringByAppendingString:query]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
	return request;
}

- (NSURLRequest *)requestCreateCollectionWithName:(NSString *)name {
	NSParameterAssert([self authenticationToken] != nil);
	
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								[self APIKey], @"api_key",
								[self authenticationToken], @"user_token",
								name, @"name",
								@"1", @"privacy_level_id",
								nil];
	return [self _multipartRequestForURL:[NSURL URLWithString:@"/collections/create" relativeToURL:[self serviceURL]] withParameters:parameters];
}

- (NSURLRequest *)requestAddImage:(NSString *)imageIdentifier toCollection:(NSString *)collectionIdentifier {
	NSParameterAssert([self authenticationToken] != nil);
	
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								[self APIKey], @"api_key",
								[self authenticationToken], @"user_token",
								collectionIdentifier, @"slug",
								imageIdentifier, @"token",
								nil];
	return [self _multipartRequestForURL:[NSURL URLWithString:@"/collections/add_image" relativeToURL:[self serviceURL]] withParameters:parameters];
}

- (NSURLRequest *)requestCategories {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"/categories/index" relativeToURL:[self serviceURL]]];
	return request;
}

- (NSURLRequest *)requestSubmitImage:(NSString *)imageIdentifier toCategory:(NSString *)categoryIdentifier {
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								[self APIKey], @"api_key",
								categoryIdentifier, @"slug",
								imageIdentifier, @"token",
								nil];
	return [self _multipartRequestForURL:[NSURL URLWithString:@"/categories/submit_image" relativeToURL:[self serviceURL]] withParameters:parameters];
}

@end

@implementation RMEmberContext (Private)

- (NSURLRequest *)_multipartRequestForURL:(NSURL *)URL withParameters:(NSDictionary *)parameters {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
	[request setHTTPMethod:@"POST"];
	
	
	RMUploadMultipartFormDocument *formDocument = [[RMUploadMultipartFormDocument alloc] init];
	
	[parameters enumerateKeysAndObjectsUsingBlock:^ (id key, id obj, BOOL *stop) {
		[formDocument setValue:obj forField:key];
	}];
	
	NSData *bodyData = nil;
	NSString *contentType = nil;
	[formDocument getFormData:&bodyData contentType:&contentType];
	
	[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:bodyData];
	
	
	return request;
}

static NSString * (^encodeString)(NSString *) = ^ NSString * (NSString *string) {
	return NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
};

- (NSString *)_queryForParameters:(NSDictionary *)parameters {
	NSMutableArray *query = [NSMutableArray arrayWithCapacity:[parameters count]];
	
	[parameters enumerateKeysAndObjectsUsingBlock:^ (id key, id obj, BOOL *stop) {
		NSMutableString *parameter = [NSMutableString string];
		[parameter appendString:encodeString(key)];
		[parameter appendString:@"="];
		if (![obj isKindOfClass:[NSNull class]]) [parameter appendString:encodeString(obj)]; 
		
		[query addObject:parameter];
	}];
	
	return [@"?" stringByAppendingString:[query componentsJoinedByString:@"&"]];
}

@end
