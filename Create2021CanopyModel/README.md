## 2021 Worcester Canopy Cover Map Creation

### 1. Pull MA 2021 Lidar tiles

Hosted at https://www.mass.gov/info-details/massgis-data-lidar-terrain-data

See getLidarTiles.ipynb

### 2. Process lidar with LASTools in ArcGIS Pro
For each step I suggest adding an appendix ("_grd", "_hgt", "_cnpy") to distinguish each new iteration of the data

**i. Batch lassplit**

Each lidar tile is too large to be processed, so they first must be split using lassplit.
	Run Batch lassplit on the original 65 tiles 
	This creatses 568 tiles. Which is too many to be fed into a batch process for subsequent geoprocessing tools.
	I don't know exactly what the limit is here, but I split the 568 tiles into goups of 223, 200, and 145, which worked in batch processing

**ii. Batch lasground**

An indication that this step has worked is that a tile, when brought into contents in ArcPRO, will have a 'Data percentage' measure.
	The tiles created by lassplit are very strange shapes, and each bbox runs to min and max.
	This step gives every pixel a ground (0) or non-ground (1) classificatoin, though this is not apparent in any arcgis visualization

**iii. Batch lasheight**

Check the box to replace the z coordinate with the height (as opposed to the elevation).
	Output format remains .las

**iv. Batch lascanopy**

The ouput here is a .tif file for every lassplit tile. 

**v. Mosaic .tifs**

You'll end up with a .tif for average, max, and coverage.
	Which is to say a map where each pixel represents:
 
- The average height of returns within that square meter
 
- The max height of returns within that square meter
 
- What percentage of returns within that square meter are non-ground (essentially a measure of canopy density)

canopy_avg.tif:
![image](https://github.com/andrews-j/UrbanForestry/assets/26927475/34d7a6dd-f162-4fd4-acdf-046d2d6d6e66)

canopy_avg.tif detail:

![image](https://github.com/andrews-j/UrbanForestry/assets/26927475/41417ed4-2341-4a7e-97db-ccdca2d11f59)

### 3. Filter roof pixels
The lidar produced maps we have at this point give us hi-res information about non-ground objects, but this includes roofs. 
Our goal is a single layer, boolean map that includes only trees, ie canopy. 
Since we've already filtered non-ground, we can now filter out roofs with an NDVI mask.
We'll use NAIP (EarthDefine) data for this, which is 4 bands at .6 meter resolution. 
Note: there is a worcester buildings layer, but it seems to be slightly off kilter in relation to the lider data, I think there would be lots of slivers of buildings left behind


**i. Get NAIP imagery**

  Source: https://coast.noaa.gov/dataviewer/#/imagery/search/where:ID=9591
  
It will download by tile the area that you draw. Mosaic these, then clip to worcester city boundary. 

2021 NAIP imagery for Worcester detail:
  
![image](https://github.com/andrews-j/UrbanForestry/assets/26927475/a3944ebb-7446-4e06-94c4-64ce259a170d)


**ii. Create NDVI map from NAIP imagery**

60 cm resolution gives us a highly detailed map

![image](https://github.com/andrews-j/UrbanForestry/assets/26927475/dda52524-ce9d-4c98-bf46-203b40647c4d)


**iii. Choose NDVI threshold to create NDVI Mask**

The logic here is that we need to create a mask that will exclude roofs, to combine with the lidar derived map that excludes ground points (such as fields) With these two we can run a boolean raster operation to extract just high NDVI that is not ground, ie trees:

The NDVI image ranges in  value from 1 to 256. I tried several different thresholds, but settled on 100, which is just high enough to not include white roofs, but includes even trees with yellowed leaves, a common feature of this NAIP imager (perhaps it was taken in the fall).

The biggest problem with the NAIP imagery is that appears to have been taken late in the day, and shadows cover certain areas, particularly in forests. This leads to some portion of error by ommission, because these register as low NDVI. 

This is a detail from the NAIP imagery of the Clark University Hadwen Arboretum, notice patches of shade in the canopy.

![image](https://github.com/andrews-j/UrbanForestry/assets/26927475/aba87a0a-8915-45c4-948b-17dd7fad009c)

Here is how the above imagery translates to NDVI. Notices low NDVI coincident with areas of shade:

![image](https://github.com/andrews-j/UrbanForestry/assets/26927475/b215b0e9-0460-4a67-934d-1167e7115edd)

And this is what a high resolution image of the same area looks like taken at peak foliage during the middle of the day:

![image](https://github.com/andrews-j/UrbanForestry/assets/26927475/4dfa4f18-3859-4fef-9eaf-93084113d8b9)


**iv. Create canopy mask raster**

This is another boolean image, that we will create from one of the lidar derived images. 

I used the average height image, and took all pixels that are not ground: avg_bool =  "canopy_average" > .01

**v. Use both masks to get only canopy**

Now we have a boolean image where 1= non-ground, and another where 1 == greenery. Putting these together will leave us with only tree canopies and should exclude the usual suspects: grass and roofs. 

This is the boolean operation to accomplish this:

("avg_bool" == 1) & ("ndvi_bool" ==1)

Here is a detail of the result on ESRI basemap imagery:

![image](https://github.com/andrews-j/UrbanForestry/assets/26927475/789710b3-d969-4b2b-8996-26bdda69b40c)


