## Merging Summer '23 and Fall '23 HERO Surveys

In the summer of 2023 HERO fellows collected data on trees planted by the Massachusetts Department of Conservation and Recreation (MA DCR) in four neighborhoods of Worcester, Massachusetts in the aftermath of the [Longhorned Beetle removals](https://storymaps.arcgis.com/collections/e071fd383e7f4022a242ef4c87b16e44?item=6).
This data came to reside in "LBSurvey23FINAL.csv". I perfomed preliminary cleaning on dataset this resulting in "S23_work.csv"

In the Fall of 2023 a smaller HERO survey team, led by myself, collected data on a random sample of trees from the same DCR planting program, but planted beyond the summer 2023 study area. The fall survey zone included trees in other areas of Worcester, as well as some in the towns of Auburn, Holden, West Boylston, Boylston, and Shrewsbury. This data ended up in "Dataset_for_final_analysis_fall23.csv"

All trees in both surveys were planted between Fall 2010 and Spring 2012 by the DCR as part of an effort to restore canopy after the Longhorned Beetle removals.
A baseline survey of most of the trees surveyed in 2023 was conducted in 2014, 2015, and 2016. 
This baseline data is found in "DCRreplanted141516gisfieldmap.csv"

The work to merge S23 and F23 is broken into two notebooks:

[**DataPrep.ipynb**](https://github.com/andrews-j/UrbanForestry/blob/main/WorcesterTreeSurveyCleaning/DataCleaning/DataPrep.ipynb) is mostly about conforming the fields of S23 to the field structure of F23. Additionally, coordinate data for S23 trees is added via a join with baseline.

[**CombineRefine.ipynb**](https://github.com/andrews-j/UrbanForestry/blob/main/WorcesterTreeSurveyCleaning/DataCleaning/CombineRefine.ipynb) performs the merge, and extensive additional data cleaning
