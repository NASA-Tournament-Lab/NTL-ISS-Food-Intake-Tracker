
#import "PostgresDataKit.h"
#import "PostgresDataKitPrivate.h"

static FLXPostgresDataCache* FLXSharedCache = nil;
static NSString* FLXPostgresDataCacheDomain = @"FLXPostgresDataCache";

////////////////////////////////////////////////////////////////////////////////

@implementation FLXPostgresDataCache

@synthesize connection;
@synthesize context;
@synthesize schema;

////////////////////////////////////////////////////////////////////////////////
// singleton design pattern
// see http://www.cocoadev.com/index.pl?SingletonDesignPattern

+(FLXPostgresDataCache* )sharedCache {
	@synchronized(self) {
		if (FLXSharedCache == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	return FLXSharedCache;
}

+(id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (FLXSharedCache == nil) {
			FLXSharedCache = [super allocWithZone:zone];
			return FLXSharedCache;  // assignment and return on first allocation
		}
	}
	return nil; //on subsequent allocation attempts return nil
}

-(id)copyWithZone:(NSZone *)zone {
	return self;
}

-(id)retain {
	return self;
}

-(unsigned)retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

-(void)release {
	// do nothing
}

-(id)autorelease {
	return self;
}

////////////////////////////////////////////////////////////////////////////////
// constructor and destructor

-(id)init {
	self = [super init];
	if(self) {
		[self setContext:[[NSMutableDictionary alloc] init]];
		[self setSchema:@"public"];
	}
	return self;
}

-(void)dealloc {
	[self setConnection:nil];
	[self setContext:nil];
	[self setSchema:nil];
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
// private methods

+(BOOL)_isValidIdentifier:(NSString* )theName {
	NSCharacterSet* illegalCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"] invertedSet];
	if([theName length]==0) return NO;
	NSRange theRange = [theName rangeOfCharacterFromSet:illegalCharacterSet];
	return (theRange.location==NSNotFound) ? YES : NO;
}

-(NSArray* )_columnsFromDatabaseForTableName:(NSString* )theTableName {
	NSParameterAssert(theTableName);
	if([self connection]==nil) return nil;
	NSArray* theColumns = [[self connection] columnNamesForTable:theTableName inSchema:[self schema]];
	NSParameterAssert(theColumns);
	return theColumns;	
}

-(NSString* )_primaryKeyFromDatabaseForTableName:(NSString* )theTableName {
	NSParameterAssert(theTableName);
	if([self connection]==nil) return nil;
	NSString* theKey = [[self connection] primaryKeyForTable:theTableName inSchema:[self schema]];
	return theKey;	
}

////////////////////////////////////////////////////////////////////////////////
// register setter and getter properties for a class

-(BOOL)_registerPropertyImplementationForContext:(FLXPostgresDataObjectContext* )theContext property:(objc_property_t)theProperty {	
	NSParameterAssert(theContext);

	const char* propertyName = property_getName(theProperty);
	const char* propertyAttributes = property_getAttributes(theProperty);

	NSParameterAssert(propertyName);
	NSParameterAssert(propertyAttributes);
	NSParameterAssert(strlen(propertyAttributes) >= 2);	
	NSParameterAssert(propertyAttributes[0]=='T');
	
	// return if property is not the same as a column name
	if([[theContext tableColumns] containsObject:[NSString stringWithUTF8String:propertyName]]==NO) {
		return NO;
	}
	
	// ensure property is dynamic
	if([[NSString stringWithUTF8String:propertyAttributes]hasSuffix:@",D"] == NO) {
		return NO;
	}

	return YES;
}

-(void)_registerPropertyImplementationForContext:(FLXPostgresDataObjectContext* )theContext {
	NSParameterAssert(theContext);
	Class theClass = NSClassFromString([theContext className]);
	NSParameterAssert(theClass);
	// get properties from the object
	unsigned int numProperties;	
	objc_property_t* properties = class_copyPropertyList(theClass,&numProperties);
	for(unsigned int i = 0; i < numProperties; i++) {
		BOOL isRegistered = [self _registerPropertyImplementationForContext:theContext property:properties[i]];
		if(isRegistered==NO) {
			const char* propertyName = property_getName(properties[i]);
			NSLog(@"Unable to create implementation for dynamic property '%s', class '%@'",propertyName,[theContext className]);
		}
	}
    free(properties);	
}

////////////////////////////////////////////////////////////////////////////////
// get object context for class

-(FLXPostgresDataObjectContext* )objectContextForClass:(Class)theClass {
	// turn class into a string
	NSString* theClassString = NSStringFromClass(theClass);
	if(theClassString==nil) {
		[NSException raise:FLXPostgresDataCacheDomain format:@"objectContextForClass: Invalid class"];
		return nil;
	}
	// fetch context from cache
	FLXPostgresDataObjectContext* theContext = [[self context] objectForKey:theClassString];
	if(theContext) {
		return theContext;
	}
	// check class has superclass of FLXPostgresDataObject
	Class superClass = theClass;
	do {
		superClass = class_getSuperclass(superClass);
	} while(superClass != nil && superClass != [FLXPostgresDataObject class]);
	if(superClass==nil) {
		[NSException raise:FLXPostgresDataCacheDomain format:@"objectContextForClass: Does not inherit FLXPostgresDataObject superclass"];
		return nil;
	}
	// get table name
	NSString* theTableName = [theClass tableName];
	if(theTableName==nil) {
		[NSException raise:FLXPostgresDataCacheDomain format:@"objectContextForClass: Invalid table name"];
		return nil;
	}
	if([FLXPostgresDataCache _isValidIdentifier:theTableName]==NO) {
		[NSException raise:FLXPostgresDataCacheDomain format:@"objectContextForClass: Invalid table name: '%@'" arguments:theTableName];
		return nil;
	}
	// get table columns from class
	NSArray* theTableColumns = [theClass tableColumns];
	if(theTableColumns==nil) {		
		// get table columns from the database		
		theTableColumns = [self _columnsFromDatabaseForTableName:theTableName];
	}
	if([theTableColumns isKindOfClass:[NSArray class]]==NO || [theTableColumns count]==0) {
		[NSException raise:FLXPostgresDataCacheDomain format:@"objectContextForClass: Invalid table columns"];
		return nil;
	}
	for(NSObject* theColumn in theTableColumns) {
		if([theColumn isKindOfClass:[NSString class]]==NO) {
			[NSException raise:FLXPostgresDataCacheDomain format:@"objectContextForClass: Invalid table column"];
			return nil;
		}
		if([FLXPostgresDataCache _isValidIdentifier:((NSString* )theColumn)]==NO) {
			[NSException raise:FLXPostgresDataCacheDomain format:@"objectContextForClass: Invalid table column '%@'" arguments:theColumn];
			return nil;
		}				
	}
	// get primary key
	NSString* thePrimaryKey = [theClass primaryKey] ? [theClass primaryKey] : [self _primaryKeyFromDatabaseForTableName:theTableName];
	if(thePrimaryKey==nil) {
		[NSException raise:FLXPostgresDataCacheDomain format:@"objectContextForClass: Invalid primary key"];
		return nil;
	}
	if([FLXPostgresDataCache _isValidIdentifier:((NSString* )thePrimaryKey)]==NO) {
		[NSException raise:FLXPostgresDataCacheDomain format:@"objectContextForClass: Invalid primary key '%@'" arguments:thePrimaryKey];
		return nil;
	}
	// get object type
	FLXPostgresDataObjectType theObjectType = [theClass objectType];
	// get serial column
	NSString* theSerialKey = nil;
	if(theObjectType | FLXPostgresDataObjectSerial) {
		theSerialKey = [theClass serialKey];
	}
	// create an object
	theContext = [[[FLXPostgresDataObjectContext alloc] init] autorelease];
	[theContext setClassName:theClassString];
	[theContext setTableName:theTableName];
	[theContext setSchema:[self schema]];
	[theContext setPrimaryKey:thePrimaryKey];
	[theContext setSerialKey:theSerialKey];
	[theContext setType:theObjectType];
	[theContext setTableColumns:theTableColumns];
	// register the properties
	[self _registerPropertyImplementationForContext:theContext];
	// place object in cache
	[[self context] setObject:theContext forKey:theClassString];	
	// return the cbject
	return theContext;
}

////////////////////////////////////////////////////////////////////////////////
// create a new object

-(id)newObjectForClass:(Class)theClass {
	id theObject = [[theClass alloc] initWithContext:[self objectContextForClass:theClass]];
	if(theObject==nil || [theObject isKindOfClass:[FLXPostgresDataObject class]]==NO) {
		[theObject release];
		return nil;
	}

	// observe the key/value updating on the object for each property
	NSArray* theKeyPaths = [[(FLXPostgresDataObject* )theObject context] tableColumns];
	for(NSString* theKeyPath in theKeyPaths) {
		[theObject addObserver:self forKeyPath:theKeyPath options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	}
	
	// call awakeFromInsert
	[theObject awakeFromInsert];
	
	return [theObject autorelease];
}

////////////////////////////////////////////////////////////////////////////////
// observe object changes

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSLog(@"object = %@ key = %@ change = %@",object,keyPath,change);
}

////////////////////////////////////////////////////////////////////////////////
// commit changes to object - can throw an exception

-(BOOL)saveObject:(FLXPostgresDataObject* )theObject full:(BOOL)isFullCommit {
	NSParameterAssert(theObject);
/*
	FLXPostgresDataObjectContext* theContext = [theObject context];
	NSParameterAssert(theContext);
	NSArray* columnNames = isFullCommit ? [theContext tableColumns] : [theObject _modifiedTableColumns];
	NSParameterAssert(columnNames);
	if([columnNames count]==0) {
		// nothing to save!
		return YES;
	}
	// construct name, value arrays
	NSMutableArray* columnValues = [NSMutableArray arrayWithCapacity:[columnNames count]];
	for(NSString* theKey in columnNames) {
		NSObject* theValue = [theObject valueForKey:theKey];
		NSParameterAssert(theValue);
		[columnValues addObject:theValue];
	}
 */
	// save object
	if([theObject _isNewObject]) {
		NSObject* thePrimaryValue = [[self connection] insertRowForObject:theObject];
		NSParameterAssert(thePrimaryValue);
		// set the primary value
		[theObject setValue:thePrimaryValue forKey:[theContext primaryKey]];
	} else {
		[[self connection] updateRowForObject:theObject];
	}
	// commit modified information
	[theObject _commit];
	// return success
	return YES;
}

-(BOOL)saveObject:(FLXPostgresDataObject* )theObject {
	return [self saveObject:theObject full:NO];
}

@end




////////////////////////////////////////////////////////////////////////////////
/*
 void dynamicPropertySetter_obj(FLXPostgresDataObject* self, SEL _cmd,id object) {	
 NSLog(@"dynamic set %@ %@ => %@",self,NSStringFromSelector(_cmd),object);
 }
 
 id dynamicPropertyGetter_obj(FLXPostgresDataObject* self, SEL _cmd) {
 return [self valueForKey:NSStringFromSelector(_cmd)];
 }
 
 void dynamicPropertySetter_char(FLXPostgresDataObject* self, SEL _cmd,char value) {
 
 }
 
 char dynamicPropertyGetter_char(FLXPostgresDataObject* self, SEL _cmd) {
 
 }
 
 void dynamicPropertySetter_int(FLXPostgresDataObject* self, SEL _cmd,int value) {
 
 }
 
 int dynamicPropertyGetter_int(FLXPostgresDataObject* self, SEL _cmd) {
 
 }
 
 void dynamicPropertySetter_short(FLXPostgresDataObject* self, SEL _cmd,short value) {
 
 }
 
 short dynamicPropertyGetter_short(FLXPostgresDataObject* self, SEL _cmd) {
 
 }
 
 void dynamicPropertySetter_long(FLXPostgresDataObject* self, SEL _cmd,long value) {
 
 }
 
 long dynamicPropertyGetter_long(id self, SEL _cmd) {
 
 }
 
 void dynamicPropertySetter_longlong(id self, SEL _cmd,long long value) {
 
 }
 
 long long dynamicPropertyGetter_longlong(id self, SEL _cmd) {
 
 }
 
 void dynamicPropertySetter_unsignedchar(id self, SEL _cmd,unsigned char value) {
 
 }
 
 unsigned char dynamicPropertyGetter_unsignedchar(id self, SEL _cmd) {
 
 }
 
 void dynamicPropertySetter_unsignedint(id self, SEL _cmd,unsigned int value) {
 
 }
 
 unsigned int dynamicPropertyGetter_unsignedint(id self, SEL _cmd) {
 
 }
 
 void dynamicPropertySetter_unsignedshort(id self, SEL _cmd,unsigned short value) {
 
 }
 
 unsigned short dynamicPropertyGetter_unsignedshort(id self, SEL _cmd) {
 
 }
 
 void dynamicPropertySetter_unsignedlong(id self, SEL _cmd,unsigned long value) {
 
 }
 
 unsigned long dynamicPropertyGetter_unsignedlong(id self, SEL _cmd) {
 
 }
 
 void dynamicPropertySetter_unsignedlonglong(id self, SEL _cmd,unsigned long long value) {
 
 }
 
 unsigned long long dynamicPropertyGetter_unsignedlonglong(id self, SEL _cmd) {
 
 }
 
 void dynamicPropertySetter_float(id self, SEL _cmd,float value) {
 
 }
 
 float dynamicPropertyGetter_float(id self, SEL _cmd) {
 
 }
 
 void dynamicPropertySetter_double(id self, SEL _cmd,double value)  {
 
 }
 
 double dynamicPropertyGetter_double(id self, SEL _cmd) {
 
 }
 */
/*
+(NSString* )_camelCaseForIdentifier:(NSString* )theName {
	NSParameterAssert(theName && [theName length] > 0);
	if([theName length]==1) {
		return [theName uppercaseString];
	}
	NSString* firstChar = [[theName substringToIndex:1] uppercaseString];
	NSString* restOfChars = [theName substringFromIndex:1];
	return [NSString stringWithFormat:@"%@%@",firstChar,restOfChars];
}
 
 */
/*
 switch(propertyAttributes[1]) {
 case '@':
 setterImplementation = (IMP)dynamicPropertySetter_obj;
 getterImplementation = (IMP)dynamicPropertyGetter_obj;
 isValid = YES;
 break;
 case 'c':
 setterImplementation = (IMP)dynamicPropertySetter_char;
 getterImplementation = (IMP)dynamicPropertyGetter_char;			
 isValid = YES;
 break;
 case 'i':
 setterImplementation = (IMP)dynamicPropertySetter_int;
 getterImplementation = (IMP)dynamicPropertyGetter_int;			
 isValid = YES;
 break;
 case 's':
 setterImplementation = (IMP)dynamicPropertySetter_short;
 getterImplementation = (IMP)dynamicPropertyGetter_short;			
 isValid = YES;
 break;
 case 'l':
 setterImplementation = (IMP)dynamicPropertySetter_long;
 getterImplementation = (IMP)dynamicPropertyGetter_long;			
 isValid = YES;
 break;
 case 'q':
 setterImplementation = (IMP)dynamicPropertySetter_longlong;
 getterImplementation = (IMP)dynamicPropertyGetter_longlong;			
 isValid = YES;
 break;
 case 'C':
 setterImplementation = (IMP)dynamicPropertySetter_unsignedchar;
 getterImplementation = (IMP)dynamicPropertyGetter_unsignedchar;			
 isValid = YES;
 break;
 case 'I':
 setterImplementation = (IMP)dynamicPropertySetter_unsignedint;
 getterImplementation = (IMP)dynamicPropertyGetter_unsignedint;			
 isValid = YES;
 break;
 case 'S':
 setterImplementation = (IMP)dynamicPropertySetter_unsignedshort;
 getterImplementation = (IMP)dynamicPropertyGetter_unsignedshort;			
 isValid = YES;
 break;
 case 'L':
 setterImplementation = (IMP)dynamicPropertySetter_unsignedlong;
 getterImplementation = (IMP)dynamicPropertyGetter_unsignedlong;			
 isValid = YES;
 break;
 case 'Q':
 setterImplementation = (IMP)dynamicPropertySetter_unsignedlonglong;
 getterImplementation = (IMP)dynamicPropertyGetter_unsignedlonglong;			
 isValid = YES;
 break;
 case 'f':
 setterImplementation = (IMP)dynamicPropertySetter_float;
 getterImplementation = (IMP)dynamicPropertyGetter_float;			
 isValid = YES;
 break;
 case 'd':
 setterImplementation = (IMP)dynamicPropertySetter_double;
 getterImplementation = (IMP)dynamicPropertyGetter_double;			
 isValid = YES;
 break;
 default:
 break;
 }
 
 if(isValid==NO) {
 return NO;
 }
 
 // determine setter & getter names
 SEL theSetter;
 SEL theGetter = NSSelectorFromString([NSString stringWithFormat:@"%s",propertyName]);	
 if(strlen(propertyName)==1) {
 theSetter = NSSelectorFromString([NSString stringWithFormat:@"set%c:",toupper(propertyName[0])]);
 } else {
 theSetter = NSSelectorFromString([NSString stringWithFormat:@"set%c%s:",toupper(propertyName[0]),propertyName+1]);
 }			
 
 // add these methods to the class
 if(class_addMethod(theClass,theSetter,setterImplementation,[setterEncoding UTF8String])==NO) {
 return NO;
 }
 if(class_addMethod(theClass,theGetter,getterImplementation,[getterEncoding UTF8String])==NO) {
 return NO;
 }			
 */
/*
 // determine setter and getter implementations
 IMP setterImplementation;
 IMP getterImplementation;
 NSString* setterEncoding = [NSString stringWithFormat:@"v@:%c",propertyAttributes[1]];
 NSString* getterEncoding = [NSString stringWithFormat:@"%@@:",propertyAttributes[1]];
 BOOL isValid = NO;
 */
