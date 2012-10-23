#include <hdf5.h>
#include <hdf5_hl.h>

typedef struct {
  hid_t fileID;
  hid_t curLocID; //file or group identifier
} BIE_Data_HDF5_Path;

typedef enum {
  CHAR,
  SHORT,
  INT,
  LONG,
  LLONG,
  UCHAR,
  USHORT,
  UINT,
  ULONG,
  ULLONG,
  FLOAT,
  DOUBLE,
  LDOUBLE,
  OOPS,
} dataType;

typedef struct {
  hid_t dataID;
  const char * name;
  BIE_Data_HDF5_Path * path;
  hid_t typeID;
  hid_t spaceID;
  int size;
  int count;
  dataType type;
  void * buf;
} BIE_Data_HDF5_Data;



