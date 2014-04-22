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
//  FoodProductServiceImpl.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//
//  Updated by pvmagacho on 04/19/2014
//  F2Finish - NASA iPad App Updates
//

#import "FoodProductServiceImpl.h"
#import "LoggingHelper.h"

@implementation FoodProductServiceImpl

-(AdhocFoodProduct *)buildAdhocFoodProduct:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.buildAdhocFoodProduct:", NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AdhocFoodProduct"
                                              inManagedObjectContext:[self managedObjectContext]];
    AdhocFoodProduct *product = [[AdhocFoodProduct alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    product.name = @"";
    product.barcode = @"";
    product.images = [NSMutableSet set];
    product.origin = @"";
    product.category = @"";
    product.fluid = @0;
    product.energy = @0;
    product.sodium = @0;
    product.protein = @0;
    product.carb = @0;
    product.fat = @0;
    product.active = @NO;
    product.productProfileImage = nil;
    product.user = nil;
    product.deleted = @NO;
    
    [LoggingHelper logMethodExit:methodName returnValue:product];
    return product;
}

-(FoodProductFilter *)buildFoodProductFilter:(NSError** )error {
    NSString *methodName = [NSString stringWithFormat:@"%@.buildFoodProductFilter:", NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FoodProductFilter"
                                              inManagedObjectContext:[self managedObjectContext]];
    FoodProductFilter *filter = [[FoodProductFilter alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    filter.name = @"";
    filter.origins = [NSMutableSet set];
    filter.categories = [NSMutableSet set];
    filter.favoriteWithinTimePeriod = @0;
    filter.sortOption = @(A_TO_Z);
    filter.deleted = @NO;
    
    [LoggingHelper logMethodExit:methodName returnValue:filter];
    return filter;
}

-(BOOL)addAdhocFoodProduct:(User *)user product:(AdhocFoodProduct *)product error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.addAdhocFoodProduct:product:error:",
                                    NSStringFromClass(self.class)];
    
    //Check user or product == nil?
    if(user == nil || product == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"FoodProductServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"user or product should not be nil"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return NO;
    }
   
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user", @"product"] params:@[user, product]];
    
    //Add adhoc product
    [self.managedObjectContext lock];
    NSDate *currentDate = [NSDate date];
    product.createdDate = currentDate;
    product.lastModifiedDate = currentDate;
    product.synchronized = @NO;
    NSSet *images = product.images;
    product.images = nil;
    [self.managedObjectContext insertObject:product];
    // Save changes in the managedObjectContext
    [self.managedObjectContext save:error];
    
    for (StringWrapper *s in images) {
        [self.managedObjectContext insertObject:s];
    }
    // Save changes in the managedObjectContext
    [self.managedObjectContext save:error];
    product.user = user;
    product.images = images;
    [self.managedObjectContext save:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    
    [LoggingHelper logMethodExit:methodName returnValue:nil];
    return YES;
}

-(BOOL)deleteAdhocFoodProduct:(AdhocFoodProduct *)product error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.deleteAdhocFoodProduct:error:",
                                    NSStringFromClass(self.class)];
    
    //Check product == nil?
    if(product == nil){
        if(error)
        {
            *error = [NSError errorWithDomain:@"FoodProductServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"product should not be nil"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return NO;
    }
    
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"product"] params:@[product]];
    
    //Delete adhoc product
    [self.managedObjectContext lock];
    NSDate *currentDate = [NSDate date];
    product.synchronized = @NO;
    product.lastModifiedDate = currentDate;
    product.deleted = @YES;
    [self.managedObjectContext save:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    
    [LoggingHelper logMethodExit:methodName returnValue:nil];
    return YES;
}

-(NSArray *)filterFoodProducts:(User *)user filter:(FoodProductFilter *)filter error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.filterFoodProducts:filter:error:",
                                    NSStringFromClass(self.class)];
    
    //Check user == nil or filter == nil?
    if(user == nil || filter == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"FoodProductServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"user or filter should not be nil"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return nil;
    }
    
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"filter", @"user"] params:@[filter,user]];
    
    
    // Prepare fetch predicate string
    NSMutableString *predicateString = [NSMutableString stringWithString:@"(deleted == NO)"];
    NSMutableArray *arguments = [NSMutableArray array];
//    if ([filter.adhocOnly boolValue]) {
//        predicateString = [NSMutableString stringWithString:@"(deleted == NO) AND (user == %@)"];
//        arguments = [NSMutableArray arrayWithObject:user];
//    }else {
//        predicateString = [NSMutableString stringWithString:@"(deleted == NO)"];
//        arguments = [NSMutableArray array];
//    }
    if (filter.name) {
        [predicateString appendString:@" AND (name LIKE[c] %@)"];
        [arguments addObject:[NSString stringWithFormat:@"*%@*", filter.name]];
    }
    if (filter.origins && filter.origins.count) {
        [predicateString appendString:@" AND (origin IN %@)"];
        NSMutableArray *originsArray = [NSMutableArray arrayWithCapacity:filter.origins.count];
        for(StringWrapper *stringWrapper in filter.origins) {
            [originsArray addObject:stringWrapper.value];
        }
        [arguments addObject:originsArray];
    }
    if (filter.categories && filter.categories.count) {
        [predicateString appendString:@" AND (category IN %@)"];
        NSMutableArray *categoriesArray = [NSMutableArray arrayWithCapacity:filter.categories.count];
        for(StringWrapper *stringWrapper in filter.categories) {
            [categoriesArray addObject:stringWrapper.value];
        }
        [arguments addObject:categoriesArray];
    }
    
    [self.managedObjectContext lock];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString argumentArray:arguments];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"FoodProduct"
                                                   inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:description];
    [request setPredicate:predicate];
    
    // Set sort descriptor
    int option = [filter.sortOption integerValue];
    if (option == A_TO_Z) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                            ascending:YES]]];
    } else if (option == Z_TO_A) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                            ascending:NO]]];
    } else if (option == ENERGY_HIGH_TO_LOW) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"energy"
                                                                                            ascending:NO]]];
    } else if (option == ENERGY_LOW_TO_HIGH) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"energy"
                                                                                            ascending:YES]]];
    } else if (option == FLUID_HIGH_TO_LOW) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fluid"
                                                                                            ascending:NO]]];
    } else if (option == FLUID_LOW_TO_HIGH) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fluid"
                                                                                            ascending:YES]]];
    } else if (option == SODIUM_HIGH_TO_LOW) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sodium"
                                                                                            ascending:NO]]];
    } else if (option == SODIUM_LOW_TO_HIGH) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sodium"
                                                                                            ascending:YES]]];
    } else if (option == PROTEIN_LOW_TO_HIGH) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"protein"
                                                                    ascending:NO]]];
    } else if (option == PROTEIN_LOW_TO_HIGH) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"protein"
                                                                    ascending:YES]]];
    } else if (option == CARB_LOW_TO_HIGH) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"carb"
                                                                    ascending:NO]]];
    } else if (option == CARB_LOW_TO_HIGH) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"carb"
                                                                    ascending:YES]]];
    } else if (option == FAT_LOW_TO_HIGH) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fat"
                                                                    ascending:NO]]];
    } else if (option == FAT_LOW_TO_HIGH) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fat"
                                                                    ascending:YES]]];
    }
    
    // Execute fetch request and filter
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:error];
    [LoggingHelper logError:methodName error:*error];
    
    // Filter results by user and whether filter is adhoc only
    result = [self filterResult:result user:user adhocOnly:[filter.adhocOnly boolValue]];
    
    // Sort by consumption frequency
    if (option == FREQUENCY_HIGH_TO_LOW) {
        result = [result sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            return [self compareFoodProduct:a secondProduct:b error:error];
        }];
    } else if (option == FREQUENCY_LOW_TO_HIGH) {
        result = [result sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            return [self compareFoodProduct:b secondProduct:a error:error];
        }];
    }
    
    // Filter by favorite within time period
    if (filter.favoriteWithinTimePeriod && filter.favoriteWithinTimePeriod.intValue > 0) {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:result];
        // Filter by favorite status
        NSMutableArray *toRemove = [NSMutableArray array];
        for (FoodProduct* item in result) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            description = [NSEntityDescription  entityForName:@"FoodConsumptionRecord"
                                       inManagedObjectContext:[self managedObjectContext]];
            predicate = [NSPredicate predicateWithFormat:@"(foodProduct == %@) AND (timestamp >= %@)",
                                        item, [NSDate dateWithTimeIntervalSinceNow:-(24 * 3600 * filter.favoriteWithinTimePeriod.intValue)]];
            [request setEntity:description];
            [request setPredicate:predicate];
            //unsigned int count = [[self managedObjectContext] countForFetchRequest:request error:error];
            NSArray *tmp = [[self managedObjectContext] executeFetchRequest:request error:error];
            unsigned int count = tmp.count;
            [LoggingHelper logError:methodName error:*error];
            if (*error) {
                [LoggingHelper logMethodExit:methodName returnValue:nil];
                return nil;
            }
            if (count == 0) {
                [toRemove addObject:item];
            }
        }
        [temp removeObjectsInArray:toRemove];
        result = [NSArray arrayWithArray:temp];
    }
    
    // Save filter and update user
    NSDate *currentDate = [NSDate date];
    if (!filter.managedObjectContext) {
        filter.createdDate = currentDate;
        filter.lastModifiedDate = currentDate;
        filter.synchronized = @NO;
        NSSet *origins = filter.origins;
        NSSet *categories = filter.categories;
        filter.origins = nil;
        filter.categories = nil;
        [self.managedObjectContext insertObject:filter];
        // Save changes in the managedObjectContext
        [self.managedObjectContext save:error];
        
        for (StringWrapper *s in origins) {
            [self.managedObjectContext insertObject:s];
        }
        for (StringWrapper *s in categories) {
            [self.managedObjectContext insertObject:s];
        }
        filter.origins = origins;
        filter.categories = categories;
        [self.managedObjectContext save:error];
    }
    if (user) {
        user.lastUsedFoodProductFilter = filter;
        user.lastModifiedDate = [NSDate date];
        user.synchronized = @NO;
    }
    [self.managedObjectContext save:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    
    [LoggingHelper logMethodExit:methodName returnValue:result];
    return result;
}

-(FoodProduct *)getFoodProductByBarcode:(User *)user barcode:(NSString *)barcode error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.getFoodProductByBarcode:barcode:error:",
                                    NSStringFromClass(self.class)];
    
    //Check user or barcode == nil?
    if(user == nil || barcode == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"FoodProductServiceImpl" code:IllegalArgumentErrorCode
                                     userInfo:@{NSUnderlyingErrorKey: @"user or barcode should not be nil"}];
            
           [LoggingHelper logError:methodName error:*error];
        }
        return nil;
    }
  
    if (user != nil) {
        [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user", @"barcode"] params:@[user, barcode]];
    }else{
        [LoggingHelper logMethodEntrance:methodName paramNames:@[@"barcode"] params:@[barcode]];
    }
    
    [self.managedObjectContext lock];
    //Fetch food product by bar code
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(barcode beginswith[cd] %@) AND (deleted == NO)",
                                            [barcode substringToIndex:4]];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodProduct"
                                                    inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    [request setPredicate:predicate];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:error];
    [self.managedObjectContext unlock];
    [LoggingHelper logError:methodName error:*error];
    
    //Return product
    FoodProduct *ret = nil;
    if (result.count > 0) {
        for (FoodProduct *p in result) {
            if ([p isKindOfClass:[AdhocFoodProduct class]]) {
                if (user != nil && [((AdhocFoodProduct *)p).user isEqual:user]) {
                    ret = p;
                    break;
                }
            }
            else {
                ret = p;
                break;
            }
        }
        [LoggingHelper logMethodExit:methodName returnValue:ret];
        return ret;
    } else {
        if(error) {
            *error = [[NSError alloc] initWithDomain:@"FoodProductService"
                                                code:EntityNotFoundErrorCode
                                            userInfo:@{NSLocalizedDescriptionKey: @"No such food product."}];
        }
        [LoggingHelper logMethodExit:methodName returnValue:nil];
        return nil;
    }
    return ret;
}

-(FoodProduct *)getFoodProductByName:(User *)user name:(NSString *)name error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.getFoodProductByName:name:error:", NSStringFromClass(self.class)];
    
    //Check name == nil?
    if(name == nil){
        *error = [NSError errorWithDomain:@"FoodProductServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:[NSDictionary dictionaryWithObject:@"name should not be nil" forKey:NSUnderlyingErrorKey]];
        [LoggingHelper logError:methodName error:*error];
        return nil;
    }
    
    if (user == nil) {
        [LoggingHelper logMethodEntrance:methodName paramNames:@[@"name"] params:@[name]];
    }else{
        [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user", @"name"] params:@[user, name]];
    }
    
    //Fetch food product
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@) AND (deleted == NO)", name];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodProduct" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    [request setPredicate:predicate];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:error];
    [LoggingHelper logError:methodName error:*error];
    
    //return food product if user is nil and name matches; or return adhoc food product if user is not nil and name matches
    FoodProduct *ret = nil;
    if (result.count > 0) {
        for (FoodProduct *p in result) {
            if ([p isKindOfClass:[AdhocFoodProduct class]]) {
                if (user != nil && [((AdhocFoodProduct *)p).user isEqual:user]) {
                    ret = p;
                    break;
                }
            }
            else {
                ret = p;
                break;
            }
        }
        [LoggingHelper logMethodExit:methodName returnValue:ret];
        return ret;
    } else {
        *error = [[NSError alloc] initWithDomain:@"FoodProductService" code:EntityNotFoundErrorCode userInfo:[NSDictionary dictionaryWithObject:@"No such food product." forKey:NSLocalizedDescriptionKey]];
        [LoggingHelper logMethodExit:methodName returnValue:nil];
        return nil;
    }
    
    //return products
    return ret;
}

-(NSArray *)getAllProductCategories:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.getAllProductCategories:", NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    [self.managedObjectContext lock];
    //Fetch categories
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category != '' AND category != 'Vitamins / Supplements' AND deleted == NO"];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodProduct"
                                                    inManagedObjectContext:self.managedObjectContext];
    NSExpression *categoryExpression = [NSExpression expressionForKeyPath:@"category"];
    NSExpressionDescription *expression = [[NSExpressionDescription alloc] init];
    expression.name = @"category";
    expression.expression = categoryExpression;
    expression.expressionResultType = NSStringAttributeType;
    [request setEntity:description];
    [request setPredicate:predicate];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[expression]];
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    NSMutableArray *categories = [NSMutableArray arrayWithCapacity:result.count];
    for (NSDictionary *category in result) {
        [categories addObject:[category valueForKey:@"category"]];
    }
    [LoggingHelper logMethodExit:methodName returnValue:categories];
    return categories;
}

-(NSArray *)getAllProductOrigins:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.getAllProductOrigins:", NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    [self.managedObjectContext lock];
    //Fetch origins
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"origin != '' AND deleted == NO"];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodProduct"
                                                    inManagedObjectContext:self.managedObjectContext];
    NSExpression *categoryExpression = [NSExpression expressionForKeyPath:@"origin"];
    NSExpressionDescription *expression = [[NSExpressionDescription alloc] init];
    expression.name = @"origin";
    expression.expression = categoryExpression;
    expression.expressionResultType = NSStringAttributeType;
    [request setEntity:description];
    [request setPredicate:predicate];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[expression]];
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    NSMutableArray *origins = [NSMutableArray arrayWithCapacity:result.count];
    for (NSDictionary *origin in result) {
        [origins addObject:[origin valueForKey:@"origin"]];
    }
    [LoggingHelper logMethodExit:methodName returnValue:origins];
    return origins;
}

//A private method to filter predicated result
-(NSArray *)filterResult:(NSArray *)result user:(User *)user adhocOnly:(BOOL)adhocOnly
{
    //filter result
    NSMutableArray *filteredResult = [NSMutableArray array];
    for (id product in result) {
        if ([product isKindOfClass:[AdhocFoodProduct class]]) {
            AdhocFoodProduct *adhcFoodProduct = (AdhocFoodProduct *)product;
            if ([adhcFoodProduct.user isEqual:user]) {
                [filteredResult addObject:adhcFoodProduct];
                continue;
            }
        }
        else {
            //General food product is also valid
            if (!adhocOnly) {
                [filteredResult addObject:product];
            }
        }
    }
    return filteredResult;
}

//Compare two products by their counts.
-(NSComparisonResult)compareFoodProduct:(id)firstProduct secondProduct:(id)secondProduct error:(NSError **)error
{
    [self.managedObjectContext lock];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodConsumptionRecord"
                                                    inManagedObjectContext:[self managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(foodProduct == %@)", firstProduct];
    [request setEntity:description];
    [request setPredicate:predicate];
    unsigned int count1 = [[self managedObjectContext] countForFetchRequest:request error:error];
    
    predicate = [NSPredicate predicateWithFormat:@"(foodProduct == %@)", secondProduct];
    [request setPredicate:predicate];
    unsigned int count2 = [[self managedObjectContext] countForFetchRequest:request error:error];
    [self.managedObjectContext unlock];
    if (count1 < count2) {
        return NSOrderedDescending;
    } else if (count1 == count2) {
        return NSOrderedSame;
    } else {
        return NSOrderedAscending ;
    }
}
@end
