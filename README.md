# ThermalPigR 
This repo is considered as supplementary data for the paper "An approach towards a practicable assessment of neonatal piglet body core temperature using automatic object detection based on thermal images" The the main software for this application is R Studio, which should be installed on your system (version 2022.02.3 Build 492 or higher) with R version **>=4.1**.

## Software requirement and setup
Download this repository and unzip to your preferred path.

Some additional installations outside of R are required to use the **ThermalPigR** package.  
Due to the use of the *readflirjpg* function from the **ThermImage** R package [^1], the installation of `Exiftool` is required, which
must be added to the **Path environment variable**. (This can be done during installation or manually afterwards)    

`Exiftool` can be installed via one of these two links:  (just follow the description)   
*https://exiftool.org/install.html*     
*https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows*

The *detect_yolov3* function uses the `yolov3` python package from roboflow [^2](forked from ultralytics [^3]).
This requires the following installations:
- Install `Python`**>= 3.8** and `Pytorch`**>=1.7** on your system. Python has to be added to the environment variable path too.

    - `Python` can be installed via the link below (via anaconda). Any other Python installation should also work. 
    *https://www.anaconda.com/products/individual*
    - `Pytorch` can be installed via this link:  (CPU)   
    *https://pytorch.org/get-started/locally/*  
- Additionally `yolov3` needs the following python packages to be installed:(easiest way should be via *conda install* you can find the correct commands by searching for the package name on *https://anaconda.org/conda-forge*
    - *numpy*
    - *opencv-python >= 4.1*
    - *matplotlib*
    - *pycocotools*
    - *tqdm*
    - *pillow*  
    
Depending on how you installed Python, some of these packages may already be installed. 

For the installation of the R package **ThermalPigR** itself, the *install_local()* function from the *remotes*
package is needed. Please install and load it into the session. After downloading and adding the R-package `thermalpigR_1.0.0.tar.gz` (*https://drive.google.com/file/d/1M24Np47MHuTz8UD8tzhIiUv3dAy-dwjZ/view?usp=sharing*) to the working directory the package(**ThermalPigR**) can be installed via 
```
remotes::install_local("path to thermalpigR_1.0.0.tar.gz")
```
[^1]:https://github.com/gtatters/Thermimage
[^2]:https://github.com/roboflow/yolov3
[^3]:https://github.com/ultralytics/yolov3

## Introduction with a 15 image dataset and reproduction of all results
This is an introduction to the package ThermalPigR uploaded as supplementary material of the Paper "An approach towards a practicable assessment of neonatal piglet body core temperature using automatic object detection based on thermal images". 

Load the package
```
library(thermalpigR)
```

Set the working directory to the download path of this repo.  
```
wd<-"PATH"  
setwd(wd)
```  

Produce the 15_data using the code of the paper "An approach towards a practicable assessment of neonatal piglet body core temperature using automatic object detection based on thermal images".  

1. Produce the "ClimateData_15" dataset.  
-> Combine all Excel datasets with ClimateData information (all pens) into one dataset.  
```
path_dir<-paste(wd,"ClimateData",sep="/") 
ClimateData_15<-LoadandCombineClimateData(path_dir)
```

2. Produce "myData_15" dataset.  
--> Combine general information and climate data for all images.
```
path_info_15<-paste(wd, "general_piglet_information.xlsx", sep="/")
path_im_15<-paste(wd, "Thermal_Images", sep="/")
myData_15<-CombineData(path_info_15,path_im_15)
myData_15<-matchTimeswithClimateData(myData_15,ClimateData_15)
```

3. Produce the object detection results.   
Before we can start with object detection, you have to download the yolov3spp-weights and add them to the working directory where you downloaded this github repo.
You can download via this link:   
*https://drive.google.com/file/d/1qqUVR34LNecylKlIqs1mwaOpAaX_7QFK/view?usp=share_link*

--> Set the path to weights, config and names(classes).
```
w<-paste(wd, "four_bp_yv3spp.pt",sep="/")
cfg<-paste(wd, "yolov3-spp.cfg",sep="/")
names<-paste(wd, "four_bp_yv3spp.names",sep="/")
```
  
--> Set the path to yolov3-master, add the image folder and set iou, confidence threshold and do the inference. The output is saved into the output_dir inside yolov3-master.(This step can take a few seconds)   
```
path<-paste(wd, "yolov3-master",sep="/")
source<-paste(wd, "Thermal_Images",sep="/")
iou<-0.1
conf<-0.3
output_dir<-detect_yolov3(path,w,cfg,source,names,iou,conf)
```
Produce "BP_coord_15" data. Import the coordinates of all .txt files from the object recognition.  
```
BP_coord_15<-get_bodypart_coordinates(output_dir)
```
Produce "BP_Features_15" data. The specific object distance and object emission can be adapted here. There may be warnings, which can be ignored at this point. (This step can take some minutes) 
```
BP_Features_15<-get_bodypart_features(BP_coord_15,path_im=source,
climate_info=myData_15,objectdistance=0.5,
emission=0.98, landw=FALSE)
```
Produce "AllFeatures_15" dataset. This is used to set up the estimation models.  
```
AllFeatures_15<-get_rel_quad_features(BP_Features_15)
```
**This following step is only nessecary if you want to use the manual body measurements of the piglets!!**   

Reproduce the "lw" dataset stored in the package. Dataset. Length and width measurement:  
```
Features_length_15<-get_bodypart_features(BP_coord_15,path_im=source,
climate_info=myData_15,objectdistance=0.5,
emission=0.98, landw=TRUE)
```
```
landw_15<-Features_length_15[,c(1,2,34,35)]
```




