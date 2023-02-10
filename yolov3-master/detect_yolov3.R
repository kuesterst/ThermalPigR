#' @title detect_yolov3
#'
#' @description This function opens python and executes the detect.py file
#'      to start the object detection. It uses the system function to pass a
#'      string to the shell. This function requires that python,pytorch and the
#'      python package roboflow-ai/yolov3 is installed. To download the python
#'      package use path="download".
#'
#' @param path A path to the python package roboflow-ai/yolov3 where
#'     detect.py is saved. Use path="download" to download the package to your
#'     working directory.
#' @param w A path to the weight file.
#' @param cfg A path to the cfg file.
#' @param source A path to the input images. Either one image or a directory
#'  with images
#' @param names A path to the names file.
#' @param iou A value between 0 and 1. This is the threshold for non-maximum
#'  suppresion.
#' @param conf A value between 0 and 1. This is the confidence threshold for
#' the output of the boxes
#'
#' @return A path to the directory where the output from the image detection
#' are saved.
#' @examples
#' \dontrun{
#' path<-"download"
#' w<-system.file("extdata", "four_bp_yv3spp.pt",package="thermalpigR")
#' cfg<-system.file("extdata", "yolov3-spp.cfg",package="thermalpigR")
#' source<-system.file("extdata", "22041_1138_1.jpg",package="thermalpigR")
#' names<-system.file("extdata", "four_bp_yv3spp.names",package="thermalpigR")
#' iou<- 0.1
#' conf<- 0.3
#' output <- detect(path,w,cfg,source,names,iou,conf)
#'
#'
#' path<-paste(getwd(),"yolov3-master",sep="/")
#' output <- detect_yolov3(path,w,cfg,source,names,iou,conf)
#' }
#' @export
#' @importFrom utils download.file
#' @importFrom utils unzip



detect_yolov3<-function(path,w,cfg,source,names,iou,conf)
{
  #This function opens python and executes the detect.py file to start
  #the object detection. It uses the system function to pass a string to
  #the shell.
  #This function requires that python,pytorch and the python package
  #roboflow-ai/yolov3 is installed.


  #path should be the path to the python package where detect.py is saved
  #w path to the weight file
  #cfg path to the cfg file
  #source path to the input images. Either one image or a directory with images
  #names path to the names file
  #iou the iou threshold for nms
  #conf the confidence threshold

  #check if python package yolov3 should be downloaded from github
  if(path=="download")
  {
    print("Downloading yolov3 python package to the working directory.")
    path_dir_down<-paste("https://github.com/roboflow-ai/yolov3",
                         "archive/refs/heads/master.zip",sep="/")

    path_zip<-paste(getwd(),"rf_yolov3.zip",sep="/")

    download.file(path_dir_down,destfile = path_zip)
    unzip(path_zip,exdir=getwd())
    print("Download finished! The package should be in your working directory.")
    path<-paste(getwd(),"yolov3-master",sep="/")
  }



  if(file.exists(w)==FALSE)
  {
    message("error: weight file not found")
    return("error: weight file not found")
  }
  if(file.exists(cfg)==FALSE)
  {
    message("error: cfg file not found")
    return("error: cfg file not found")
  }
  if(file.exists(names)==FALSE)
  {
    message("error: names file not found")
    return("error: names file not found")
  }
  if(file.exists(source)==FALSE && dir.exists(source)==FALSE)
  {
    message("error: source not found")
    return("error: source not found")
  }
  if(dir.exists(path)==FALSE)
  {
    message("error: path not found")
    return("error: path not found")
  }
  if(file.exists(paste(path,"detect.py",sep="/"))==FALSE)
  {
    message("error: detect.py not found")
    return("error: detect.py not found")
  }
  wd<-getwd()

  string<-paste("python detect.py --weights",w,"--source",source,
                "--names",names,"--save-txt",
                "--iou-thres",iou,"--conf-thres",conf,sep=' ')

  setwd(path)
  system(string)
  setwd(wd)

  output<-paste(path,"output",sep="/")
  print(paste("Detection succesfull. The output is saved in",output, sep=" "))

  return(output)
}






