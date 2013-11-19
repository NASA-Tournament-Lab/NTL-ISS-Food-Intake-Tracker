//
//  SMBClient.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @protocol SMBClient
 @discussion This protocol defines the methods to access Samba server.
 @author flying2hk, duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1. Modified to use libsmbclient and KxSMBProvider
    2.Fixed " Method accepting NSError** should have a non-void return value to indicate whether or not an error
    occurred". Add a BOOL return to indicate whether the operation succeeds.
 */
@protocol SMBClient <NSObject>

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
      password:(NSString *)password error:(NSError **)error;

/*!
 @discussion Disconnect from Samba server.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)disconnect:(NSError **)error;

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
