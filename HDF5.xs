#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include "bieH5.h"

void getH5DataRawType(hid_t nativeType, BIE_Data_HDF5_Data * data)
{
if(nativeType == H5T_NATIVE_CHAR) {
data->type = CHAR;
}
else if(nativeType == H5T_NATIVE_SHORT) {
data->type = SHORT;
}
else if(nativeType == H5T_NATIVE_INT) {
data->type = INT;
}
else if(nativeType == H5T_NATIVE_LONG) {
data->type = LONG;
}
else if(nativeType == H5T_NATIVE_LLONG) {
data->type = LLONG;
}
else if(nativeType == H5T_NATIVE_UCHAR) {
data->type = UCHAR;
}
else if(nativeType == H5T_NATIVE_USHORT) {
data->type = USHORT;
}
else if(nativeType == H5T_NATIVE_UINT) {
data->type = UINT;
}
else if(nativeType == H5T_NATIVE_ULONG) {
data->type = ULONG;
}
else if(nativeType == H5T_NATIVE_ULLONG) {
data->type = ULLONG;
}
else {
data->type = OOPS;
}
}

MODULE = BIE::Data::HDF5            PACKAGE = BIE::Data::HDF5

BIE_Data_HDF5_Path *
H5Fcreate(const char * fileName, unsigned int flags=H5F_ACC_TRUNC, hid_t create_plist=H5P_DEFAULT, hid_t access_plist=H5P_DEFAULT)
PREINIT:
BIE_Data_HDF5_Path * path;
CODE:
path = malloc(sizeof(BIE_Data_HDF5_Path));
path->fileID = H5Fcreate(fileName, flags, create_plist, access_plist);
path->curLocID = path->fileID;  
RETVAL = path;
OUTPUT:
RETVAL

BIE_Data_HDF5_Path *
H5Fopen(const char * fileName, unsigned int flags=H5F_ACC_RDONLY, hid_t fapl_id=H5P_DEFAULT)
PREINIT:
BIE_Data_HDF5_Path * path;
CODE:
path = malloc(sizeof(BIE_Data_HDF5_Path));
path->fileID = H5Fopen(fileName, flags, fapl_id);
path->curLocID = path->fileID;
RETVAL = path;
OUTPUT:
RETVAL

int
H5Fclose(BIE_Data_HDF5_Path * path)
CODE:
RETVAL = H5Fclose(path->fileID);
OUTPUT:
RETVAL

BIE_Data_HDF5_Path *
H5Gcreate(BIE_Data_HDF5_Path * path, const char * grpName, hid_t lcpl_id=H5P_DEFAULT, hid_t gcpl_id=H5P_DEFAULT, hid_t gapl_id=H5P_DEFAULT)
CODE:
path->curLocID = H5Gcreate(path->curLocID, grpName, lcpl_id, gcpl_id, gapl_id);
RETVAL = path;
OUTPUT:
RETVAL

BIE_Data_HDF5_Path *
H5Gopen(BIE_Data_HDF5_Path * path, const char * grpName, hid_t gapl_id=H5P_DEFAULT)
CODE:
path->curLocID = H5Gopen2(path->curLocID, grpName, gapl_id);
RETVAL = path;
OUTPUT:
RETVAL

int
H5Gclose(BIE_Data_HDF5_Path * path)
CODE:
RETVAL = H5Gclose(path->curLocID);

BIE_Data_HDF5_Data *
H5Dcreate(BIE_Data_HDF5_Path * path, const char * name, hid_t dtype_id, hid_t space_id, hid_t lcpl_id=H5P_DEFAULT, hid_t dcpl_id=H5P_DEFAULT, hid_t dapl_id=H5P_DEFAULT)
PREINIT:
BIE_Data_HDF5_Data * data;
CODE:
data = malloc(sizeof(BIE_Data_HDF5_Data));
data->dataID = H5Dcreate(path->curLocID, name, dtype_id, space_id, lcpl_id, dcpl_id, dapl_id);
data->name = name;
data->path = path;
RETVAL = data;
OUTPUT:
RETVAL

BIE_Data_HDF5_Data *
H5Dopen(BIE_Data_HDF5_Path * path, const char * name, hid_t dapl_id=H5P_DEFAULT)
PREINIT:
BIE_Data_HDF5_Data * data;
CODE:
data = malloc(sizeof(BIE_Data_HDF5_Data));
data->dataID = H5Dopen(path->curLocID, name, dapl_id);
data->name = name;
data->path = path;
data->typeID = H5Dget_type(data->dataID);
data->spaceID = H5Dget_space(data->dataID);
data->count = H5Sget_simple_extent_npoints(data->spaceID);
data->size = data->count * H5Tget_size(data->typeID);
RETVAL = data;
OUTPUT:
RETVAL

int
H5Dclose(BIE_Data_HDF5_Data * data)
CODE:
RETVAL = H5Dclose(data->dataID);
OUTPUT:
RETVAL

hid_t
H5Dget_type(BIE_Data_HDF5_Data * data)
CODE:
data->typeID = H5Dget_type(data->dataID);
RETVAL = data->typeID;
OUTPUT:
RETVAL

hid_t
H5Dget_space(BIE_Data_HDF5_Data * data)
CODE:
data->spaceID = H5Dget_space(data->dataID);
RETVAL = data->spaceID;
OUTPUT:
RETVAL

int
H5Dget_size(BIE_Data_HDF5_Data * data)
PREINIT:
hssize_t eleCnt;
size_t typeSize;
int size = 0;
CODE:
if (data->spaceID && data->typeID) {
eleCnt = H5Sget_simple_extent_npoints(data->spaceID);
typeSize = H5Tget_size(data->typeID);
size = eleCnt * typeSize;
}
RETVAL = size;
OUTPUT:
RETVAL

BIE_Data_HDF5_Data *
H5Dread(BIE_Data_HDF5_Data * data, hid_t mem_space_id = H5S_ALL, hid_t file_space_id = H5S_ALL, hid_t xfer_plist_id = H5P_DEFAULT)
PREINIT:
hid_t mem_type_id;
CODE:
data->buf = malloc(data->size);
mem_type_id = H5Tget_native_type(data->typeID, H5T_DIR_ASCEND);
getH5DataRawType(mem_type_id, data);
H5Dread(data->dataID, mem_type_id, mem_space_id, file_space_id, xfer_plist_id, data->buf);
RETVAL = data;
H5Tclose(mem_type_id);
OUTPUT:
RETVAL

SV *
H5Dprint(BIE_Data_HDF5_Data * data)
CODE:
RETVAL = newSVpvn(data->buf, data->size);
OUTPUT:
RETVAL



MODULE = BIE::Data::HDF5            PACKAGE = BIE::Data::HDF5::PathPtr
void
DESTROY(BIE_Data_HDF5_Path * path)
CODE:
free(path);

MODULE = BIE::Data::HDF5            PACKAGE = BIE::Data::HDF5::DataPtr
void
DESTROY(BIE_Data_HDF5_Data * data)
CODE:
H5Tclose(data->typeID);
H5Sclose(data->spaceID);
H5Dclose(data->dataID);
free(data->buf);



