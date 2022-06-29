install.packages('umap')
#####################
library(umap)
library("R.matlab")
# load data matrix
ss<-paste("~/TT/Sawada/PCA_matrix.mat") 
data<-readMat(ss)
# settings
custom.settings = umap.defaults
custom.settings$n_neighbors = 20
custom.setting
# apply UMAP 
epdat<-data$Segdata
epdat<-t(epdat)
ep.umap = umap(epdat,config=custom.settings)
# get embedding coordinates 
coord<-ep.umap$layout
x<-seq(1,1040,by=1)
plot(coord,type="o")
writeMat('~/TT/Sawada/Umap-P150.mat',coord=coord)
