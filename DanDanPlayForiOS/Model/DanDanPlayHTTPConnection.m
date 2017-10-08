
#import "DanDanPlayHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"

#define UPLOAD_PATH @"/upload"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
 **/

@implementation DanDanPlayHTTPConnection
{
    NSString *_writePath;
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
	HTTPLogTrace();
	
	// Add support for POST
	
	if ([method isEqualToString:@"POST"]) {
			return YES;
	}
	
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
	HTTPLogTrace();
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"] && [path isEqualToString:UPLOAD_PATH]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }

		// enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for(NSString* param in params) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
	HTTPLogTrace();
	
	if ([method isEqualToString:@"POST"] && [path isEqualToString:UPLOAD_PATH]) {
        return [[HTTPDataResponse alloc] initWithData:[@"{}" dataUsingEncoding:NSUTF8StringEncoding]];
	}
    
    if( [method isEqualToString:@"GET"]) {
        
        if ([path hasPrefix:@"/version"]) {
            return [[HTTPDataResponse alloc] initWithData:[[[UIApplication sharedApplication] appVersion]  dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
	
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength {
	HTTPLogTrace();
	
	// set up mime parser
    NSString* boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;

//	uploadedFiles = [[NSMutableArray alloc] init];
}

- (void)processBodyData:(NSData *)postDataChunk {
	HTTPLogTrace();
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    [parser appendData:postDataChunk];
}


//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate


- (void)processStartOfPartWithHeader:(MultipartMessageHeader*)header {
	// in this sample, we are not interested in parts, other then file parts.
	// check content disposition to find out filename

    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
	NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];

    if ( (nil == filename) || [filename isEqualToString: @""]) {
        // it's either not a file part, or
		// an empty form sent. we won't handle it.
		return;
	}
    
//	NSString* uploadDirPath = [[config documentRoot] stringByAppendingPathComponent:@"upload"];
    NSString* uploadDirPath = [[UIApplication sharedApplication] documentsPath];

	BOOL isDir = YES;
	if (![[NSFileManager defaultManager] fileExistsAtPath:uploadDirPath isDirectory:&isDir ]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
    NSString* filePath = [uploadDirPath stringByAppendingPathComponent:filename];
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
//        storeFile = nil;
//        _writePath = nil;
    }
    
		HTTPLogVerbose(@"Saving file to %@", filePath);
		if(![[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:true attributes:nil error:nil]) {
			HTTPLogError(@"Could not create directory at path: %@", filePath);
		}
        
		if(![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
			HTTPLogError(@"Could not create file at path: %@", filePath);
		}
        _writePath = filePath;
		storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
//		[uploadedFiles addObject: [NSString stringWithFormat:@"/upload/%@", filename]];
}


- (void)processContent:(NSData *)data WithHeader:(MultipartMessageHeader*)header {
	// here we just write the output from parser to the file.
	if(storeFile) {
		[storeFile writeData:data];
	}
}

- (void)processEndOfPartWithHeader:(MultipartMessageHeader*)header {
	// as the file part is over, we close the file.
	[storeFile closeFile];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:WRITE_FILE_SUCCESS_NOTICE object:_writePath]; 
    });
	storeFile = nil;
    _writePath = nil;
    
}

- (void)processPreambleData:(NSData*)data {
    // if we are interested in preamble data, we could process it here.

}

- (void)processEpilogueData:(NSData*)data {
    // if we are interested in epilogue data, we could process it here.
    
}

@end
