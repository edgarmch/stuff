import numpy
from osgeo import gdal        

raster1 = r'/home/edgarmch/maunt/test/gdal-hdf_to_tiff/4/out.tif'
raster2 = r'/home/edgarmch/maunt/test/gdal-hdf_to_tiff/2/out.tif'

ds1 = gdal.Open(raster1)
ds2 = gdal.Open(raster2)

r1 = numpy.array(ds1.ReadAsArray())
r2 = numpy.array(ds2.ReadAsArray())

d = numpy.array_equal(r1,r2)

if d == False:
    print "Son diferentes"

else:
    print "Son el mismo"
