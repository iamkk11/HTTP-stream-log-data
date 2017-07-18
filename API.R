library(class)
library(jsonlite)
library(varhandle)

load("knn_model.RData")

#* @post /predict
predict.seg_dur <- function(Arr_time,Del_Time,Byte_Size) 
  {
  data <- data.frame(Arr_time=Arr_time,Del_Time=Del_Time,Byte_Size=Byte_Size)
  prediction <- predict(knn.fit, data)
  return(seg_dur=(prediction))
}

