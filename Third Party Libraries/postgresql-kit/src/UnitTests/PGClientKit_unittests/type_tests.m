

// Copyright 2009-2015 David Thorpe
// https://github.com/djthorpe/postgresql-kit
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not
// use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.

#import <Foundation/Foundation.h>
#import <PGClientKit/PGClientKit.h>
#import <XCTest/XCTest.h>

////////////////////////////////////////////////////////////////////////////////

@interface type_tests : XCTestCase

@end

////////////////////////////////////////////////////////////////////////////////

@implementation type_tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

-(void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end


-(NSString* )stringForURL:(NSURL* )theURL {
	NSString* theString = [[self stringCache] objectForKey:theURL];
	if(theString==nil) {
		theString = [NSString stringWithContentsOfURL:theURL];
		if(theString) {
			[[self stringCache] setObject:theString forKey:theURL];
		}
	}
	return theString;
}

////////////////////////////////////////////////////////////////////////////

-(NSObject* )shortValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	if(row==0) {
		return [NSNumber numberWithShort:SHRT_MIN];
	} else if(row==1) {
		return [NSNumber numberWithShort:SHRT_MAX];
	} else if(row==2) {
		return [NSNumber numberWithShort:0];
	} else if(row==3) {
		return [NSNull null];
	} else {
		return [NSNumber numberWithShort:(short)(rand() % (int)SHRT_MAX)];
	}
}

-(NSObject* )integerValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	if(row==0) {
		return [NSNumber numberWithInt:INT_MIN];
	} else if(row==1) {
		return [NSNumber numberWithInt:INT_MAX];
	} else if(row==2) {
		return [NSNumber numberWithInt:0];
	} else if(row==3) {
		return [NSNull null];
	} else {
		return [NSNumber numberWithInt:(int)(rand())];
	}	
}

-(NSObject* )longLongValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	if(row==0) {
		return [NSNumber numberWithLongLong:LONG_LONG_MIN];
	} else if(row==1) {
		return [NSNumber numberWithLongLong:LONG_LONG_MAX];
	} else if(row==2) {
		return [NSNumber numberWithLongLong:0];
	} else if(row==3) {
		return [NSNull null];
	} else {
		return [NSNumber numberWithLongLong:(long long)(rand() * 100)];
	}		
}

-(NSObject* )floatValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	switch(row) {
		case 0:
			return [NSNumber numberWithFloat:0.0f];
		case 1:
			return [NSNumber numberWithFloat:MAXFLOAT];
		case 2:
			return [NSNull null];				
		default:
			return [NSNumber numberWithFloat:(float)(rand() * 1000)];
	}
}

-(NSObject* )doubleValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	switch(row) {
		case 0:
			return [NSNumber numberWithDouble:0.0];
		case 1:
			return [NSNumber numberWithDouble:MAXFLOAT];
		case 2:
			return [NSNumber numberWithDouble:__inf()];
		case 3:
			return [NSNumber numberWithDouble:(-__inf())];
		case 4:
			return [NSNumber numberWithDouble:__nan()];
		case 5:
			return [NSNumber numberWithDouble:__nan()];
		case 6:
			return [NSNull null];				
		case 7:
			return [NSNumber numberWithDouble:M_E];
		case 8:
			return [NSNumber numberWithDouble:M_LOG2E];
		case 9:
			return [NSNumber numberWithDouble:M_LOG10E];
		case 10:
			return [NSNumber numberWithDouble:M_LN2];
		case 11:
			return [NSNumber numberWithDouble:M_LN10];
		case 12:
			return [NSNumber numberWithDouble:M_PI];
		case 13:
			return [NSNumber numberWithDouble:M_PI_2];
		case 14:
			return [NSNumber numberWithDouble:M_PI_4];
		case 15:
			return [NSNumber numberWithDouble:M_1_PI];
		case 16:
			return [NSNumber numberWithDouble:M_2_PI];
		case 17:
			return [NSNumber numberWithDouble:M_2_SQRTPI];
		case 18:
			return [NSNumber numberWithDouble:M_SQRT2];
		case 19:
			return [NSNumber numberWithDouble:M_SQRT1_2];
		default:
			return [NSNumber numberWithDouble:(double)(rand() * 100000)];
	}
}

-(NSObject* )stringValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	switch(row) {
		case 0:
			return [NSString string];
		case 1:
			return [NSNull null];		
		case 2:
			return [self stringForURL:[NSURL URLWithString:@"http://newsrss.bbc.co.uk/rss/newsonline_uk_edition/front_page/rss.xml"]];
		case 3:
			return [self stringForURL:[NSURL URLWithString:@"http://newsrss.bbc.co.uk/rss/arabic/news/rss.xml"]];
		case 4:
			return [self stringForURL:[NSURL URLWithString:@"http://www.bbc.co.uk/mundo/index.xml"]];
		case 5:
			return [self stringForURL:[NSURL URLWithString:@"http://www.bbc.co.uk/russian/index.xml"]];
		case 6:
			return [self stringForURL:[NSURL URLWithString:@"http://newsrss.bbc.co.uk/rss/chinese/simp/news/rss.xml"]];
	}
	
	NSString* theString = (NSString* )[self stringValueForRow:[NSNumber numberWithUnsignedInteger:((row % 5) + 2)]];
	NSParameterAssert([theString isKindOfClass:[NSString class]]);
	return [theString substringToIndex:row];
}

-(NSObject* )varcharValueForRow:(NSNumber* )theRow {
	NSObject* theObject = [self stringValueForRow:theRow];
	if([theObject isKindOfClass:[NSNull class]]) return theObject;
	NSParameterAssert([theObject isKindOfClass:[NSString class]]);
	NSString* theString = (NSString* )theObject;
	if([theString length] < 80) return theString;
	
	// return first 80 characters
	return [(NSString* )theObject substringToIndex:80];
}

-(NSObject* )charValueForRow:(NSNumber* )theRow {
	NSUInteger theLength = (NSUInteger)(rand() % 80);
	NSObject* theObject = [self stringValueForRow:theRow];
	if([theObject isKindOfClass:[NSNull class]]) return theObject;
	
	NSString* theString = (NSString* )theObject;
	if([theString length] > 80) {
		theString = [theString substringToIndex:theLength];
	}
	// pad to 80 characters
	return [theString stringByPaddingToLength:80 withString:@" " startingAtIndex:0];
}

-(NSObject* )nameValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	switch(row) {
		case 0:
			return @"abcdefghijklmnopqrstuvwxzy";
		case 1:
			return @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		default:
			return [NSNull null];
	}			
}

-(NSObject* )booleanValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	switch(row) {
		case 0:
			return [NSNumber numberWithBool:YES];
		case 1:
			return [NSNumber numberWithBool:NO];
		default:
			return [NSNull null];
	}			
}

-(NSObject* )unsignedIntegerValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	NSNumber* theNumber = nil;
	switch(row) {
		case 0:
			theNumber = [NSNumber numberWithUnsignedInt:((unsigned int)UINT_MAX)];
			break;
		case 1:
			// NOTE: not a valid Oid?
			theNumber = [NSNumber numberWithUnsignedInt:0];
			break;
		case 2:
			return [NSNull null];
		default:
			theNumber = [NSNumber numberWithUnsignedInt:((unsigned int)row)];
			break;
	}			
	return theNumber;
}

-(NSObject* )dataValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	NSString* thePath = @"/etc";
	NSArray* theDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:thePath error:nil];
	NSParameterAssert(theDirectory);
	if(row >= [theDirectory count]) return [NSNull null];
	NSString* theFilename = [thePath stringByAppendingPathComponent:[theDirectory objectAtIndex:row]];
	BOOL isDirectory;
	if([[NSFileManager defaultManager] fileExistsAtPath:theFilename isDirectory:&isDirectory]==NO) return [NSNull null];
	if([[NSFileManager defaultManager] isReadableFileAtPath:theFilename]==NO) return [NSNull null];	
	if(isDirectory==YES) return [NSNull null];	
	NSData* theData = [NSData dataWithContentsOfFile:theFilename];
	if(theData==nil)  return [NSNull null];
	return theData;
}


-(NSObject* )intervalValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	switch(row) {
		case 0:
			return [FLXTimeInterval interval];
			break;
		case 1:
			return [NSNull null];
			break;
		default:
			return [FLXTimeInterval intervalWithSeconds:(NSTimeInterval)(rand() - 10000.0) days:rand() months:rand()];
	}			
}

-(NSObject* )pointValueForRow:(NSNumber* )theRow {
	FLXGeometryPt p = FLXMakePoint((double)rand() / (double)rand(),(double)rand() / (double)rand());
	FLXGeometry* thePoint = [FLXGeometry pointWithOrigin:p];
	return thePoint;
}

-(NSObject* )lineValueForRow:(NSNumber* )theRow {
	FLXGeometryPt p1 = FLXMakePoint((double)rand() / (double)rand(),(double)rand() / (double)rand());
	FLXGeometryPt p2 = FLXMakePoint((double)rand() / (double)rand(),(double)rand() / (double)rand());
	FLXGeometry* theLine = [FLXGeometry lineWithOrigin:p1 destination:p2];
	return theLine;
}

-(NSObject* )boxValueForRow:(NSNumber* )theRow {
	FLXGeometryPt p1 = FLXMakePoint((double)rand() / (double)rand(),(double)rand() / (double)rand());
	FLXGeometryPt p2 = FLXMakePoint((double)rand() / (double)rand(),(double)rand() / (double)rand());
	FLXGeometry* theBox = [FLXGeometry boxWithPoint:p1 point:p2];
	return theBox;
}

-(NSObject* )circleValueForRow:(NSNumber* )theRow {
	FLXGeometryPt p = FLXMakePoint((double)rand() / (double)rand(),(double)rand() / (double)rand());
	double r = (double)rand() / (double)rand();
	FLXGeometry* theCircle = [FLXGeometry circleWithCentre:p radius:r];
	return theCircle;
}

-(NSObject* )polygonValueForRow:(NSNumber* )theRow {
	// how many points?
	NSUInteger numPoints = [theRow unsignedIntegerValue];
	
	// return null if number of points is less than one
	if(numPoints < 1) {
		return [NSNull null];
	}

	// set polygon radius
	double theRadius = (double)rand() / (double)rand();
	double theAngleStep = (2.0 * M_PI) / numPoints;
	
	// create the points
	FLXGeometryPt* points = malloc(sizeof(FLXGeometryPt) * numPoints);
	NSParameterAssert(points);
	for(NSUInteger i = 0; i < numPoints; i++) {
		double theAngle = theAngleStep * (double)i;
		points[i] = FLXMakePoint(cos(theAngle) * theRadius,sin(theAngle) * theRadius);
	}
	// create the polygon
	FLXGeometry* thePolygon = [FLXGeometry polygonWithPoints:points count:numPoints];
	// free points
	free(points);
	// return polygon
	return thePolygon;
}

-(NSObject* )pathValueForRow:(NSNumber* )theRow {
	// how many points?
	NSUInteger numPoints = [theRow unsignedIntegerValue];
	
	// return null if number of points is less than one
	if(numPoints < 1) {
		return [NSNull null];
	}
	
	// is closed path?
	BOOL isClosedPath = (numPoints % 2) ? YES : NO;
	// create the points
	FLXGeometryPt* points = malloc(sizeof(FLXGeometryPt) * numPoints);
	NSParameterAssert(points);
	for(NSUInteger i = 0; i < numPoints; i++) {
		points[i] = FLXMakePoint((double)rand(),(double)rand());
	}
	// create the path
	FLXGeometry* thePath = [FLXGeometry pathWithPoints:points count:numPoints closed:isClosedPath];
	// free points
	free(points);
	// return path
	return thePath;
}

-(NSObject* )dateValueForRow:(NSNumber* )theRow {
	return [NSDate date];
}

-(NSObject* )macaddrValueForRow:(NSNumber* )theRow {
	// create data structure to hold data
	NSMutableData* theData = [NSMutableData dataWithCapacity:6];
	for(NSUInteger i = 0; i < 6; i++) {
		char c = rand() % 0xFF;		
		[theData appendBytes:&c length:1];
	}
	return [FLXMacAddr macAddrWithBytes:[theData bytes]];
}

-(NSObject* )stringArrayValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	switch(row) {
		case 0:
			return [NSNull null];
		case 1:
			return [NSArray array];
		case 2:
			return [NSArray arrayWithObject:@"test"];
		case 3:
			return [NSArray arrayWithObjects:@"test",[NSNull null],nil];
		case 4:
			return [NSArray arrayWithObjects:@"test",[NSNull null],@"test",nil];
		case 5:
			return [NSArray arrayWithObjects:[NSNull null],@"test",[NSNull null],@"test",nil];
	}
	
	// create array with row tuples
	NSMutableArray* theArray = [NSMutableArray arrayWithCapacity:row];
	for(NSUInteger i = 0; i < row; i++) {
		[theArray addObject:[self stringValueForRow:theRow]];
	}
	
	return theArray;
}

-(NSObject* )booleanArrayValueForRow:(NSNumber* )theRow {
	NSUInteger row = [theRow unsignedIntegerValue];
	NSMutableArray* theArray = [NSMutableArray arrayWithCapacity:row];
	for(NSUInteger i = 0; i < row; i++) {
		[theArray addObject:[self booleanValueForRow:theRow]];
	}	
	return theArray;
}

////////////////////////////////////////////////////////////////////////////

 -(void)doWork { 
	 NSString* theSchema = @"public";
	 NSString* theTable = @"test";
	 NSUInteger numberOfRows = 100;
	 NSArray* theTypes = [NSArray arrayWithObjects:
	 // text
	 [NSArray arrayWithObjects:@"text",@"NSString",@"stringValueForRow:",nil],						 
     [NSArray arrayWithObjects:@"char(80)",@"NSString",@"charValueForRow:",nil],
	 [NSArray arrayWithObjects:@"varchar(80)",@"NSString",@"varcharValueForRow:",nil],
	 [NSArray arrayWithObjects:@"name",@"NSString",@"nameValueForRow:",nil],
	 // numbers
	 [NSArray arrayWithObjects:@"boolean",@"NSNumber",@"booleanValueForRow:",nil],
     [NSArray arrayWithObjects:@"bytea",@"NSData",@"dataValueForRow:",nil],
	 [NSArray arrayWithObjects:@"int2",@"NSNumber",@"shortValueForRow:",nil],
	 [NSArray arrayWithObjects:@"int4",@"NSNumber",@"integerValueForRow:",nil],
	 [NSArray arrayWithObjects:@"int8",@"NSNumber",@"longLongValueForRow:",nil],
	 [NSArray arrayWithObjects:@"float4",@"NSNumber",@"floatValueForRow:",nil],
	 [NSArray arrayWithObjects:@"float8",@"NSNumber",@"doubleValueForRow:",nil],
	 [NSArray arrayWithObjects:@"oid",@"NSNumber",@"unsignedIntegerValueForRow:",nil],
	 // geometry
     [NSArray arrayWithObjects:@"point",@"FLXGeometryPoint",@"pointValueForRow:",nil],
	 [NSArray arrayWithObjects:@"lseg",@"FLXGeometryLine",@"lineValueForRow:",nil],
	 [NSArray arrayWithObjects:@"box",@"FLXGeometryBox",@"boxValueForRow:",nil],
	 [NSArray arrayWithObjects:@"circle",@"FLXGeometryCircle",@"circleValueForRow:",nil], 
     [NSArray arrayWithObjects:@"polygon",@"FLXGeometryPolygon",@"polygonValueForRow:",nil],
     [NSArray arrayWithObjects:@"path",@"FLXGeometryPath",@"pathValueForRow:",nil],
						  
	 // network addresses
     [NSArray arrayWithObjects:@"macaddr",@"FLXMacAddr",@"macaddrValueForRow:",nil],

	 // date and time types
	 [NSArray arrayWithObjects:@"interval",@"FLXTimeInterval",@"intervalValueForRow:",nil],

	  // arrays
	 [NSArray arrayWithObjects:@"text[]",@"NSArray",@"stringArrayValueForRow:",nil],					  
     [NSArray arrayWithObjects:@"varchar[]",@"NSArray",@"stringArrayValueForRow:",nil],					  
     [NSArray arrayWithObjects:@"boolean[]",@"NSArray",@"booleanArrayValueForRow:",nil],					  
/*     [NSArray arrayWithObjects:@"bytea[]",@"NSArray",@"dataArrayValueForRow:",nil],					  
     [NSArray arrayWithObjects:@"int2[]",@"NSArray",@"int2ArrayValueForRow:",nil],					  
	 [NSArray arrayWithObjects:@"int4[]",@"NSArray",@"int4ArrayValueForRow:",nil],					  
	 [NSArray arrayWithObjects:@"int8[]",@"NSArray",@"int8ArrayValueForRow:",nil],					  
	 [NSArray arrayWithObjects:@"float4[]",@"NSArray",@"float4ArrayValueForRow:",nil],					  
     [NSArray arrayWithObjects:@"float8[]",@"NSArray",@"float8ArrayValueForRow:",nil],					  */

						  nil];

	// connect to database
	[[self connection] connect];
	 
	// iterate through the types
	for(NSUInteger i = 0; i < [theTypes count]; i++) {
		NSArray* theTypeArray = [theTypes objectAtIndex:i];
		NSString* thePostgresType = [theTypeArray objectAtIndex:0];
		Class theObjectClass = NSClassFromString([theTypeArray objectAtIndex:1]);
		SEL theValueSelector = NSSelectorFromString([theTypeArray objectAtIndex:2]);
		NSParameterAssert(theObjectClass);
		NSParameterAssert(theValueSelector);
		NSUInteger errors = 0;
		
		// delete existing table		
		if([[[self connection] tablesInSchema:theSchema] containsObject:theTable]) {
			[[self connection] executeWithFormat:@"DROP TABLE %@.%@",theSchema,theTable];
		}
		
		// create a new table
		[[self connection] executeWithFormat:@"CREATE TABLE %@.%@ (id SERIAL PRIMARY KEY,value %@)",theSchema,theTable,thePostgresType];	

		// debugging
		NSLog(@"Testing pg_type=>%@ obj_type=>%@",thePostgresType,NSStringFromClass(theObjectClass));
		
		// generate data
		NSMutableArray* theData = [[NSMutableArray alloc] initWithCapacity:numberOfRows];
		for(NSUInteger row = 0; row < numberOfRows; row++) {
			NSObject* theValue = [self performSelector:theValueSelector withObject:[NSNumber numberWithUnsignedInteger:row]];
			NSParameterAssert([theValue isKindOfClass:[NSNull class]] || [theValue isKindOfClass:theObjectClass]);
			[theData addObject:theValue];			
		}

		// prepare statement
		// we use a casting hint if the type is an array
		FLXPostgresStatement* theInsert = nil;
		if(YES) {
			//[thePostgresType hasSuffix:@"[]"]) {
			theInsert = [[self connection] prepareWithFormat:@"INSERT INTO %@.%@ (value) VALUES ($1::%@)",theSchema,theTable,thePostgresType];
		} else {
			theInsert = [[self connection] prepareWithFormat:@"INSERT INTO %@.%@ (value) VALUES ($1)",theSchema,theTable];
		}
		
		// debugging
		NSLog(@"  ...inserting %u rows",numberOfRows);
		
		// insert data into the table
		for(NSUInteger row = 0; row < numberOfRows; row++) {
			[[self connection] executePrepared:theInsert value:[theData objectAtIndex:row]];
		}
		
		// debugging
		NSLog(@"  ...retrieving %u rows",numberOfRows);
		
		// read data back from table and compare to original data
		FLXPostgresResult* theResult = [[self connection] executeWithFormat:@"SELECT value FROM %@.%@ ORDER BY id ASC",theSchema,theTable];
		NSParameterAssert([theResult affectedRows]==numberOfRows);
		for(NSUInteger row = 0; row < numberOfRows; row++) {
			NSArray* theRow = [theResult fetchRowAsArray];			
			NSParameterAssert([theRow count]==1);
			NSObject* theValue = [theData objectAtIndex:row];
			NSObject* theFetchedValue = [theRow objectAtIndex:0];
			if([theValue isKindOfClass:[theFetchedValue class]]==NO) {
				NSLog(@"  ERROR: obj_class=>%@ fetched_obj_class=>%@ (row %u)",[theValue class],[theFetchedValue class],row);
				errors++;		
				continue;
			}
			NSParameterAssert([theFetchedValue isKindOfClass:[NSNull class]] || [theFetchedValue isKindOfClass:theObjectClass]);
			if([theFetchedValue isEqual:theValue]==NO) {
				NSLog(@"  ERROR: obj_value=>%@ fetched_obj_value=>%@ (row %u)",theValue,theFetchedValue,row);
				errors++;
			}
		}
		
		// release data
		[theData release];							  
		
		// debugging
		if(errors) {
			NSLog(@"  ...%u errors",errors);			
		} else {
			NSLog(@"  ...passed");
		}
	}
	
	// disconnect from database
	[[self connection] disconnect];
}

@end
