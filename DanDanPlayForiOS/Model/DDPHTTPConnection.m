
#import "DDPHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"
#import "DDPHttpReceive.h"

#define UPLOAD_PATH @"/upload"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;
#pragma clang diagnostic pop

/**
 * All we have to do is override appropriate methods in HTTPConnection.
 **/

@implementation DDPHTTPConnection
{
    NSString *_writePath;
    MultipartFormDataParser *_parser;
    NSFileHandle *_storeFile;
    uint64_t _contentLength;
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
    
    // Add support for POST
    
    if ([method isEqualToString:@"POST"]) {
        return YES;
    }
    
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
    
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
    
    // set up mime parser
    NSString* boundary = [request headerField:@"boundary"];
    _parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    _parser.delegate = self;
    _contentLength = contentLength;
    //    uploadedFiles = [[NSMutableArray alloc] init];
}

- (void)processBodyData:(NSData *)postDataChunk {
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    [_parser appendData:postDataChunk];
}


//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate


- (void)processStartOfPartWithHeader:(MultipartMessageHeader*)header {
    // in this sample, we are not interested in parts, other then file parts.
    // check content disposition to find out filename
    
    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    
    if ((nil == filename) || [filename isEqualToString: @""]) {
        // it's either not a file part, or
        // an empty form sent. we won't handle it.
        return;
    }
    
    //    NSString* uploadDirPath = [[config documentRoot] stringByAppendingPathComponent:@"upload"];
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
    
    LOG_INFO(DDPLogModuleOther, @"Saving file to %@", filePath);
    if(![[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:true attributes:nil error:nil]) {
        LOG_INFO(DDPLogModuleOther, @"Could not create directory at path: %@", filePath);
    }
    
    if(![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
        LOG_INFO(DDPLogModuleOther, @"Could not create file at path: %@", filePath);
    }
    _writePath = filePath;
    _storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    DDPHttpReceive *receive = [[DDPHttpReceive alloc] init];
    receive.filePath = _writePath;
    //开始接收
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:START_RECEIVE_FILE_NOTICE object:receive];
    });
    //        [uploadedFiles addObject: [NSString stringWithFormat:@"/upload/%@", filename]];
}


- (void)processContent:(NSData *)data WithHeader:(MultipartMessageHeader*)header {
    // here we just write the output from parser to the file.
    //写入内存
    if(_storeFile) {
        [_storeFile writeData:data];
    }
    
    DDPHttpReceive *receive = [[DDPHttpReceive alloc] init];
    receive.progress = _storeFile.offsetInFile * 1.0 / _contentLength;
    receive.filePath = _writePath;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_FILE_PROGRESS_NOTICE object:receive];
    });
}

- (void)processEndOfPartWithHeader:(MultipartMessageHeader*)header {
    // as the file part is over, we close the file.
    
    DDPHttpReceive *receive = [[DDPHttpReceive alloc] init];
    receive.progress = 1;
    receive.filePath = _writePath;
    
    [_storeFile closeFile];
    _storeFile = nil;
    _writePath = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:WRITE_FILE_SUCCESS_NOTICE object:receive];
    });
}


@end

