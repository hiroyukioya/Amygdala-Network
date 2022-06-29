### this is for UMAP and catboost including ROI information 
rm(list=ls())
#graphics.off()
#install.packages('umap') 
library(umap)
library("R.matlab")



ss1 =paste("//itf-rs-store16.hpc.uiowa.edu/hbrl_upload/for_Sawada/PT_AmygdalaEsTT_matlabcode/Figure2/Machine_learning/Alldata_matrix_roi.mat")    
Alldata =readMat(ss1)

Answer=(Alldata[1])
ROI=(Alldata[2])
ROI_m=matrix(unlist(ROI),ncol=3726);
ROI_m=t(ROI_m)

Window=(Alldata[3])
Window_m=matrix(unlist(Window),ncol=3726);
Window_m=t(Window_m)

############### Here start the umap dimensionaltiy are reduced to 5  ####################

#Window_m.umap = umap(Window_m)
#Window_m.umap
x=c(2,3,4,5,6,7,8,9,10,100)
Count1=0;
Accuracyss=matrix(,nrow=10,ncol=0)
for (val1 in x) {
  Dimension=val1    ###############################
  Count1=Count1+1;            
  custom.config = umap.defaults
  custom.config$n_components = Dimension
  
  Window_m.umap.config=umap(Window_m,config=custom.config)
  coord= Window_m.umap.config$layout
  coord2=matrix(unlist(coord),nrow=3726);
  
  ###### Here start cat boost  ##################################################
  library("catboost")
  library("tidyverse")
  library(caret)
  
  #### Creating the dataset for catboost
  Answer1=t(Answer$Answer)            ###############check  !!!!!!!!!!!!!
  Dataset=cbind(coord2,Answer1);
  Dataset=cbind(ROI_m, Dataset)
  ##### Randamazation of 
  DatasetRM=Dataset[sample(nrow(Dataset)),];
  
  
  Accuracys=matrix(,nrow=10,ncol=1)
  i=  c(1,   c(1:9)*370);
  count=0;
  for (val in i) {
    count=count+1;
    Test_data=DatasetRM[val:(val+369),];
    Train_data=DatasetRM[-c(val:(val+369)), ];
    
    
    target=Dimension+2
    targetr= target-1
    
    # create catboost data for Train
    pool<-catboost.load_pool(Train_data[,(1:targetr)],label=Train_data[,target],cat_features =0)
    cat("Nrows: ", nrow(pool), ", Ncols: ", ncol(pool), "\n")
    
    # Parameter settings
    fit_params = list(iterations = 100,
                      thread_count = 10,
                      loss_function = 'Logloss',
                      border_count = 32,
                      depth = 12,
                      learning_rate = 0.03,
                      l2_leaf_reg = 3.5,
                      train_dir='train_dir',
                      logging_level = 'Silent')
    
    
    # Train catboost model .....
    model = catboost.train(pool,test_pool=NULL,params=fit_params)
    
    # create catboost data for Test
    pool2=catboost.load_pool(Test_data[,1:(targetr)],label=Test_data[,target],cat_features =0)
    cat("Nrows: ", nrow(pool2), ", Ncols: ", ncol(pool2), "\n")
    
    prediction<-catboost.predict(model,
                                 pool2,
                                 verbose = FALSE,
                                 prediction_type = "Class",
                                 ntree_start = 0,
                                 ntree_end = 0,
                                 thread_count = -1)
    
   # plot(c(1:(Dimension+1),model$feature_importances,type='h',lwd=10,col='blue')  
    print(Test_data[,target])
    plot(prediction,type='p',col='red')
    print(prediction);
    
    Diff=prediction-Test_data[,target]
    Accucary= length(which(Diff==0))/length(prediction)*100;
    Accuracys[count]=Accucary
  }
  
  Accuracyss=    cbind(Accuracyss,Accuracys)             
}     
print(Accuracyss)



write.table(Accuracyss, file = "//itf-rs-store16.hpc.uiowa.edu/hbrl_upload/for_Sawada/PT_AmygdalaEsTT_matlabcode/Figure2/Machine_learning/Accuracy_catboost_ROI.csv",sep = ", ")  
