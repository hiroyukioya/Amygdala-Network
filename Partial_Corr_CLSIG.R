#####################################################################
###########         AMYG-esfMRI  CLSIG analysis       ###############
#####################################################################
library("tidyverse")
library("R.matlab")
library("qgraph")
library("ppcor")
rm(list = ls())  
trial<-1:30
PC1 <- array(numeric(),c(19,19,30)) # create empty matrix ...
PP1 <- array(numeric(),c(19,19,30)) # create empty matrix ...
PC2 <- array(numeric(),c(19,19,30)) # create empty matrix ...
PP2 <- array(numeric(),c(19,19,30)) # create empty matrix ...
PC3 <- array(numeric(),c(19,19,30)) # create empty matrix ...
PP3 <- array(numeric(),c(19,19,30)) # create empty matrix ...
# Run loop [ON]
for (i in trial) {
  ss<-paste("~/es-fMRI/AMYG-esfMRI/CLSIG/TS_CLSIG_",i,".mat",sep="")
  data<-readMat(ss)
  A2<-pcor(t(data$OFF))
  PC2[, , i]<-A2$estimate  # estimate
  PP2[, , i]<-A2$p.value   # p-value

  A2<-pcor(t(data$ON))
  PC1[, , i]<-A2$estimate  # estimate
  PP1[, , i]<-A2$p.value   # p-value
  
  A2<-pcor(t(data$ALL))
  PC3[, , i]<-A2$estimate  # estimate
  PP3[, , i]<-A2$p.value   # p-value
}
ss<-paste("~/es-fMRI/AMYG-esfMRI/CLSIG/Pcor.mat",sep="")
writeMat(ss,PC1=PC1,PP1=PP1,PC2=PC2,PP2=PP2,PP3=PP3,PC3=PC3)

###########  Community detection #################
library('igraph')
library("leidenAlg")  
library('leiden')  
# load data
ss<-paste("~/es-fMRI/AMYG-esfMRI/CLSIG/PcorD.mat",sep="")
data<-readMat(ss)
# data to be analyzed [Change variable name here]
indat<data$avXall
d<-dim(indat)
# Define_data to analyse and Create graph object
G <- graph_from_adjacency_matrix(indat, mode = "undirected",weighted=TRUE,'diag'=FALSE)
plot.igraph(G)
# Run Leiden's algorithm
parcel<-matrix(numeric(),d[1],200)
iter<-1:200
for (i in iter) {
  partition <- leiden.community(G,resolution=1,n.iterations=2 )  
  parcel[,i]<-as.double(as.matrix(partition$membership))
}
ss<-paste("~/es-fMRI/AMYG-esfMRI/group/Leiden_Parc.mat",sep="")
writeMat(ss,parcel=parcel)







  