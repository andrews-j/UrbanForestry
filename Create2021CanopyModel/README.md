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

![image](https://github.com/andrews-j/WorcesterUrbanForest/assets/26927475/2f6c64af-981e-48dd-b48a-93ef540ffd0a)

canopy_avg.tif detail:

![image](https://github.com/andrews-j/WorcesterUrbanForest/assets/26927475/392559ba-fa56-44a8-a7d7-e4536bb77713)


### 3. Filter roof pixels
The lidar produced maps we have at this point give us hi-res information about non-ground objects, but this includes roofs. 
Our goal is a single layer, boolean map that includes only trees, ie canopy. 
Since we've already filtered non-ground, we can now filter out roofs with an NDVI mask.
We'll use NAIP (EarthDefine) data for this, which is 4 bands at .6 meter resolution. 
Note: there is a worcester buildings layer, but it seems to be slightly off kilter in relation to the lider data, I think there would be lots of slivers of buildings left behind

**i. Get NAIP imagery**

  Source: https://coast.noaa.gov/dataviewer/#/imagery/search/where:ID=9591
  
It will download by tile the area that you draw. Mosaic these, then clip to worcester city boundary. 

2021 NAIP imagery for Worcester:
  
![image](https://github.com/andrews-j/WorcesterUrbanForest/assets/26927475/2c112821-a0e0-45d3-a2a8-1fd9e89b3903)


**ii. Create NDVI map from NAIP imagery**

60 cm resolution gives us a highly detailed map

![image](https://github.com/andrews-j/WorcesterUrbanForest/assets/26927475/a49e4a59-7a62-4361-9b78-944600f4ef0b)


**iii. Choose NDVI threshold to create NDVI Mask**

The logic here is that we need to create a mask that will exclude roofs, to combine with the lidar derived map that excludes ground points (such as fields) With these two we can run a boolean raster operation to extract just high NDVI that is not ground, ie trees:

The NDVI image ranges in  value from 1 to 256. I tried several different thresholds, but settled on 100, which is just high enough to not include white roofs, but includes even trees with yellowed leaves, a common feature of this NAIP imager (perhaps it was taken in the fall).

The biggest problem with the NAIP imagery is that appears to have been taken late in the day, and shadows cover certain areas, particularly in forests. This leads to some portion of error by ommission, because these register as low NDVI. 

This is a detail from the NAIP imagery of the Clark University Hadwen Arboretum, notice patches of shade in the canopy.

![NAIP_Shadow](https://github.com/andrews-j/WorcesterUrbanForest/assets/26927475/b5d4c961-5fe3-42a2-8a0d-9e985b8c76ac)

Here is how the above imagery translates to NDVI. Notices low NDVI coincident with areas of shade:

![NDVI_Shadow](https://github.com/andrews-j/WorcesterUrbanForest/assets/26927475/a7f0fdc0-88d2-4f3f-8a29-a0cd463a7466)

And this is what a high resolution image of the same area looks like taken at peak foliage during the middle of the day:

![ESRI_basemap_shadowComparison](https://github.com/andrews-j/WorcesterUrbanForest/assets/26927475/310dfe72-7eb2-4dbe-81d9-71283629d93f)


**iv. Create canopy mask raster**

This is another boolean image, that we will create from one of the lidar derived images. 

I used the average height image, and took all pixels that are not ground: avg_bool =  "canopy_average" > .01

**v. Use both masks to get only canopy**

Now we have a boolean image where 1= non-ground, and another where 1 == greenery. Putting these together will leave us with only tree canopies and should exclude the usual suspects: grass and roofs. 

This is the boolean operation to accomplish this:

("avg_bool" == 1) & ("ndvi_bool" ==1)

Here is a detail of the result on ESRI basemap imagery:

![detail](https://github.com/andrews-j/WorcesterUrbanForest/assets/26927475/e39799a1-14bf-4150-8cd7-618eefc76fa2)

