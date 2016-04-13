# distutils: language = c++
# cython: profile=True
"""Raster fill."""

import numpy as np
cimport numpy as np

from rasterio import dtypes
from rasterio._err import CPLErrors
from rasterio cimport _gdal, _io

from rasterio._io cimport InMemoryRaster


def _fillnodata(image, mask, double max_search_distance=100.0,
                int smoothing_iterations=0):
    cdef void *memdriver = _gdal.GDALGetDriverByName("MEM")
    cdef void *image_dataset = NULL
    cdef void *image_band = NULL
    cdef void *mask_dataset = NULL
    cdef void *mask_band = NULL
    cdef _io.RasterReader rdr
    cdef _io.RasterReader mrdr
    cdef char **alg_options = NULL

    if dtypes.is_ndarray(image):
        # copy numpy ndarray into an in-memory dataset.
        image_dataset = _gdal.GDALCreate(
            memdriver,
            "image",
            image.shape[1],
            image.shape[0],
            1,
            <_gdal.GDALDataType>dtypes.dtype_rev[image.dtype.name],
            NULL)
        image_band = _gdal.GDALGetRasterBand(image_dataset, 1)
        _io.io_auto(image, image_band, True)
    else:
        raise ValueError("Invalid source image")

    if dtypes.is_ndarray(mask):
        mask_cast = mask.astype('uint8')
        mask_dataset = _gdal.GDALCreate(
            memdriver,
            "mask",
            mask.shape[1],
            mask.shape[0],
            1,
            <_gdal.GDALDataType>dtypes.dtype_rev['uint8'],
            NULL)
        mask_band = _gdal.GDALGetRasterBand(mask_dataset, 1)
        _io.io_auto(mask_cast, mask_band, True)
    elif isinstance(mask, tuple):
        if mask.shape != image.shape:
            raise ValueError("Mask must have same shape as image")
        mrdr = mask.ds
        mask_band = mrdr.band(mask.bidx)
    elif mask is None:
        mask_band = NULL
    else:
        raise ValueError("Invalid source image mask")

    try:
        with CPLErrors() as cple:
            alg_options = _gdal.CSLSetNameValue(
                alg_options, "TEMP_FILE_DRIVER", "MEM")
            _gdal.GDALFillNodata(
                image_band, mask_band, max_search_distance, 0,
                    smoothing_iterations, alg_options, NULL, NULL)
            cple.check()
        # read the result into a numpy ndarray
        result = np.empty(image.shape, dtype=image.dtype)
        _io.io_auto(result, image_band, False)
    finally:
        if image_dataset != NULL:
            _gdal.GDALClose(image_dataset)
        if mask_dataset != NULL:
            _gdal.GDALClose(mask_dataset)
        _gdal.CSLDestroy(alg_options)

    return result
