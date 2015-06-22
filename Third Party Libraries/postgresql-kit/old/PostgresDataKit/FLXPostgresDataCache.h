
#import <Foundation/Foundation.h>

@interface FLXPostgresDataCache : NSObject {
	FLXPostgresConnection* connection;	
	NSMutableDictionary* context;
	NSString* schema;
}

@property (retain) FLXPostgresConnection* connection;
@property (retain) NSMutableDictionary* context;
@property (retain) NSString* schema;

+(FLXPostgresDataCache* )sharedCache;

-(id)newObjectForClass:(Class)theClass;
//-(id)fetchObjectForClass:(Class)theClass primaryKeyValue:(id)theValue;
-(BOOL)saveObject:(FLXPostgresDataObject* )theObject;

@end

@interface NSObject (FLXPostgresDataCacheDelegate)
-(void)dataCache:(FLXPostgresDataCache* )theCache error:(NSError* )theError;
@end
