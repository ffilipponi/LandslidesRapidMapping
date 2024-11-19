# Landslides detector
### Command line tool to perform landslides mapping from remote sensing optical multispectral imagery

The tool can be easily used through a docker container by building a dedicated image from the Dockerfile, that contains all the required free libraries and software dependencies.

The tool works from the command-line interface by running the following command:

`Landslides_detector -o /output_folder -d /data/dem.tif -c /data/PostEvent_NDWI.tif -a /data/PreEvent_NDVI.tif -b /data/PostEvent_NDVI.tif`

Additional arguments can be passed to the operator, for example:

`Landslides_detector -v -t 0.2 -p "20230428_20230523" -o /output_folder -n /data/AoI.gpkg -m /data/raster_mask.tif -l /data/Soil_sealing_mask.tif -d /data/dem.tif -c /data/PostEvent_NDWI.tif -a /data/PreEvent_NDVI.tif -b /data/PostEvent_NDVI.tif -e /data/PreEvent_cloud_mask.tif -f /data/PostEvent_cloud_mask.tif`

Complete operator help with description of single arguments can be displayed by running the command:

`Landslides_detector -h`

Input datasets required for the analysis are:
- Digital Elevation Model
- Pre-event NDVI
- Post-event NDVI
- Post-event NDWI
