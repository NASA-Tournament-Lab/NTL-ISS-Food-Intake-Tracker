//
//  DataHelper.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 8/5/13.
//  Copyright (c) 2013 TopCoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Models.h"

/*!
 @class DataHelper
 @discussion This class is a helper class used for managing data.
 
 @ Changes in 1.1
   Added support for protein/carb/fat

 @author LokiYang, subchap
 @version 1.1
 @since 1.0
 */
@interface DataHelper : NSObject

/*!
 @discussion It will convert the NSString to a NSSet with managed objects. 
        The string is separated by the separator.
 @param str The string.
 @param entity The managed object's entity description.
 @param context The entity's context.
 @param separator The separator used to split the string.
 @return The NSSet with manged objects.
 */
+ (NSSet *)convertNSStringToNSSet:(NSString *)str withEntityDescription:(NSEntityDescription *)entity
           inManagedObjectContext:(NSManagedObjectContext*)context withSeparator:(NSString *)separator;


/*!
 @discussion This method will convert the NSSet of StringWrapper to NSString by using the separator.
 @param set The NSSet.
 @param separator The separator used to join StringWrapper in NSString.
 @return The NSString with joined StringWrapper.
 */
+ (NSString *)convertStringWrapperNSSetToNSString:(NSSet *)set withSeparator:(NSString *)separator;


/*!
 @discussion This method will get the device's identifier. It will fetch uniquely identifies a device to the app’s
 vendor in iOS 6.0 and later, or fetch MAC address as the identifier previous iOS 6.0.
 @return The device's indentifier string.
 */
+ (NSString *)getDeviceIdentifier;

/*!
 @discussion This method will build a User instance from the array data.
 @param data The array contains User info.
 @param context The maanged object context the new User belongs to.
 @param error The error.
 @return A new User instance. 
 */
+ (User *)buildUserFromData:(NSArray *)data
     inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error;

/*!
 @discussion This method will build a FoodConsumptionRecord instance from the array data.
 @param data The array contains FoodConsumptionRecord info.
 @param context The maanged object context the new FoodConsumptionRecord belongs to.
 @param error The error.
 @return A new FoodConsumptionRecord instance.
 */
+ (FoodConsumptionRecord *)buildFoodConsumptionRecordFromData:(NSArray *)data
                                       inManagedObjectContext:(NSManagedObjectContext *)context
                                                        error:(NSError **)error;

/*!
 @discussion This method will build a AdhocFoodProduct instance from the array data.
 @param data The array contains AdhocFoodProduct info.
 @param context The maanged object context the newAdhocFoodProductUser belongs to.
 @param error The error.
 @return A new AdhocFoodProduct instance.
 */
+ (AdhocFoodProduct *)buildAdhocFoodProductFromData:(NSArray *)data
                             inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error;

/*!
 @discussion This method will build a FoodProductSortOption from string.
 @param str The string representation of FoodProductSortOption
 @return The FoodProductSortOption enum
 */
+ (FoodProductSortOption)buildFoodProductSortOptionFromString:(NSString *)str;

/*!
 @discussion This method will format a FoodProductSortOption to string.
 @param The NSNumber stores FoodProductSortOption enum
 @return str The string representation of FoodProductSortOption
 */
+ (NSString*)formatFoodProductSortOptionToString:(NSNumber *)sortOption;

/*!
 @discussion This method will get the LocalFileSystemDirectory absolute directory in "Document" folder.
 @return The absolute directory of the LocalFileSystemDirectory. 
 */
+ (NSString *)getAbsoulteLocalDirectory:(NSString *)localDirectory;
@end
