//
//  SMBClientTests.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 8/5/13.
//  Copyright (c) 2013 TopCoder Inc. All rights reserved.
//

#import "SMBClientTests.h"
#import "BaseCommunicationDataService.h"

@implementation SMBClientTests

@synthesize smbClient;

/*!
 @discussion Set up testing environment. It creates a test folder
 */
- (void)setUp {
    [super setUp];
    
    NSError *error = nil;
    BaseCommunicationDataService *service = [[BaseCommunicationDataService alloc] initWithConfiguration:self.configurations];
    self.smbClient = [service createSMBClient:&error];
    self.testFolder = @"samba_tests";
    [self.smbClient createDirectory:self.testFolder error:&error];
    
}

/*!
 @discussion Tear down testing environment. It deletes the test folder.
 */
- (void)tearDown {
    NSError *error = nil;
    [self.smbClient deleteDirectory:self.testFolder error:&error];
    [super tearDown];
}

/*!
 @discussuion Test initialization method
 */
- (void)testInit {
    STAssertNotNil(self.smbClient, @"Initialization should succeed");
}

/*!
 @discussuion Test ListFiles method
 */
- (void)testListFiles {
    NSError *error = nil;
    NSArray *files = [self.smbClient listFiles:self.testFolder error:&error];
    STAssertNotNil(files, @"result should not be nil.");
    STAssertNil(error, @"error should be nil.");
}

/*!
 @discussuion Test ListFiles method with invalid path
 */
- (void)testListFiles_NotFound {
    NSError *error = nil;
    NSArray *files = [self.smbClient listFiles:@"This_is_an_invalid_folder" error:&error];
    STAssertNil(files, @"result should be nil.");
    STAssertNotNil(error, @"error should not be nil.");
}


/*!
 @discussuion Test Connect method with Nil params
 */
- (void)testListFiles_Nil {
    NSError *error = nil;
    NSArray *files = [self.smbClient listFiles:nil error:&error];
    STAssertNil(files, @"result should be nil.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test ListDirectories method
 */
- (void)testListDirectories {
    NSError *error = nil;
    NSArray *files = [self.smbClient listDirectories:self.testFolder error:&error];
    STAssertNotNil(files, @"result should not be nil.");
    STAssertNil(error, @"error should be nil.");
}


/*!
 @discussuion Test ListDirectories method with invalid path
 */
- (void)testListDirectories_NotFound {
    NSError *error = nil;
    NSArray *folders = [self.smbClient listDirectories:@"This_is_an_invalid_folder" error:&error];
    STAssertNil(folders, @"result should  be nil.");
    STAssertNotNil(error, @"error should not be nil.");
}


/*!
 @discussuion Test ListDirectories method with nil params
 */
- (void)testListDirectories_Nil {
    NSError *error = nil;
    NSArray *folders = [self.smbClient listDirectories:nil error:&error];
    STAssertNil(folders, @"result should  be nil.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test CreateDirectory method.
 */
- (void)testCreateDirectory {
    NSString *createFolderName = @"folder_to_be_created";
    NSString *folder = [NSString stringWithFormat:@"%@/%@", self.testFolder, createFolderName];
    NSError *error = nil;
    BOOL result = [self.smbClient createDirectory:folder error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
    NSArray *folders = [self.smbClient listDirectories:self.testFolder error:&error];
    STAssertNotNil(folders, @"folders should not be nil.");
    STAssertNil(error, @"error should be nil.");
    STAssertTrue([folders containsObject:createFolderName], @"folders should contain test folder.");

}

/*!
 @discussuion Test CreateDirectory method with directory already exists.
 */
- (void)testCreateDirectory_Exist {
    NSString *createFolderName = @"folder_to_be_created";
    NSString *folder = [NSString stringWithFormat:@"%@/%@", self.testFolder, createFolderName];
    NSError *error = nil;
    BOOL result = [self.smbClient createDirectory:folder error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
    NSArray *folders = [self.smbClient listDirectories:self.testFolder error:&error];
    STAssertNotNil(folders, @"folders should not be nil.");
    STAssertNil(error, @"error should be nil.");
    STAssertTrue([folders containsObject:createFolderName], @"folders should contain test folder.");
    
    result = [self.smbClient createDirectory:folder error:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test CreateDirectory method with part of the path does not exist.
 */
- (void)testCreateDirectory_PathNotExist {
    NSString *createFolderName = @"folder_to_be_created";
    NSString *folder = [NSString stringWithFormat:@"%@/%@/%@", self.testFolder, createFolderName,createFolderName];
    NSError *error = nil;
    BOOL result = [self.smbClient createDirectory:folder error:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}


/*!
 @discussuion Test CreateDirectory method with nil params
 */
- (void)testCreateDirectory_Nil {
    NSError *error = nil;
    BOOL result = [self.smbClient createDirectory:nil error:&error];
    STAssertFalse(result, @"result should  be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test DeleteDirectory method.
 */
- (void)testDeleteDirectory {
    NSString *deleteFolderName = @"folder_to_be_deleted";
    NSString *folder = [NSString stringWithFormat:@"%@/%@", self.testFolder, deleteFolderName];
    NSError *error = nil;
    BOOL result = [self.smbClient createDirectory:folder error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
    NSArray *folders = [self.smbClient listDirectories:self.testFolder error:&error];
    STAssertNotNil(folders, @"folders should not be nil.");
    STAssertNil(error, @"error should be nil.");
    STAssertTrue([folders containsObject:deleteFolderName], @"folders should contain test folder.");
    
    result = [self.smbClient deleteDirectory:folder error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    folders = [self.smbClient listDirectories:self.testFolder error:&error];
    STAssertNotNil(folders, @"folders should not be nil.");
    STAssertNil(error, @"error should be nil.");
    STAssertTrue(![folders containsObject:deleteFolderName], @"folders should not contain test folder.");
    
}

/*!
 @discussuion Test DeleteDirectory method with directory contains files.
 */
- (void)testDeleteDirectory_WithFiles {
    NSString *folder = [NSString stringWithFormat:@"%@/folder_to_be_deleted", self.testFolder];
    NSError *error = nil;
    BOOL result = [self.smbClient createDirectory:folder error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    NSString *file = [NSString stringWithFormat:@"%@/file_to_be_deleted.txt", folder];
    result = [self.smbClient writeFile:file data:[NSData data] error:&error];
    STAssertTrue(result, @"result should be YES.");

    result = [self.smbClient deleteDirectory:folder error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
}

/*!
 @discussuion Test DeleteDirectory method with directory contains folders.
 */
- (void)testDeleteDirectory_WithFolders {
    NSString *folder = [NSString stringWithFormat:@"%@/folder_to_be_deleted", self.testFolder];
    NSError *error = nil;
    BOOL result = [self.smbClient createDirectory:folder error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    NSString *subfolder = [NSString stringWithFormat:@"%@/folder_to_be_deleted", folder];
    result = [self.smbClient createDirectory:subfolder error:&error];
    STAssertTrue(result, @"result should be YES.");
    
    result = [self.smbClient deleteDirectory:folder error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
}

/*!
 @discussuion Test DeleteDirectory method with invalid directory.
 */
- (void)testDeleteDirectory_NotExist {
    NSError *error = nil;
    BOOL result = [self.smbClient deleteDirectory:@"This_is_an_invalid_directory" error:&error];
    STAssertFalse(result, @"result should not be YES.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test DeleteDirectory method with nil params
 */
- (void)testDeleteDirectory_Nil {
    NSError *error = nil;
    BOOL result = [self.smbClient deleteDirectory:nil error:&error];
    STAssertFalse(result, @"result should  be false.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test DeleteFile method
 */
- (void)testDeleteFile {
    NSString *file = [NSString stringWithFormat:@"%@/file_to_be_deleted.txt", self.testFolder];
    NSError *error = nil;
    BOOL result = [self.smbClient writeFile:file data:[NSData data] error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    result = [self.smbClient deleteFile:file error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
}

/*!
 @discussuion Test DeleteFile method with invalid flle path.
 */
- (void)testDeleteFile_NotExist {
    NSError *error = nil;
    BOOL result = [self.smbClient deleteFile:@"This_is_an_invalid_file" error:&error];
    STAssertFalse(result, @"result should not be YES.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test DeleteFile method with nil params
 */
- (void)testDeleteFile_Nil {
    NSError *error = nil;
    BOOL result = [self.smbClient deleteFile:nil error:&error];
    STAssertFalse(result, @"result should  be false.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test ReadFile method
 */
- (void)testReadFile {
    NSError *error = nil;
    NSString *file = @"file_to_be_read.txt";
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", self.testFolder, file];
    BOOL result = [self.smbClient writeFile:filePath data:[NSData data] error:&error];
    STAssertTrue(result, @"result should  be YES.");
    STAssertNil(error, @"error should  be nil.");
    
    NSData *data = [self.smbClient readFile:filePath error:&error];
    STAssertNotNil(data, @"data should not be nil.");
    STAssertNil(error, @"error should be nil.");
}

/*!
 @discussuion Test ReadFile method with invalid path
 */
- (void)testReadFile_PathNotExist {
    NSError *error = nil;
    NSString *filePath = @"invalid_folder/file_to_be_read.txt";
    filePath = [NSString stringWithFormat:@"%@/%@", self.testFolder, filePath];
    NSData *data = [self.smbClient readFile:filePath error:&error];
    STAssertNil(data, @"data should be nil.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test ReadFile method with nil params
 */
- (void)testReadFile_Nil {
    NSError *error = nil;
    NSData *data = [self.smbClient readFile:nil error:&error];
    STAssertNil(data, @"data should  be nil.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test WriteFile method
 */
- (void)testWriteFile {
    NSError *error = nil;
    NSString *filePath = @"file_to_be_write.txt";
    filePath = [NSString stringWithFormat:@"%@/%@", self.testFolder, filePath];
    BOOL result = [self.smbClient writeFile:filePath data:[NSData data] error:&error];
    STAssertTrue(result, @"result should  be YES.");
    STAssertNil(error, @"error should  be nil.");
    
    NSData *data = [self.smbClient readFile:filePath error:&error];
    STAssertNotNil(data, @"data should not be nil.");
    STAssertNil(error, @"error should be nil.");
}

/*!
 @discussuion Test WriteFile method with invalid path
 */
- (void)testWriteFile_PathNotExist {
    
    NSError *error = nil;
    NSString *filePath = @"invalid_folder/file_to_be_write.txt";
    filePath = [NSString stringWithFormat:@"%@/%@", self.testFolder, filePath];
    BOOL result = [self.smbClient writeFile:filePath data:[NSData data] error:&error];
    STAssertFalse(result, @"result should  be false.");
    STAssertNotNil(error, @"error should not be nil.");
    
    NSData *data = [self.smbClient readFile:filePath error:&error];
    STAssertNil(data, @"data should be nil.");
    STAssertNotNil(error, @"error should not be nil.");
    
}

/*!
 @discussuion Test WriteFile method with existing file
 */
- (void)testWriteFile_PathAlreadyExist {
    
    NSError *error = nil;
    NSString *filePath = @"file_to_be_write.txt";
    filePath = [NSString stringWithFormat:@"%@/%@", self.testFolder, filePath];
    BOOL result = [self.smbClient writeFile:filePath data:[NSData data] error:&error];
    STAssertTrue(result, @"result should  be YES.");
    STAssertNil(error, @"error should  be nil.");
    
    NSData *data = [self.smbClient readFile:filePath error:&error];
    STAssertNotNil(data, @"data should not be nil.");
    STAssertNil(error, @"error should be nil.");
    
    result = [self.smbClient writeFile:filePath data:[NSData data] error:&error];
    STAssertTrue(result, @"result should  be YES.");
    STAssertNil(error, @"error should  be nil.");
    
}

/*!
 @discussuion Test WriteFile method with nil params
 */
- (void)testWriteFile_Nil {
    NSError *error = nil;
    BOOL result = [self.smbClient writeFile:nil data:nil error:&error];
    STAssertFalse(result, @"result should  be false.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test Connect method
 */
- (void)testConnect {
    NSError *error = nil;
    BOOL result = [self.smbClient connect:self.configurations[@"SharedFileServerPath"]
                                workgroup:self.configurations[@"SharedFileServerWorkgroup"]
                                 username:self.configurations[@"SharedFileServerUsername"]
                                 password:self.configurations[@"SharedFileServerPassword"]
                                    error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
}

/*!
 @discussuion Test Connect method with wrong server info
 */
- (void)testConnect_Failure{
    NSError *error = nil;
    [self.smbClient disconnect:&error];
    BOOL result = [self.smbClient connect:self.configurations[@"SharedFileServerPath"]
                                workgroup:self.configurations[@"SharedFileServerWorkgroup"]
                                 username:self.configurations[@"SharedFileServerUsername"]
                                 password:@"Invalid paaasword"
                                    error:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test Connect method with Nil params
 */
- (void)testConnect_Nil {
    NSError *error = nil;
    BOOL result = [self.smbClient connect:nil workgroup:nil username:nil password:nil error:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test Disconnet method
 */
- (void)testDisconnect {
    NSError *error = nil;
    BOOL result = [self.smbClient disconnect:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");

}




@end
