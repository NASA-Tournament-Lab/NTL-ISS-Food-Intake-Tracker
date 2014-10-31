
typedef struct {
	NSUInteger oid;
	id (*bin2obj)(NSUInteger oid,const void* bytes,NSUInteger size,NSStringEncoding encoding);
	id (*text2obj)(NSUInteger oid,const void* bytes,NSUInteger size,NSStringEncoding encoding);
	const char* name;
} PGResultConverterType;

typedef struct {
	const char* classname;
	const void* (*obj2bin)(id obj,NSUInteger* type,NSUInteger* size,BOOL* freeWhenDone,NSStringEncoding encoding);
	const void* (*obj2text)(id obj,NSUInteger* type,NSUInteger* size,BOOL* freeWhenDone,NSStringEncoding encoding);
} PGObjectConverterType;

////////////////////////////////////////////////////////////////////////////////
// see postgresql source code for OID definitions
// include/catalog/pg_type.h
// http://doxygen.postgresql.org/include_2catalog_2pg__type_8h.html

enum {
	PGOidTypeBool = 16,
	PGOidTypeData = 17,
	PGOidTypeName = 19,
	PGOidTypeInt8 = 20,
	PGOidTypeInt2 = 21,
	PGOidTypeInt4 = 23,
	PGOidTypeText = 25,
	PGOidTypeOid = 26,
	PGOidTypeXML = 142,
	PGOidTypePoint = 600,
	PGOidTypeLSeg = 601,
	PGOidTypePath = 602,
	PGOidTypeBox = 603,
	PGOidTypePolygon = 604,
	PGOidTypeFloat4 = 700,
	PGOidTypeFloat8 = 701,
	PGOidTypeAbsTime = 702,
	PGOidTypeUnknown = 705,
	PGOidTypeCircle = 718,
	PGOidTypeMoney = 790,
	PGOidTypeMacAddr = 829,
	PGOidTypeIPAddr = 869,
	PGOidTypeNetAddr = 869,
	PGOidTypeArrayBool = 1000,
	PGOidTypeArrayData = 1001,
	PGOidTypeArrayChar = 1002,
	PGOidTypeArrayName = 1003,
	PGOidTypeArrayInt2 = 1005,
	PGOidTypeArrayInt4 = 1007,
	PGOidTypeArrayText = 1009,
	PGOidTypeArrayVarchar = 1015,
	PGOidTypeArrayInt8 = 1016,
	PGOidTypeArrayFloat4 = 1021,
	PGOidTypeArrayFloat8 = 1022,
	PGOidTypeArrayMacAddr = 1040,
	PGOidTypeArrayIPAddr = 1041,
	PGOidTypeChar = 1042,
	PGOidTypeVarchar = 1043,
	PGOidTypeDate = 1082,
	PGOidTypeTime = 1083,
	PGOidTypeTimestamp = 1114,
	PGOidTypeTimestampTZ = 1184,
	PGOidTypeInterval = 1186,
	PGOidTypeTimeTZ = 1266,
	PGOidTypeBit = 1560,
	PGOidTypeVarbit = 1562,
	PGOidTypeNumeric = 1700,
	PGOidTypeMax = 1700
};
