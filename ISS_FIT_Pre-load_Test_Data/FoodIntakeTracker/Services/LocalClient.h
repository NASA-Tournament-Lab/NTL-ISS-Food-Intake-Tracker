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
//  SMBClient.h
//  ISSFoodIntakeTracker
//
//  Created by pvmagacho on 2014-05-28.
//

#import <Foundation/Foundation.h>

/*!
 @protocol LocalClient
 @discussion This protocol defines the methods to access local.
 @author pvmagacho
 @version 1.0
 */
@protocol LocalClient <NSObject>

/*!
 @discussion Read a remote file from Samba server.
 @param filePath The remote file path.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The content of the file.
 */
-(NSData *)readFile:(NSString *)filePath error:(NSError **)error;

/*!
 @discussion Write a file to Samba server.
 @param filePath The remote file path.
 @param data The file content to write.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)writeFile:(NSString *)filePath data:(NSData *)data error:(NSError **)error;

/*!
 @discussion List all files under a directory (non-recrusively).
 @param directory The remote directory.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return An array containing the file names of the specified directory.
 */
-(NSArray *)listFiles:(NSString *)directory error:(NSError **)error;

/*!
 @discussion List all sub-directories under a directory (non-recrusively).
 @param directory The remote directory.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return An array containing the directory names of the specified directory.
 */
-(NSArray *)listDirectories:(NSString *)directory error:(NSError **)error;

/*!
 @discussion Delete a file from Samba server.
 @param filePath The remote file path.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)deleteFile:(NSString *)filePath error:(NSError **)error;

/*!
 @discussion Delete a directory recusively from Samba server.
 @param directory The directory to delete.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)deleteDirectory:(NSString *)directory error:(NSError **)error;

/*!
 @discussion Create a directory on Samba server.
 @param directory The directory to create.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)createDirectory:(NSString *)directory error:(NSError **)error;

@end
