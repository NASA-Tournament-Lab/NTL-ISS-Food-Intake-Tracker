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
//  UserService.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-10.
//

#import "UserServiceImpl.h"
#import "DataHelper.h"
#import "LoggingHelper.h"

@implementation UserServiceImpl

-(id)initWithConfiguration:(NSDictionary *)configuration {
    return [super init];
}

-(User *)buildUser:(NSError **) error {
    NSString *methodName = [NSString stringWithFormat:@"%@.buildUser:", NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:[self managedObjectContext]];
    User *user = [[User alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    user.admin = @NO;
    user.fullName = @"";
    user.lastUsedFoodProductFilter = nil;
    user.useLastUsedFoodProductFilter = @NO;
    user.dailyTargetFluid = @0;
    user.dailyTargetEnergy = @0;
    user.dailyTargetSodium = @0;
    user.maxPacketsPerFoodProductDaily = @0;
    user.removed = @NO;

    entity = [NSEntityDescription entityForName:@"Media"
                                                                   inManagedObjectContext:[self managedObjectContext]];
    user.profileImage = [[Media alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    user.profileImage.removed = @NO;
    user.profileImage.synchronized = @NO;
    
    [LoggingHelper logMethodExit:methodName returnValue:user];
    return user;
}

-(BOOL)saveUser:(User *)user error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.saveUser:error:", NSStringFromClass(self.class)];

    //Check user == nil?
    if(user == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"UserServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"user should not be nil"}];
            [LoggingHelper logError:methodName error:*error];
        }

        return NO;
    }

    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user"] params:@[user]];
    
    //Save new user or update existing user
    [self.managedObjectContext lock];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fullName == %@)", user.fullName];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"User"
                                                    inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    [request setPredicate:predicate];
    User *existingUser = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:error];
    [LoggingHelper logError:methodName error:*error];
    if (!(*error)) {
        if ([objects count] == 0) {
            // No existing user
            [self.managedObjectContext insertObject:user.profileImage];
            [self.managedObjectContext insertObject:user];
            // Save changes in the managedObjectContext
            [self.managedObjectContext save:error];
        } else {
            // There is existing user
            existingUser = objects[0];
            if ([existingUser isEqual:user]) {
                existingUser = user;
            } else {
                // copy fields from user to existingUser
                existingUser.admin = user.admin;
                existingUser.fullName = user.fullName;
                existingUser.useLastUsedFoodProductFilter = user.useLastUsedFoodProductFilter;
                if (user.lastUsedFoodProductFilter != nil) {
                    existingUser.lastUsedFoodProductFilter = [existingUser.managedObjectContext
                                                              objectWithID:user.lastUsedFoodProductFilter.objectID];
                    existingUser.lastUsedFoodProductFilter.synchronized = @NO;
                }
                existingUser.dailyTargetFluid = user.dailyTargetFluid;
                existingUser.dailyTargetEnergy = user.dailyTargetEnergy;
                existingUser.dailyTargetSodium = user.dailyTargetSodium;
                existingUser.maxPacketsPerFoodProductDaily = user.maxPacketsPerFoodProductDaily;
                existingUser.profileImage = [existingUser.managedObjectContext objectWithID:user.profileImage.objectID];
                existingUser.removed = user.removed;
                existingUser.synchronized = @NO;
            }
            
            // Save changes in the managedObjectContext
            [self.managedObjectContext save:error];
        }
        
        [LoggingHelper logError:methodName error:*error];
    }
    [self.managedObjectContext unlock];
    
    [LoggingHelper logMethodExit:methodName returnValue:nil];
    return YES;
}

-(BOOL)deleteUser:(User *)user error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.deleteUser:error:", NSStringFromClass(self.class)];
    
    //Check user == nil?
    if(user == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"UserServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"user should not be nil"}];
            [LoggingHelper logError:methodName error:*error];
        }

        return NO;
    }
 
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user"] params:@[user]];
    
    //Delete user
    [self.managedObjectContext lock];
    user.synchronized = @NO;
    user.removed = @YES;
    
    [self.managedObjectContext save:error];
    
    [LoggingHelper logError:methodName error:*error];
    
    [self.managedObjectContext unlock];
    
    [LoggingHelper logMethodExit:methodName returnValue:nil];
    return YES;
}

-(NSArray*)filterUsers:(NSString *)partialName error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.filterUser:error:", NSStringFromClass(self.class)];
    
    //Check partial name == nil?
    if (partialName == nil) {
        if (error) {
            *error = [NSError errorWithDomain:@"UserServiceImpl" code:IllegalArgumentErrorCode
                                     userInfo:@{NSUnderlyingErrorKey: @"partialName should not be nil"}];
            [LoggingHelper logError:methodName error:*error];
        }

        return nil;

    }
   
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"partialName"] params:@[partialName]];
    [self.managedObjectContext lock];
    //Filter users
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fullName LIKE %@) AND (removed == NO)",
                              [NSString stringWithFormat:@"*%@*", partialName]];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"User"
                                                   inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    [request setPredicate:predicate];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    
    [LoggingHelper logMethodExit:methodName returnValue:result];
    return [DataHelper orderByDate:result];
}

-(User *)loginUser:(NSString *)fullName error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.loginUser", NSStringFromClass(self.class)];
    
    //Check partial name == nil?
    if (fullName == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"UserServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"fullName should not be nil"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return nil;
    }
    
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"fullName"] params:@[fullName]];
    [self.managedObjectContext lock];
	//Login
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fullName == %@) AND (removed == NO)", fullName];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"User"
                                                    inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    [request setPredicate:predicate];
    
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    
    if (*error) {
        [LoggingHelper logMethodExit:methodName returnValue:nil];
        return nil;
    }
    
    if ([result count] == 0) {
        *error = [[NSError alloc] initWithDomain:@"UserService"
                                            code:EntityNotFoundErrorCode
                                        userInfo:@{NSLocalizedDescriptionKey: @"No such user."}];
        [LoggingHelper logError:methodName error:*error];
        [LoggingHelper logMethodExit:methodName returnValue:nil];
        return nil;
    } else {
        User *user = result[0];
        [LoggingHelper logMethodExit:methodName returnValue:user];
        return user;
    }
}

-(BOOL)logoutUser:(User *)user error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.logoutUser:error:", NSStringFromClass(self.class)];
    
    //Check user == nil?
    if(user == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"UserServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"user should not be nil"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return NO;
    }
    
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user"] params:@[user]];
    
	//Logout

    //[self.lockService releaseLock:user error:error]; //lock is removed
    [LoggingHelper logError:methodName error:*error];
    [LoggingHelper logMethodExit:methodName returnValue:nil];
    return YES;
}

@end
