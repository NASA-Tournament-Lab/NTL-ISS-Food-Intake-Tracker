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
//  SMBClientImpl.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//

#import "SMBClientImpl.h"
#import "LoggingHelper.h"

@interface SMBClientImpl() <KxSMBProviderDelegate>
@end

@implementation SMBClientImpl {
    
    NSMutableDictionary *_cachedAuths;
}

@synthesize serverRootPath = _serverRootPath;

/*!
 @discussion This method creates an instance of SMBClientImpl.
 @return an instance of SMBClientImpl.
 */
- (id)init {
    self = [super init];
    if(self) {
        _cachedAuths = [NSMutableDictionary dictionary];
        KxSMBProvider *provider = [KxSMBProvider sharedSmbProvider];
        provider.delegate = self;
    }
    return self;
}

/*!
 @discussion This method fetches an instance of KxSMBAuth with given server and share.
 @param server The server name.
 @param share The share name.
 @return an instance of KxSMBAuth with given server and share.
 */
- (KxSMBAuth *)smbAuthForServer:(NSString *)server
                      withShare:(NSString *)share {
    
    KxSMBAuth *auth = _cachedAuths[server.uppercaseString];
    if (auth) {
        return auth;
    }
    return nil;
}

/*!
 @discussion Connect to Samba server.
 @param serverPath The Samba server path.
 @param workgroup the Samba server workgroup.
 @param username The Samba server username.
 @param password The Samba server password.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)connect:(NSString *)serverPath workgroup:(NSString*)workgroup username:(NSString *)username
      password:(NSString *)password error:(NSError **)error {
    
    NSString *methodName = [NSString stringWithFormat:@"%@.connect:workgroup:username:password:error:",
                            NSStringFromClass(self.class)];
    
    if (serverPath == nil || workgroup == nil || username == nil || password == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"serverPath or workgroup or"
                      " username or password should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"server path", @"workgroup", @"username", @"password" ]
                              params:@[serverPath, workgroup, username, password]];

    // stores connection information
    KxSMBAuth *auth = [KxSMBAuth smbAuthWorkgroup:workgroup
                                         username:username
                                         password:password];
    NSURL *serverURL = [NSURL URLWithString:serverPath];
    _cachedAuths[serverURL.host.uppercaseString] = auth;
    _serverRootPath = serverPath;
    
    // try to connect to server
    NSArray *result = [self listDirectories:@"" error:error];
    if(result == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: ConnectionErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot connect to smb server."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
    }
    [LoggingHelper logMethodExit:methodName returnValue:@YES];
    return YES;
}

/*!
 @discussion Disconnect from Samba server.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)disconnect:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.disconnect:error:", NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    // remove the conenction information so that the smb server cann't be connected.
    [_cachedAuths removeAllObjects];
    [LoggingHelper logMethodExit:methodName returnValue:@YES];
    return YES;
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
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"filePath should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"filePath"] params:@[filePath]];
    NSString *serverFilePath = [self.serverRootPath stringByAppendingSMBPathComponent:filePath];
    id result = [[KxSMBProvider sharedSmbProvider] fetchAtPath: serverFilePath];
    id data = nil;
    if([result isKindOfClass:[NSError class]]) {
        [LoggingHelper logMethodExit:methodName returnValue:nil];
        return nil;
    } else if ([(data = [(KxSMBItemFile*)result readDataToEndOfFile]) isKindOfClass:[NSError class]]){
        [LoggingHelper logError:methodName error:([result isKindOfClass:[NSError class]]?result:nil)];
        [LoggingHelper logError:methodName error:data];
        if(error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: ConnectionErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot read file."}];
            [LoggingHelper logError:methodName error:*error];
        }
        [LoggingHelper logMethodExit:methodName returnValue:nil];
        return nil;
    }
    else {
        [(KxSMBItemFile*)result close];
        [LoggingHelper logMethodExit:methodName returnValue:data];
        return data;
    }
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
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"filePath or data should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"filePath", @"data"] params:@[filePath, data]];
    NSString *serverFilePath = [self.serverRootPath stringByAppendingSMBPathComponent:filePath];
    bool success = YES;
    
    id result = [[KxSMBProvider sharedSmbProvider] createFileAtPath:serverFilePath overwrite:YES];
    if ([result isKindOfClass:[KxSMBItemFile class]]) {
        KxSMBItemFile *itemFile = result;
        id result2 = [itemFile writeData:data];
        [itemFile close];
        if (![result2 isKindOfClass:[NSError class]]) {
            success = YES;
        }
        else {
            [LoggingHelper logError:methodName error:result2];
            if(error) {
                *error = [NSError errorWithDomain:@"SMBClient" code: ConnectionErrorCode
                                         userInfo:@{NSLocalizedDescriptionKey: @"Cannot write data to file."}];
                [LoggingHelper logError:methodName error:*error];
            }
            success = NO;
        }
        
    } else {
        [LoggingHelper logError:methodName error:result];
        if(error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: ConnectionErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot create file to write."}];
            [LoggingHelper logError:methodName error:*error];
        }
        success = NO;
        
    }
    [LoggingHelper logMethodExit:methodName returnValue:success==YES?@YES:@NO];
    return success;
    
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
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"directory should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"directory"] params:@[directory]];
    
    NSString *serverFolderPath = [self.serverRootPath stringByAppendingSMBPathComponent:directory];
    if(![serverFolderPath hasSuffix:@"/"]) {
        serverFolderPath = [serverFolderPath stringByAppendingString:@"/"];
    }
    
    id items = [[KxSMBProvider sharedSmbProvider] fetchAtPath: serverFolderPath];
    if([items isKindOfClass:[NSError class]]) {
        [LoggingHelper logError:methodName error:items];
        if(error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: ConnectionErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot list files for the folder."}];
            [LoggingHelper logError:methodName error:*error];
        }
        [LoggingHelper logMethodExit:methodName returnValue:nil];
        return nil;
    }
    else {
        NSMutableArray *files = [[NSMutableArray alloc] init];
        for (KxSMBItem *item in items) {
            if(item.type == KxSMBItemTypeFile) {
                [files addObject:[item.path.lastPathComponent copy]];
            }
            
            
        }
        [LoggingHelper logMethodExit:methodName returnValue:files];
        return files;
    }
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
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"directory should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }

        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"directory"] params:@[directory]];
    
    NSString *serverFolderPath = [self.serverRootPath stringByAppendingSMBPathComponent:directory];
    if(![serverFolderPath hasSuffix:@"/"]) {
        serverFolderPath = [serverFolderPath stringByAppendingString:@"/"];
    }
    
    
    
    id items = [[KxSMBProvider sharedSmbProvider] fetchAtPath: serverFolderPath];
    if([items isKindOfClass:[NSError class]]) {
        [LoggingHelper logError:methodName error:items];
        if(error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: ConnectionErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot list folders for the folder."}];
            [LoggingHelper logError:methodName error:*error];
        }
        [LoggingHelper logMethodExit:methodName returnValue:nil];
        return nil;
    }
    else {
        NSMutableArray *folders = [[NSMutableArray alloc] init];
        for (KxSMBItem *item in items) {
            if(item.type == KxSMBItemTypeDir) {
                [folders addObject:[item.path.lastPathComponent copy]];
            }
            
        }
        [LoggingHelper logMethodExit:methodName returnValue:folders];
        return folders;
    }
}

/*!
 @discussion Delete a file from Samba server.
 @param filePath The remote file path.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)deleteFile:(NSString *)filePath error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.deleteFile:error", NSStringFromClass(self.class)];
    if (filePath == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"filePath should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"filePath"] params:@[filePath]];
    
    NSString *serverFilePath = [self.serverRootPath stringByAppendingSMBPathComponent:filePath];
    //serverFilePath = @"smb://192.168.1.195/NASA/samba_tests/delete_this_file.txt";
    id result = [[KxSMBProvider sharedSmbProvider] removeAtPath:serverFilePath];
    if([result isKindOfClass:[NSError class]]) {
        [LoggingHelper logError:methodName error:result];
        if(error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: ConnectionErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot delete file."}];
            [LoggingHelper logError:methodName error:*error];
        }
        [LoggingHelper logMethodExit:methodName returnValue:@NO];
        return NO;
        
    }
    else {
        [LoggingHelper logMethodExit:methodName returnValue:@YES];
        return YES;
    }
}

/*!
 @discussion Delete a directory recusively from Samba server.
 @param directory The directory to delete.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)deleteDirectory:(NSString *)directory error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.deleteDirectory:error", NSStringFromClass(self.class)];
    if (directory == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"directory should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"directory"] params:@[directory]];
    
    NSString *serverFolderPath = [self.serverRootPath stringByAppendingSMBPathComponent:directory];
    if([serverFolderPath hasSuffix:@"/"]) {
        serverFolderPath = [serverFolderPath substringToIndex:[serverFolderPath length] - 1];
    }
    
    // delete all files
    NSError *e = nil;

    // delete all folders
    id folders = [self listDirectories:directory error:&e];
    if (e) {
        if (error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: ConnectionErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot access directory."}];
            [LoggingHelper logError:methodName error:*error];
        }
        [LoggingHelper logMethodExit:methodName returnValue:@NO];
        return NO;
    }
    else {
        for (NSString *folder in folders) {
            e = nil;
            NSString *folderPath = [directory stringByAppendingSMBPathComponent:folder];
            
            [self deleteDirectory:folderPath error:&e];
            if(e) {
                if (error) {
                    *error = [NSError errorWithDomain:@"SMBClient"
                                                 code: ConnectionErrorCode
                                             userInfo:@{NSLocalizedDescriptionKey:
                              @"Cannot delete directories in directory."}];
                    [LoggingHelper logError:methodName error:*error];
                }
                [LoggingHelper logMethodExit:methodName returnValue:@NO];
                return NO;
            }
            
        }
    }
    
    id files = [self listFiles:directory error:&e];
    if (e) {
        if (error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: ConnectionErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot access directory."}];
            [LoggingHelper logError:methodName error:*error];
        }
        [LoggingHelper logMethodExit:methodName returnValue:@NO];
        return NO;
    }
    else {
        for (NSString *file in files) {
            e = nil;
            NSString *filePath = [directory stringByAppendingSMBPathComponent:file];
            [self deleteFile:filePath error:&e];
            if(e) {
                if (error) {
                    *error = [NSError errorWithDomain:@"SMBClient"
                                                 code: ConnectionErrorCode
                                             userInfo:@{NSLocalizedDescriptionKey:
                              @"Cannot delete files in directory."}];
                    [LoggingHelper logError:methodName error:*error];
                }
                [LoggingHelper logMethodExit:methodName returnValue:@NO];
                return NO;
                
            }
        }
    }
    
    e = nil;
    
    // then delete directory
    id result = [[KxSMBProvider sharedSmbProvider] removeAtPath:serverFolderPath];
    if([result isKindOfClass:[NSError class]]) {
        [LoggingHelper logError:methodName error:result];
        if(error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: ConnectionErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot delete directory."}];
            [LoggingHelper logError:methodName error:*error];
        }
        [LoggingHelper logMethodExit:methodName returnValue:@NO];
        return NO;
        
    }
    else {
        [LoggingHelper logMethodExit:methodName returnValue:@YES];
        return YES;
    }
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
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: IllegalArgumentErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"directory should not be nil."}];
            [LoggingHelper logError:methodName error:*error];
        }
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"directory"] params:@[directory]];
    
    NSString *serverFolderPath = [self.serverRootPath stringByAppendingSMBPathComponent:directory];
    if([serverFolderPath hasSuffix:@"/"]) {
        serverFolderPath = [serverFolderPath substringToIndex:[serverFolderPath length] - 1];
    }
    KxSMBProvider *provider = [KxSMBProvider sharedSmbProvider];
    id result = [provider createFolderAtPath:serverFolderPath];
    if ([result isKindOfClass:[KxSMBItemTree class]]) {
        [LoggingHelper logMethodExit:methodName returnValue:@YES];
        return YES;
        
    }
    else {
        [LoggingHelper logError:methodName error:result];
        if(error) {
            *error = [NSError errorWithDomain:@"SMBClient"
                                         code: ConnectionErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot create directory."}];
            [LoggingHelper logError:methodName error:*error];
        }
        [LoggingHelper logMethodExit:methodName returnValue:@NO];
        return NO;
    }
}

@end
