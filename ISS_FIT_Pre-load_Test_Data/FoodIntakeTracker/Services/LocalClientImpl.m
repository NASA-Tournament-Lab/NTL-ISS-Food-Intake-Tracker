// Copyright (c) 2013 TopCoder. All rights reserved.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//
//  LocalClient.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//

#import "LocalClientImpl.h"
#import "LoggingHelper.h"
#import "Models.h"

@implementation LocalClientImpl

@synthesize serverRootPath = _serverRootPath;

- (id)init {
    self = [super init];
    if (self) {
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _serverRootPath = [[searchPaths objectAtIndex:0] stringByAppendingString:@"/samba/"];
    }
    return self;
}

/*!
 @discussion Read a remote file from Samba server.
 @param filePath The remote file path.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The content of the file.
 */
-(NSData *)readFile:(NSString *)filePath error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.readFile:error:", NSStringFromClass(self.class)];
    
    
    if (filePath == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"LocalClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"filePath should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
    }
    
    NSString *serverFolderPath = [self.serverRootPath stringByAppendingString:filePath];
    NSData *data = [NSData dataWithContentsOfFile:serverFolderPath options:NSDataReadingMappedIfSafe error:error];
    if (!data) {
        return nil;
    }
    
    [LoggingHelper logMethodExit:methodName returnValue:data];
    return data;
}

/*!
 @discussion Write a file to Samba server.
 @param filePath The remote file path.
 @param data The file content to write.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)writeFile:(NSString *)filePath data:(NSData *)data error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.writeFile:data:error:", NSStringFromClass(self.class)];
    
    if (filePath == nil || data == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"LocalClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"filePath or data should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"filePath", @"data"] params:@[filePath, data]];

    NSString *serverFolderPath = [self.serverRootPath stringByAppendingString:filePath];
    if(![data writeToFile:serverFolderPath options:NSDataWritingAtomic error:error]) {
        *error = [NSError errorWithDomain:@"LocalClient"
                                     code: FilePathNotExistErrorCode
                                 userInfo:@{NSLocalizedDescriptionKey: @"Cannot write to local file."}];
        [LoggingHelper logError:methodName error:*error];
        [LoggingHelper logMethodExit:methodName returnValue:@NO];
        return NO;
    }

    [LoggingHelper logMethodExit:methodName returnValue:@YES];
    return YES;
}

/*!
 @discussion List all files under a directory (non-recrusively).
 @param directory The remote directory.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return An array containing the file names of the specified directory.
 */
-(NSArray *)listFiles:(NSString *)directory error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.listFiles:error:", NSStringFromClass(self.class)];
    if (directory == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"LocalClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"directory should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"directory"] params:@[directory]];
    
    NSString *serverFolderPath = [self.serverRootPath stringByAppendingString:directory];
    NSArray *tmpFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:serverFolderPath  error:error];
    if (!tmpFiles) {
        *error = [NSError errorWithDomain:@"LocalClient"
                                     code: FilePathNotExistErrorCode
                                 userInfo:@{NSLocalizedDescriptionKey: @"Cannot list files."}];
        [LoggingHelper logError:methodName error:*error];
        
        [LoggingHelper logMethodExit:methodName returnValue:nil];
        return nil;
    }
    
    NSMutableArray *files = [NSMutableArray array];
    for (NSString *cPath in tmpFiles) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", serverFolderPath, cPath];
        NSDictionary *dPath = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:error];
        if ([[dPath objectForKey:NSFileType] isEqualToString:NSFileTypeRegular]) {
            [files addObject:cPath];
        }
    }
    
    [LoggingHelper logMethodExit:methodName returnValue:files];
    return files;
}

/*!
 @discussion List all sub-directories under a directory (non-recrusively).
 @param directory The remote directory.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return An array containing the directory names of the specified directory.
 */
-(NSArray *)listDirectories:(NSString *)directory error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.listDirectories:error:", NSStringFromClass(self.class)];
    if (directory == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"LocalClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"directory should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"directory"] params:@[directory]];
    
    NSString *serverFolderPath = [self.serverRootPath stringByAppendingString:directory];
    NSArray *tmpFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:serverFolderPath  error:error];
    if (!tmpFiles) {
        *error = [NSError errorWithDomain:@"LocalClient"
                                     code: FilePathNotExistErrorCode
                                 userInfo:@{NSLocalizedDescriptionKey: @"Cannot list directories."}];
        [LoggingHelper logError:methodName error:*error];
        
        [LoggingHelper logMethodExit:methodName returnValue:nil];
        return nil;
    }
    
    NSMutableArray *folders = [NSMutableArray array];
    for (NSString *cPath in tmpFiles) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", serverFolderPath, cPath];
        NSDictionary *dPath = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:error];
        if ([[dPath objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]) {
            [folders addObject:cPath];
        }
    }
    
    [LoggingHelper logMethodExit:methodName returnValue:folders];
    return folders;
}

/*!
 @discussion Delete a file from local path.
 @param filePath The remote file path.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)deleteFile:(NSString *)filePath error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.deleteFile:error", NSStringFromClass(self.class)];
    if (filePath == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"LocalClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"filePath should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"filePath"] params:@[filePath]];
    
    NSString *serverFolderPath = [self.serverRootPath stringByAppendingString:filePath];
    if (![[NSFileManager defaultManager] removeItemAtPath:serverFolderPath error:error]) {
        *error = [NSError errorWithDomain:@"LocalClient"
                                     code: ConnectionErrorCode
                                 userInfo:@{NSLocalizedDescriptionKey: @"Cannot delete file."}];
        [LoggingHelper logError:methodName error:*error];
        [LoggingHelper logMethodExit:methodName returnValue:@NO];
        return NO;
    }
    
    [LoggingHelper logMethodExit:methodName returnValue:@YES];
    return YES;
}

/*!
 @discussion Delete a directory recusively from local path.
 @param directory The directory to delete.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)deleteDirectory:(NSString *)directory error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.deleteDirectory:error", NSStringFromClass(self.class)];
    if (directory == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"LocalClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"directory should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"directory"] params:@[directory]];
    
    NSString *serverFolderPath = [self.serverRootPath stringByAppendingString:directory];
    if (![[NSFileManager defaultManager] removeItemAtPath:serverFolderPath error:error]) {
        *error = [NSError errorWithDomain:@"LocalClient"
                                     code: ConnectionErrorCode
                                 userInfo:@{NSLocalizedDescriptionKey: @"Cannot delete directory."}];
        [LoggingHelper logError:methodName error:*error];
        [LoggingHelper logMethodExit:methodName returnValue:@NO];
        return NO;
    }
    
    [LoggingHelper logMethodExit:methodName returnValue:@YES];
    return YES;
}

/*!
 @discussion Create a directory on Samba server.
 @param directory The directory to create.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)createDirectory:(NSString *)directory error:(NSError **)error {
    
    NSString *methodName = [NSString stringWithFormat:@"%@.createDirectory:error:", NSStringFromClass(self.class)];
    if (directory == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"LocalClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"directory should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"directory"] params:@[directory]];
    
    NSString *serverFolderPath = [self.serverRootPath stringByAppendingString:directory];
    if (![[NSFileManager defaultManager] createDirectoryAtPath:serverFolderPath withIntermediateDirectories:NO attributes:nil
                                                         error:error]) {
        *error = [NSError errorWithDomain:@"LocalClient"
                                     code: ConnectionErrorCode
                                 userInfo:@{NSLocalizedDescriptionKey: @"Cannot create directory."}];
        [LoggingHelper logError:methodName error:*error];
        [LoggingHelper logMethodExit:methodName returnValue:@NO];
        return NO;
    }
    
    [LoggingHelper logMethodExit:methodName returnValue:@YES];
    return YES;
}

@end
