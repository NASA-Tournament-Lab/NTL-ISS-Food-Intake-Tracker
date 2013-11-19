//
//  FoodProductServiceTests.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import "FoodProductServiceTests.h"

@implementation FoodProductServiceTests

@synthesize foodProductService;
@synthesize userService;

/*!
 @discussion Set up testing environment. It creates managed object context and populate some testing data.
 */
-(void)setUp {
    [super setUp];
    
    // insert some test data
    [self.managedObjectContext lock];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:self.managedObjectContext];
    User *user1 = [[User alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    user1.fullName = @"user1";
    user1.deleted = @NO;
    
    User *user2 = [[User alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    user2.fullName = @"user2";
    user2.deleted = @NO;
    
    entity = [NSEntityDescription entityForName:@"AdhocFoodProduct" inManagedObjectContext:self.managedObjectContext];
    AdhocFoodProduct *product1 = [[AdhocFoodProduct alloc] initWithEntity:entity
                                           insertIntoManagedObjectContext:self.managedObjectContext];
    product1.name = @"product1";
    product1.barcode = @"12345";
    product1.origin = @"origin1";
    product1.category = @"category1";
    product1.fluid = @10;
    product1.energy = @20;
    product1.sodium = @5;
    product1.active = @YES;
    product1.user = user1;
    product1.deleted = @NO;
    product1.images = [NSMutableSet set];
    product1.productProfileImage = @"product1.png";
    
    entity = [NSEntityDescription entityForName:@"FoodProduct" inManagedObjectContext:self.managedObjectContext];
    FoodProduct *product2 = [[FoodProduct alloc] initWithEntity:entity
                                 insertIntoManagedObjectContext:self.managedObjectContext];
    product2.name = @"product2";
    product2.barcode = @"54321";
    product2.origin = @"origin2";
    product2.category = @"category2";
    product2.fluid = @20;
    product2.energy = @30;
    product2.sodium = @10;
    product2.active = @NO;
    product2.deleted = @NO;
    product2.images = [NSMutableSet set];
    product2.productProfileImage = @"product2.png";
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    [self.managedObjectContext unlock];
    STAssertNil(error, @"No error should be returned");
    
    foodProductService = [[FoodProductServiceImpl alloc] init];
    userService = [[UserServiceImpl alloc] initWithConfiguration:self.configurations lockService:nil];
}

/*!
 @discussion Tear down testing environment. It deletes the database file.
 */
-(void)tearDown {
    [super tearDown];
}

/*!
 @discussion Test object initialization.
 */
-(void)testInit {
    STAssertNotNil(foodProductService, @"Initialization should succeed");
    STAssertNotNil(foodProductService.managedObjectContext, @"managedObjectContext should be initialized");
}

/*!
 @discussion Test buildAdhocFoodProduct method.
 */
-(void)testBuildAdhocFoodProduct {
    NSError *error = nil;
    AdhocFoodProduct *product = [foodProductService buildAdhocFoodProduct:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(product, @"AdhocFoodProduct should be created");
    STAssertEqualObjects(product.name, @"", @"name should be initialized");
    STAssertEqualObjects(product.barcode, @"", @"barcode should be initialized");
    STAssertEquals(product.active.boolValue, NO, @"active should be initialized");
    STAssertEquals(product.energy.intValue, 0, @"dailyTargetFluid should be initialized");
}

/*!
 @discussion Test buildFoodProductFilter method.
 */
-(void)testBuildFoodProductFilter {
    NSError *error = nil;
    FoodProductFilter *filter = [foodProductService buildFoodProductFilter:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(filter, @"FoodProductFilter should be created");
    STAssertEqualObjects(filter.name, @"", @"name should be initialized");
    STAssertEquals(filter.origins.count, (NSUInteger)0, @"origins should be initialized");
    STAssertEquals(filter.favoriteWithinTimePeriod.intValue, 0, @"favoriteWithinTimePeriod should be initialized");
    STAssertEquals(filter.sortOption.intValue, A_TO_Z, @"sortOption should be initialized");
}

/*!
 @discussion Test getFoodProductByBarcode method.
 */
-(void)testGetFoodProductByBarcode_Found {
    NSError *error = nil;
    User *user = [userService filterUsers:@"user1" error:&error][0];
    FoodProduct *product = [foodProductService getFoodProductByBarcode:user barcode:@"12345" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(product, @"product should be returned");
    STAssertEqualObjects(product.name, @"product1", @"returned product should have proper value set");
    STAssertEqualObjects(product.barcode, @"12345", @"returned product should have proper value set");
    STAssertEquals(product.fluid.intValue, 10, @"returned product should have proper value set");
}

/*!
 @discussion Test getFoodProductByBarcode method.
 */
-(void)testGetFoodProductByBarcode_NotFound {
    NSError *error = nil;
    User *user = [userService filterUsers:@"user1" error:&error][0];
    FoodProduct *product = [foodProductService getFoodProductByBarcode:user barcode:@"1234" error:&error];
    STAssertNotNil(error, @"No error should be returned");
    STAssertEqualObjects(error.domain, @"FoodProductService", @"error should contain correct information");
    STAssertNil(product, @"No product should be returned");
}

/*!
 @discussion Test getFoodProductByBarcode method with nil user and nil barcode
 */
-(void)testGetFoodProductByBarcode_NilUserNilBarcode {
    NSError *error = nil;
    FoodProduct *product = [foodProductService getFoodProductByBarcode:nil barcode:nil error:&error];
    STAssertNotNil(error, @"error should be returned");
    STAssertNil(product, @"no product should be returned");
}

/*!
 @discussion Test getFoodProductByName method.
 */
-(void)testGetFoodProductByName_Found {
    NSError *error = nil;
    User *user = [userService filterUsers:@"user1" error:&error][0];
    FoodProduct *product = [foodProductService getFoodProductByName:user name:@"product1" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(product, @"product should be returned");
    STAssertEqualObjects(product.name, @"product1", @"returned product should have proper value set");
    STAssertEqualObjects(product.barcode, @"12345", @"returned product should have proper value set");
    STAssertEquals(product.fluid.intValue, 10, @"returned product should have proper value set");
}

/*!
 @discussion Test getFoodProductByName method.
 */
-(void)testGetFoodProductByName_NotFound {
    NSError *error = nil;
    User *user = [userService filterUsers:@"user1" error:&error][0];
    FoodProduct *product = [foodProductService getFoodProductByName:user name:@"nosuchproduct" error:&error];
    STAssertNotNil(error, @"No error should be returned");
    STAssertEqualObjects(error.domain, @"FoodProductService", @"error should contain correct information");
    STAssertNil(product, @"No product should be returned");
}

/*!
 @discussion Test getFoodProductByName method with nil user and nil name
 */
-(void)testGetFoodProductByName_NilUserNilName {
    NSError *error = nil;
    FoodProduct *product = [foodProductService getFoodProductByName:nil name:nil error:&error];
    STAssertNotNil(error, @"error should be returned");
    STAssertNil(product, @"no product should be returned");
}

/*!
 @discussion Test addAdhocFoodProduct method.
 */
-(void)testAddAdhocFoodProduct {
    NSError *error = nil;
    
    AdhocFoodProduct *product = [foodProductService buildAdhocFoodProduct:&error];
    STAssertNil(error, @"No error should be returned");
    product.name = @"test";
    product.barcode = @"99999";
    product.origin = @"origin1";
    product.category = @"category1";
    product.fluid = @10;
    product.energy = @20;
    product.sodium = @5;
    product.active = @YES;
    product.deleted = @NO;
    product.images = [NSMutableSet set];
    product.productProfileImage = @"product1.png";

    User *user = [userService filterUsers:@"user2" error:&error][0];
    [foodProductService addAdhocFoodProduct:user product:product error:&error];
    STAssertNil(error, @"No error should be returned");
    
    product = (AdhocFoodProduct *)[foodProductService getFoodProductByBarcode:user barcode:@"99999" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(product, @"product should be returned");
    STAssertEqualObjects(product.name, @"test", @"returned product should have proper value set");
    STAssertEqualObjects(product.barcode, @"99999", @"returned product should have proper value set");
    STAssertEqualObjects(product.user, user, @"returned product should have proper value set");
}

/*!
 @discussion Test addAdhocFoodProduct method with nil user and nil product
 */
-(void)testAddAdhocFoodProduct_NilUserNilProduct {
    NSError *error = nil;
    [foodProductService addAdhocFoodProduct:nil product:nil error:&error];
    STAssertNotNil(error, @"error should be returned");
}

/*!
 @discussion Test deleteUser method.
 */
-(void)testDeleteAdhocFoodProduct {
    NSError *error = nil;
    User *user = [userService filterUsers:@"user1" error:&error][0];
    AdhocFoodProduct *product = (AdhocFoodProduct *)[foodProductService
                                                     getFoodProductByBarcode:user
                                                     barcode:@"12345" error:&error];
    [foodProductService deleteAdhocFoodProduct:product error:&error];
    STAssertNil(error, @"No error should be returned");
    product = (AdhocFoodProduct *)[foodProductService getFoodProductByBarcode:user barcode:@"12345" error:&error];
    STAssertNil(product, @"product should be deleted");
}

/*!
 @discussion Test getAllProductCategories method.
 */
-(void)testGetAllProductCategories {
    NSError *error = nil;
    NSArray *categories = [foodProductService getAllProductCategories:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertEquals(categories.count, (NSUInteger)2, @"2 categories should be returned");
    STAssertTrue([categories[0] isEqual:@"category1"] || [categories[0] isEqual:@"category2"],
                 @"categories should be returned");
    STAssertTrue([categories[1] isEqual:@"category1"] || [categories[1] isEqual:@"category2"],
                 @"categories should be returned");
    STAssertFalse([categories[0] isEqual:categories[1]], @"categories should be returned");
}

/*!
 @discussion Test getAllProductOrigins method.
 */
-(void)testGetAllProductOrigins {
    NSError *error = nil;
    NSArray *origins = [foodProductService getAllProductOrigins:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertEquals(origins.count, (NSUInteger)2, @"2 origins should be returned");
    STAssertTrue([origins[0] isEqual:@"origin1"] || [origins[0] isEqual:@"origin2"], @"origins should be returned");
    STAssertTrue([origins[1] isEqual:@"origin1"] || [origins[1] isEqual:@"origin2"], @"origins should be returned");
    STAssertFalse([origins[0] isEqual:origins[1]], @"origins should be returned");
}

/*!
 @discussion Test filterFoodProducts method to fetch only adhoc food product by user.
 */
-(void)testFilterFoodProducts_OnlyAdhocFoodProduct {
    NSError *error = nil;
    User *user = [userService filterUsers:@"user1" error:&error][0];
    FoodProductFilter *filter = [foodProductService buildFoodProductFilter:&error];
    STAssertNil(error, @"No error should be returned");
    filter.name = @"product";
    filter.adhocOnly = @YES;
    NSArray *products = [foodProductService filterFoodProducts:user filter:filter error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(products, @"products should be returned");
    STAssertEquals(products.count, (NSUInteger)1, @"1 product should be returned");
}

/*!
 @discussion Test filterFoodProducts method to fetch all food products, including adhoc food product by user.
 */
-(void)testFilterFoodProducts_AllFoodProducts
{
    NSError *error = nil;
    User *user = [userService filterUsers:@"user1" error:&error][0];
    FoodProductFilter *filter = [foodProductService buildFoodProductFilter:&error];
    filter.name = @"product";
    filter.adhocOnly = @NO;
    NSArray *products = [foodProductService filterFoodProducts:user filter:filter error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(products, @"products should be returned");
    STAssertEquals(products.count, (NSUInteger)2, @"2 product should be returned");
}

/*!
 @discussion Test filterFoodProducts method to fetch with empty filter.
 */
-(void)testFilterFoodProducts_EmptyFilter
{
    NSError *error = nil;
    User *user = [userService filterUsers:@"user1" error:&error][0];
    FoodProductFilter *filter = [foodProductService buildFoodProductFilter:&error];
    NSArray *products = [foodProductService filterFoodProducts:user filter:filter error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(products, @"products should be returned");
    STAssertEquals(products.count, (NSUInteger)2, @"2 product should be returned");
}

/*!
 @discussion Test filterFoodProducts method with nil user and filter input.
 */
-(void)testFilterFoodProducts_Error_NilUserNilFilter
{
    NSError *error = nil;
    User *user = nil;
    FoodProductFilter *filter = nil;
    NSArray *products = [foodProductService filterFoodProducts:user filter:filter error:&error];
    STAssertNotNil(error, @"error should be returned");
    STAssertNil(products, @"products should not be returned");
}


@end
