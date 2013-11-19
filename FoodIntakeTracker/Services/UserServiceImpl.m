//
//  UserService.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-10.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import "UserServiceImpl.h"
#import "LoggingHelper.h"

@implementation UserServiceImpl

@synthesize lockService = _lockService;
@synthesize permissions = _permissions;

-(id)initWithConfiguration:(NSDictionary *)configuration
               lockService:(id<LockService>)lockService {
    self = [super init];
    if (self) {
        _lockService = lockService;
        _permissions = configuration[@"Permissions"];
    }
    return self;
}

-(User *)buildUser:(NSError **) error {
    NSString *methodName = [NSString stringWithFormat:@"%@.buildUser:", NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:[self managedObjectContext]];
    User *user = [[User alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    user.admin = @NO;
    user.fullName = @"";
    user.faceImages = [NSMutableSet set];
    user.lastUsedFoodProductFilter = nil;
    user.useLastUsedFoodProductFilter = @NO;
    user.dailyTargetFluid = @0;
    user.dailyTargetEnergy = @0;
    user.dailyTargetSodium = @0;
    user.maxPacketsPerFoodProductDaily = @0;
    user.profileImage = nil;
    user.deleted = @NO;
    
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
    NSDate *currentDate = [NSDate date];
    if (!(*error)) {
        if ([objects count] == 0) {
            // No existing user
            user.synchronized = @NO;
            user.lastModifiedDate = currentDate;
            user.createdDate = currentDate;
            NSSet *faceImages = user.faceImages;
            user.faceImages = nil;
            [self.managedObjectContext insertObject:user];
            // Save changes in the managedObjectContext
            [self.managedObjectContext save:error];
            
            for (StringWrapper *s in faceImages) {
                [self.managedObjectContext insertObject:s];
            }
            user.faceImages = faceImages;
            // Save changes in the managedObjectContext
            [self.managedObjectContext save:error];
        } else {
            // There is existing user
            existingUser = objects[0];
            if ([existingUser isEqual:user]) {
                existingUser = user;
            }
            else {
                // copy fields from user to existingUser
                existingUser.admin = user.admin;
                existingUser.fullName = user.fullName;
                existingUser.faceImages = nil;
                existingUser.useLastUsedFoodProductFilter = user.useLastUsedFoodProductFilter;
                if(user.lastUsedFoodProductFilter != nil) {
                    existingUser.lastUsedFoodProductFilter = user.lastUsedFoodProductFilter;
                }
                existingUser.dailyTargetFluid = user.dailyTargetFluid;
                existingUser.dailyTargetEnergy = user.dailyTargetEnergy;
                existingUser.dailyTargetSodium = user.dailyTargetSodium;
                existingUser.maxPacketsPerFoodProductDaily = user.maxPacketsPerFoodProductDaily;
                existingUser.profileImage = user.profileImage;
                existingUser.synchronized = @NO;
                existingUser.lastModifiedDate = currentDate;
                existingUser.deleted = user.deleted;
                // Save changes in the managedObjectContext
                [self.managedObjectContext save:error];
                
                for (StringWrapper *s in user.faceImages) {
                    [self.managedObjectContext insertObject:s];
                }
                existingUser.faceImages = user.faceImages;
            }
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
    NSDate *currentDate = [NSDate date];
    user.synchronized = @NO;
    user.lastModifiedDate = currentDate;
    user.deleted = @YES;
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fullName LIKE %@) AND (deleted == NO)",
                              [NSString stringWithFormat:@"*%@*", partialName]];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"User"
                                                    inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    [request setPredicate:predicate];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    
    [LoggingHelper logMethodExit:methodName returnValue:result];
    return result;
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fullName == %@) AND (deleted == NO)", fullName];
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

        /* lock is removed
        [self.lockService acquireLock:user error:error];
        [LoggingHelper logError:methodName error:*error];
        
        if (*error) {
            [LoggingHelper logMethodExit:methodName returnValue:nil];
            return nil;
        } else {

            [LoggingHelper logMethodExit:methodName returnValue:user];
            return user;
        }*/
        
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

-(BOOL)isAuthorized:(User *)user action:(NSString *)action error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.isAuthorized:action:error", NSStringFromClass(self.class)];
    
    //Check user == nil?
    if(user == nil || action == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"UserServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"user or action should not be nil"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return NO;
    }
    
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user", @"action"] params:@[user, action]];
    
	BOOL result = YES;
    if ([[self.permissions valueForKey:action] boolValue]) {
        result = user.admin.boolValue;
    }
    
    [LoggingHelper logMethodExit:methodName returnValue:(result ? @"YES" : @"NO")];
    return result;
}


@end
