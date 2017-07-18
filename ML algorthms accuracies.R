#Initializing variables

f=c('ARBITER','BBA','ELASTIC')

knn_accuracy<-rep(0,3)
ctree_accuracy<-rep(0,3)
logistic_regression_accuracy<-rep(0,3)
naive_bayes_accuracy<-rep(0,3)
svm_accuracy<-rep(0,3)

#Reading trace file folder locations

for(v in f){

p=paste('/home/kevin/Downloads/data-4sec-10sec/4sec/',v,sep='')
q=paste('/home/kevin/Downloads/6-8sec/6Sec/',v,sep='')
m=paste('/home/kevin/Downloads/6-8sec/8sec/',v,sep='')
n=paste('/home/kevin/Downloads/data-4sec-10sec/10sec/',v,sep='')

#Combine files from folder into 1 data frame

library('dplyr',warn.conflicts=FALSE)

#Defining function to merge traces

combine = function(mypath){
  filenames=list.files(path=mypath, full.names=TRUE)
  datalist = lapply(filenames, function(x){read.csv(file=x,sep='')})
  Reduce(function(x,y) {bind_rows(x,y)}, datalist)}

a=combine(p);b=combine(q);c=combine(m);d=combine(n)


#adding segment duration column

a$seg_dur=rep(4,nrow(a));b$seg_dur=rep(6,nrow(b))
c$seg_dur=rep(8,nrow(c));d$seg_dur=rep(10,nrow(d))


#Binding rows into 1 dataframe

e=bind_rows(a,b,c,d)

#Droping columns which represent client data

columnstodrop<-c('Seg_.','Stall_Dur','Rep_Level','Buff_Level'
				,'Del_Rate','Act_Rate')
columnstokeep<-setdiff(names(e),columnstodrop)

#Endowing the dataset with the new columns

e<-e[,columnstokeep]

#Converting segment duration to a factor

e$seg_dur<-factor(e$seg_dur)

#New dataset with rows equal to seg_dur_10

seg_dur_4=subset(e,seg_dur==4)
seg_dur_6=subset(e,seg_dur==6)
seg_dur_8=subset(e,seg_dur==8)
seg_dur_10=subset(e,seg_dur==10)

d1<-nrow(seg_dur_4)-nrow(seg_dur_10)
d2<-nrow(seg_dur_6)-nrow(seg_dur_10)
d3<-nrow(seg_dur_8)-nrow(seg_dur_10)

seg_dur_4_remove_ind<-which(with( e, seg_dur==4))[1:d1]
seg_dur_6_remove_ind<-which(with( e, seg_dur==6))[1:d2]
seg_dur_8_remove_ind<-which(with( e, seg_dur==8))[1:d3]


e_same1<-NULL
e_same1<-e[-c(seg_dur_4_remove_ind,seg_dur_6_remove_ind
		,seg_dur_8_remove_ind),]

#Removing subsets

seg_dur_4_remove_ind<-which(with( e_same1, seg_dur==4))
seg_dur_6_remove_ind<-which(with( e_same1, seg_dur==6))
seg_dur_8_remove_ind<-which(with( e_same1, seg_dur==8))
seg_dur_10_remove_ind<-which(with( e_same1, seg_dur==10))

#Switching between samples

e_same<-NULL
e_same<-e_same1[-c(seg_dur_10_remove_ind),]
#e_same<-e_same1

#Training and test

set.seed(1)
e_same<- e_same[sample(nrow(e_same)),]
t=0.8*nrow(e_same)
trainindices <- 1:t
gtrain<-e_same[trainindices,]
gtrainlabel<-as.matrix(c(e_same[trainindices,4]))
gtest<-e_same[-trainindices,1:3]
gtest_knn<-e_same[-trainindices,]
gtestlabel_knn<-as.matrix(c(e_same[-trainindices,4]))
library('varhandle')
gtestlabel<-c(unfactor(e_same$seg_dur[-trainindices]))


library('e1071',warn.conflicts=FALSE)
#naive bayes
naive_bayes_model<-naiveBayes(seg_dur ~ ., data = gtrain)
naive_bayes_predictions<-predict(naive_bayes_model, newdata = gtest)
naive_bayes_accuracy[v]=mean(naive_bayes_predictions==gtestlabel)

#svm
svm_model<- svm(seg_dur ~ ., data = gtrain)
svm_predictions <- predict(svm_model,newdata=gtest,type='response')
svm_accuracy[v] <- mean(svm_predictions==gtestlabel)

#logistic regression
logistic_regression_model<-glm(seg_dur ~ .
		, data = gtrain,family=binomial(link=logit))
logistic_regression_probs<-predict(logistic_regression_model
,newdata = gtest,type='response')
#converting probabilities to class labels
logistic_regression_predictions=rep(4,nrow(gtest))
logistic_regression_predictions[logistic_regression_probs>.5]=10
logistic_regression_accuracy[v]=
mean(logistic_regression_predictions==gtestlabel)

#classification tree
library('party',warn.conflicts=FALSE)
ctree_model<- ctree(seg_dur ~ ., data = gtrain
,controls=ctree_control(minsplit=30,minbucket=10,maxdepth=5))
ctree_predictions <- predict(ctree_model
				,newdata=gtest,type='response')
ctree_accuracy[v]=mean(ctree_predictions==gtestlabel)

#knn
library('class',warn.conflicts=FALSE)
knn_predictions <- knn(train=gtrain,test=gtest_knn,cl=gtrainlabel, k = 1)
knn_accuracy[v]=mean(knn_predictions==gtestlabel_knn)


}

round(knn_accuracy[4:6],2)*100
round(ctree_accuracy[4:6],2)*100
round(logistic_regression_accuracy[4:6],2)*100
round(naive_bayes_accuracy[4:6],2)*100
round(svm_accuracy[4:6],2)*100


