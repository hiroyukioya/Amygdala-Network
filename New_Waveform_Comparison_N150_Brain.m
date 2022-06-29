clear all 
close all
home

addpath(genpath('\\lc-rs-storage20.hpc.uiowa.edu\hbrl_upload\for_Sawada\BrainMapping_Lib\parcellation'));
addpath(genpath('\\lc-rs-storage20.hpc.uiowa.edu\hbrl_upload\for_Sawada\BrainMapping_Lib\Subcortical_parcellation'));
addpath('\\lc-rs-storage20.hpc.uiowa.edu\hbrl_upload\for_Sawada\BrainMapping_Lib\MRIcroS/')
load('ROI_NUMBER.mat') 

PT_number=[369 376 384 399 400 403 404 405 413 416 418 427 466 511 515 534 572];
for i=1:numel(PT_number);
loadname=['\\lc-rs-storage20.hpc.uiowa.edu\hbrl_upload\for_Sawada\Ephys_data\PT',num2str(PT_number(i)),'_renamed_rawdata\Session_stim_pair.mat'];
load(loadname);
PT(i).Session_stim_pair=Session_stim_pair;

loadname=['\\lc-rs-storage20.hpc.uiowa.edu\hbrl_upload\for_Sawada\EsTTintegrate\Electlode_data\',num2str(PT_number(i)),'_Electrode_Sites_KN.xlsx'];
Table=table2cell(readtable(loadname,'Sheet',2)); Coordinates=ones(numel(Table(:,1)),4)*NaN; 
Coordinates(:,1)=cell2mat(Table(:,1)); Coordinates(:,[2 3 4])=cell2mat(Table(:,[7 8 9]));
PT(i).Coordinates=Coordinates;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%                 DATA OF RIGHT SIDE            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%RIGHT AMYGDATLA%%%%%%%%%%%%%%%%%%%%
Amy(1)={[]};
Amy(2)={[108]};
Amy(3)={[46 47 48 49]};
Amy(4)={[132 133]};
Amy(5)={[ ]};
Amy(6)={[]};
Amy(7)={[]};
Amy(8)={[102 103 104 105 106]};
Amy(9)={[]};
Amy(10)={[]};
Amy(11)={[77 ]};
Amy(12)={[]};
Amy(13)={[]};
Amy(14)={[89 90 91 92 93 94 95 96 97 117 118 123 124 125 126 127]};
Amy(15)={[13 14 ]};
Amy(16)={[79 80]};
Amy(17)={[]};

Depth(1)={[]};  %%1:lateral   0:medial
Depth(2)={[1]};
Depth(3)={[0 0 0 1]};
Depth(4)={[ 1 1 ]};
Depth(5)={[ ]};
Depth(6)={[]};
Depth(7)={[]};
Depth(8)={[0 0 0 1 1 ]};
Depth(9)={[]};
Depth(10)={[]};
Depth(11)={[1 ]};
Depth(12)={[]};
Depth(13)={[]};%{[0]};
Depth(14)={[0 0 0 0 0 0  0 0    0 0 0 0 0 0 0 0]};
Depth(15)={[1 1 ]}
Depth(16)={[0 1]};
Depth(17)={[]}
 

Coordinates_data_ROI_LR_PT_EXPs=[];
for i=  1: numel(PT_number);
       
           
       Tablename=['\\lc-rs-storage20.hpc.uiowa.edu\hbrl_upload\for_Sawada\EsTTintegrate\Electlode_data\',num2str(PT_number(i)),'_Electrode_Sites_KN.xlsx'];
       Table=readtable(Tablename,'sheet',2);    
    
                     Table=table2cell(Table);   
                      ROI=cell2mat(Table(:,15));
    
    
    
 for  j=1:numel(Amy{i})
 loadname=['\\lc-rs-storage20.hpc.uiowa.edu\hbrl_upload\for_Sawada\Ephys_data\PT',num2str(PT_number(i)),'_renamed_rawdata\',num2str(Amy{i}(j)),'\EPdata2.mat'];
        load(loadname)
Coordinates= PT(i).Coordinates;
                   Coordinates_and_data=ones(numel(PT(i).Coordinates(:,1)),10);Coordinates_and_data=Coordinates_and_data*NaN;
                   for k=1:numel(PT(i).Coordinates(:,1))
                      Top= find(Coordinates(:,1) == k);
                            if Top >= 1
                                  Coordinates_and_data(k,1:4)=Coordinates(Top,:);
                            else 
                            end
                   end
                              
                  X=Coordinates_and_data(:,2);
                  Y=Coordinates_and_data(:,3);
                  Z=Coordinates_and_data(:,4);
    
 
    LR=ones(numel(Coordinates_and_data(:,1)),1); LR=LR*NaN;      
    LR_table=Table(:,4);  R=(LR_table =="R");  R_ind=find(R ==1);
                              L=(LR_table =="L"); L_ind=find(L ==1); 
    LR(R_ind)=0; LR(L_ind)=1;                                            %%%%%%%%%%%right = 0    left =1%%%%%%%%%%%%%%%%%%%%
%% resample of data to 8000 Hz
SR=(numel(EP_data(1,:))-2)/2;
Res_EP=resample(EP_data(:,1:end-2)',8000,SR); Res_EP=Res_EP';

   %% Z transfrom
Baseline=7200:7920;
for kkk=1:numel(Res_EP(:,1));
    Base_ave=mean(Res_EP(kkk,Baseline));  Base_std=std(Res_EP(kkk,Baseline));
    Z= (Res_EP(kkk,:)-Base_ave)/ Base_std;
 Res_EP(kkk,:)=Z;   
end

Coordinates_and_data= [Coordinates_and_data(:,1:4) Res_EP];


  Coordinates_and_data_ROI=       [Coordinates_and_data  ROI];
  Coordinates_and_data_ROI_LR= [Coordinates_and_data_ROI   LR];
  Coordinates_data_ROI_LR_PT_EXP=[Coordinates_and_data_ROI_LR    repmat(PT_number(i), numel(Coordinates_and_data(:,1)),1)   repmat(Amy{i}(j), numel(Coordinates_and_data(:,1)),1)];
  
   
 Session_stim_pair=PT(i).Session_stim_pair; 
  Stim_elec=Session_stim_pair(find(Session_stim_pair (:,1)  ==Amy{i}(j)),2);
  Stim_coordinate_ind=find(Coordinates(:,1)==Stim_elec)  ;
  Stim_coordinate=Coordinates(Stim_coordinate_ind, [2 3 4]);
  
  Coordinates_data_ROI_LR_PT_EXP_StimCoord=[Coordinates_data_ROI_LR_PT_EXP    repmat(Stim_coordinate, numel(Coordinates_and_data(:,1)),1)];
  Coordinates_data_ROI_LR_PT_EXP_StimCoord_Reject=[ Coordinates_data_ROI_LR_PT_EXP_StimCoord EP_data(:,[end-1 end])];
  Coordinates_data_ROI_LR_PT_EXP_StimCoord_Reject_group=[Coordinates_data_ROI_LR_PT_EXP_StimCoord_Reject   repmat(Depth{i}(j), numel(Coordinates_data_ROI_LR_PT_EXP_StimCoord_Reject(:,1)) ,1) ];  
  
  
  Coordinates_data_ROI_LR_PT_EXPs=[Coordinates_data_ROI_LR_PT_EXPs ;       Coordinates_data_ROI_LR_PT_EXP_StimCoord_Reject_group];       
         
end
end

Coordinates_data_ROI_LR_PT_EXPs=sortrows(Coordinates_data_ROI_LR_PT_EXPs,16005);
%% Reject by Overfractuation over 5SD
Fructuation = Coordinates_data_ROI_LR_PT_EXPs(:,16012)./Coordinates_data_ROI_LR_PT_EXPs(:,16013);
Rej_ind=find(Fructuation > 0.5);
Coordinates_data_ROI_LR_PT_EXPs(Rej_ind, 4:end)= NaN;


Alldata_RIGHT=transpose(Coordinates_data_ROI_LR_PT_EXPs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%DATA FOR LEFT SIDE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Amy(1)={[91 92 100]};
Amy(2)={[]};
Amy(3)={[]};
Amy(4)={[]};
Amy(5)={[72 73 ]};
Amy(6)={[]};
Amy(7)={[39,40]};
Amy(8)={[]};
Amy(9)={[]};
Amy(10)={[]};
Amy(11)={[]};
Amy(12)={[]};
Amy(13)={[128 129 132 133 134 135]};
Amy(14)={[]};
Amy(15)={[6 7 8]};
Amy(16)={[]};
Amy(17)={[67 68]};

Depth(1)={[1 1 1]};
Depth(2)={[]};
Depth(3)={[]};
Depth(4)={[]};
Depth(5)={[1 1 ]};
Depth(6)={[ ]};
Depth(7)={[0 1]};
Depth(8)={[]};
Depth(9)={[]};
Depth(10)={[]};
Depth(11)={[]};
Depth(12)={[]};
Depth(13)={[0 0 0 0 1 1 ]};
Depth(14)={[]};
Depth(15)={[0 0 1]};
Depth(16)={[]};
Depth(17)= {[1 1]}


 Coordinates_data_ROI_LR_PT_EXPs=[];
for i=  1: numel(PT_number);
    
     Tablename=['\\lc-rs-storage20.hpc.uiowa.edu\hbrl_upload\for_Sawada\EsTTintegrate\Electlode_data\',num2str(PT_number(i)),'_Electrode_Sites_KN.xlsx'];
       Table=readtable(Tablename,'sheet',2);    
    
                     Table=table2cell(Table);   
                      ROI=cell2mat(Table(:,15));
    
 for  j=1:numel(Amy{i})
 loadname=['\\lc-rs-storage20.hpc.uiowa.edu\hbrl_upload\for_Sawada\Ephys_data\PT',num2str(PT_number(i)),'_renamed_rawdata\',num2str(Amy{i}(j)),'\EPdata2.mat'];
        load(loadname)
Coordinates= PT(i).Coordinates;
                  Coordinates_and_data=ones(numel(PT(i).Coordinates(:,1)),10);Coordinates_and_data=Coordinates_and_data*NaN;
                   for k=1:numel(PT(i).Coordinates(:,1))
                      Top= find(Coordinates(:,1) == k);
                            if Top >= 1
                                  Coordinates_and_data(k,1:4)=Coordinates(Top,:);
                            else 
                            end
                   end
                              
                  X=Coordinates_and_data(:,2);
                  Y=Coordinates_and_data(:,3);
                  Z=Coordinates_and_data(:,4);
    
 
    LR=ones(numel(Coordinates_and_data(:,1)),1); LR=LR*NaN;      
    LR_table=Table(:,4);  R=(LR_table =="R");  R_ind=find(R ==1);
                              L=(LR_table =="L"); L_ind=find(L ==1); 
    LR(R_ind)=0; LR(L_ind)=1;                                            %%%%%%%%%%%right = 0    left =1%%%%%%%%%%%%%%%%%%%%
%% resample of data to 8000 Hz
SR=(numel(EP_data(1,:))-2)/2;
Res_EP=resample(EP_data(:,1:end-2)',8000,SR); Res_EP=Res_EP';
   %% Z transfrom
Baseline=7200:7920;
for kkk=1:numel(Res_EP(:,1));
    Base_ave=mean(Res_EP(kkk,Baseline));  Base_std=std(Res_EP(kkk,Baseline));
    Z= (Res_EP(kkk,:)-Base_ave)/ Base_std;
 Res_EP(kkk,:)=Z;   
end

Coordinates_and_data= [Coordinates_and_data(:,1:4) Res_EP];


  Coordinates_and_data_ROI=       [Coordinates_and_data  ROI];
  Coordinates_and_data_ROI_LR= [Coordinates_and_data_ROI   LR];
  Coordinates_data_ROI_LR_PT_EXP=[Coordinates_and_data_ROI_LR    repmat(PT_number(i), numel(Coordinates_and_data(:,1)),1)   repmat(Amy{i}(j), numel(Coordinates_and_data(:,1)),1)];
  
   
 Session_stim_pair=PT(i).Session_stim_pair; 
  Stim_elec=Session_stim_pair(find(Session_stim_pair (:,1)  ==Amy{i}(j)),2);
  Stim_coordinate_ind=find(Coordinates(:,1)==Stim_elec)  ;
  Stim_coordinate=Coordinates(Stim_coordinate_ind, [2 3 4]);
  
  Coordinates_data_ROI_LR_PT_EXP_StimCoord=[Coordinates_data_ROI_LR_PT_EXP    repmat(Stim_coordinate, numel(Coordinates_and_data(:,1)),1)];
  Coordinates_data_ROI_LR_PT_EXP_StimCoord_Reject=[ Coordinates_data_ROI_LR_PT_EXP_StimCoord EP_data(:,[end-1 end])];
  Coordinates_data_ROI_LR_PT_EXP_StimCoord_Reject_group=[Coordinates_data_ROI_LR_PT_EXP_StimCoord_Reject   repmat(Depth{i}(j), numel(Coordinates_data_ROI_LR_PT_EXP_StimCoord_Reject(:,1)) ,1) ];  
  
  
  Coordinates_data_ROI_LR_PT_EXPs=[Coordinates_data_ROI_LR_PT_EXPs ;       Coordinates_data_ROI_LR_PT_EXP_StimCoord_Reject_group];       
         
end
end

Coordinates_data_ROI_LR_PT_EXPs=sortrows(Coordinates_data_ROI_LR_PT_EXPs,16005);
%% Reject by Overfractuation over 5SD
Fructuation = Coordinates_data_ROI_LR_PT_EXPs(:,16012)./Coordinates_data_ROI_LR_PT_EXPs(:,16013);
Rej_ind=find(Fructuation > 0.5);
Coordinates_data_ROI_LR_PT_EXPs(Rej_ind, 4:end)= NaN;


close all
 %% %%Classification according to the ROI%%%%%%%%%%%%%%%%%
 
Alldata_LEFT=transpose(Coordinates_data_ROI_LR_PT_EXPs);

Fake_right_ind= find(Alldata_LEFT(16006,:)==0);
Fake_left_ind=find(Alldata_LEFT(16006,:)==1);


Alldata_LEFT(16006,Fake_right_ind)=1;
Alldata_LEFT(16006,Fake_left_ind)=0;
Alldata_LEFT(2,:)=Alldata_LEFT(2,:)*(-1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Alldata=[Alldata_RIGHT Alldata_LEFT];


%%%%Erase opposite recording %%%%%
NoUseSideIndex=find(Alldata(16006,:) == 1 );   
Alldata(:,NoUseSideIndex)=[];
Used_ROI= unique(Alldata(16005,:));   Used_ROI(isnan(Used_ROI)) =[];
Used_ROI(find(Used_ROI  ==0)) =[];

    Used_ROI_name={}
   for k=1:numel(Used_ROI)
    Used_ROI_name{k,1}=ROI_NUMBER( Used_ROI(k) ,2);
    
   end
%%%%Filter %%%%%
 [b a]=butter(2,[4  ]/(8000/2),'high');
%%%%%%%%%%%%%%%%%%%%
 
 close all
Ps=zeros(numel(Used_ROI),6);
Hs=zeros(numel(Used_ROI),6);
Ns=zeros(numel(Used_ROI),2);
Avr_Coordinatess=zeros(numel(Used_ROI),3);
Subtractions=zeros(numel(Used_ROI),6);
Count=0;
t=linspace(-1,1,16000);
 for ii= Used_ROI;
      Count=Count+1;
        ROI_index=find(Alldata(16005,:) ==ii        );
        ROIdata=Alldata(:,ROI_index);
             UseSideIndex=find(ROIdata(16006,:) == 0 );                        %%%%left is 1 right is 0
             ROIdataUse1= ROIdata(:,UseSideIndex);
               
                %%%% if power is more than +-10 SD at 8ms after stim. Deleted          
             Del_index=find(abs(ROIdataUse1(8064,:)) >10)  ;
             ROIdataUse2=ROIdataUse1;
             ROIdataUse2(:,Del_index)=[];
             
              %%%% if power is more than 50 SD  anytime after stim. Deleted          
             Del_index2=find(max(abs(ROIdataUse2(8080:9600,:))) >50)  ;
             ROIdataUse2(:,Del_index2)=[];
             
             
             %%%filtering%%%%%%%%%%
              NaNcol_ind= find(isnan(ROIdataUse2(5,:)) ==1);    
              ROIdataUse2(:,NaNcol_ind)=[];  
              ROIdataUse2(5:16004,:)=filtfilt(b,a,ROIdataUse2(5:16004,:));
             
            Lateral_index=find(ROIdataUse2(16014,:)  == 1)   ;          %%%%%%lateral%%%%
            Medial_index=find(ROIdataUse2(16014,:)  == 0);
            
          
         figure(2)   
       %  subplot(6,7,Count)
            plot(  t,     mean(ROIdataUse2(5:16004,Medial_index),2    ),            'k')
            hold on
            plot(   t,    mean(ROIdataUse2(5:16004,Lateral_index),2    ),     'r')
            title(ROI_NUMBER(ii,2))
            xlim ([-0.01 0.2])
            ylim ([-10 10])
            
            Range10_30=range(ROIdataUse2(8085:8244,:)  );
            Range30_70=range(ROIdataUse2(8245:8564,:)  );
            Range70_200=range(ROIdataUse2(8565:9604,:)  );
            
            Max10_30=max(ROIdataUse2(8085:8244,:)  );
            Max30_70=max(ROIdataUse2(8245:8564,:)  );
            Max70_200=max(ROIdataUse2(8565:9604,:)  );
         Features=[Range10_30; Range30_70;Range70_200; Max10_30;Max30_70;Max70_200]';
         if numel(Medial_index)==1 | numel(Lateral_index)==1;
             p= ones(1,6)*NaN; h=ones(1,6)*NaN;
             
         else 
             [h p] =   ttest2(Features(Medial_index,:), Features(Lateral_index,:));
       
         end
         
         
         Subtraction =  (  mean(Features(Medial_index,:),1)- mean(Features(Lateral_index,:),1));
         Avr_Coordinates=transpose(mean(ROIdataUse2([2 3 4],:), 2));
     
     Ps(Count,:)=p;
     Hs(Count,:)=h;
     Ns(Count,1)=numel(Medial_index);   Ns(Count,2)=numel(Lateral_index);  
     Avr_Coordinatess(Count,:)=Avr_Coordinates;
     Subtractions(Count,:)=Subtraction;
 end
   
 Multiple_comparison=numel(Ps(:,3))- numel( find(isnan(Ps(:,3))==1)  )
 Corrected_alpha=0.05/Multiple_comparison

  
 Used_ROI_name= [Used_ROI_name, num2cell(Ns), num2cell(num2str(Ps))];
  
%  close all
 %%Discription of brain 

load('Destrieux_R.mat');
parc=parcels(:,1);

Structure = gifti('Conte69.R.pial.32k_fs_LR.surf.gii');
Color = gifti(['Conte69.R.atlasroi.32k_fs_LR.shape.gii']);

cdata=Color.cdata;
%cdata(cdata == 1) = single(parc);                    %%%   Now using the color data of Parcellation%%%%%%    The umber of parcels is always 29716 %%%%%%           




%%%%%%%%%%%%% Insertion of p value data to surface map %%%%%%%%%%%%%%%%
Pslog=-log10(Ps);
Medialsmall_index=find(Subtractions(:,3) < 0);    %%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!here! change samll of large !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Pslog(Medialsmall_index,3)=NaN; 

Max_late=Pslog(:,3);      %%%%%%%%%%%%%%%%%%%%%%here to change the target period !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Max_late(abs(Max_late) < -log10(Corrected_alpha)) =NaN;
%Mediallarge_index=find(Subtractions > 0);

Ranking=[Used_ROI' Max_late Ns]; 
Ranking_bu=Ranking;
Ranking=sortrows(Ranking,2,'descend');
Ranking(isnan(Ranking(:,2)),:)=[]
save('\\lc-rs-storage20.hpc.uiowa.edu\hbrl_upload\for_Sawada\PT_AmygdalaEsTT_matlabcode\Figure3\NP150ranking.mat','Ranking')


 parc2=parc;
for m=1:numel(Used_ROI);
      Ind=  find(  parc2          == Used_ROI(m));
     if Subtractions(m,3)<0
        parc2(Ind)=-Max_late(m);
     else
         parc2(Ind)=Max_late(m);
     end
end


Delete_ind=find(ismember(unique(parc), unique(Used_ROI) ) ==0);
for m=1:numel(Delete_ind);
     Ind=  find(  parc2          == Delete_ind(m));
     parc2(Ind)=NaN;
end

cdata(cdata==0)=NaN;
cdata(cdata == 1) = single(parc2);    
%%%%%%%%%%%Settting of brain%%%%%%%%%%%%%%%%
Brain.vertices=Structure.vertices;
Brain.cdata=cdata;
Brain.faces=Structure.faces;

Brain.EdgeColor='interp';
Brain.FaceColor= [0.9 0.9 0.9];%'interp';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 UseRoiIndex=find(Alldata(16005,:) >1 & Alldata(16005,:)<80);
 AlldataforUse=Alldata(:,UseRoiIndex);
 Right= find(AlldataforUse(2,:) > 0);
 AlldataforUse=AlldataforUse(:,Right);
 X=AlldataforUse(2,:); Y=AlldataforUse(3,:);Z=AlldataforUse(4,:);
     


%%%%%%%%%%Setting of figure and axis%%%%%%%%%%%%%%
f1=figure(1);
Clim=-log10(0.0000000001);
subplot(1,2,1)
                                            f1.WindowState='maximized';
                                            f1.Color='white';
                                            patch(Brain)
                                            axis equal
                                            grid off

                                            
                                           
                                            addpath('\\lc-rs-storage20.hpc.uiowa.edu\hbrl_upload\for_Sawada\BrainMapping_Lib');
                                            load RandBcolor.mat
                                           %colormap(RandBcolor(65:128,:));
                                            colormap(RandBcolor)
                                            %caxis([-log10(Corrected_alpha)   -log10(0.0000000001)])
                                                c=colorbar('location','southout');
                                            caxis([-Clim   Clim])
                                              c.Ticks=[-Clim -(-log10(Corrected_alpha)) -log10(Corrected_alpha) Clim ]
                                            %colorbar
                                            axis([0 80 -105 70 -60 80])
                                            grid off
                                            axis off

                                             l = light('Position',[12000 0 0],'Style','infinite')
                                             lighting gouraud
                                             material dull
                                             view([90 0])
                                             
   hold on
   scatter3(X,Y,Z,30,'k');
                                             
 
 subplot(1,2,2)

                                             f1.WindowState='maximized';
                                            f1.Color='white';
                                            patch(Brain)
                                            axis equal
                                            grid off

                                          
                                 
                                              %caxis([-log10(Corrected_alpha)   -log10(0.0000000001)])
                                               c=colorbar('location','southout');
                                            caxis([-Clim   Clim])
                                              c.Ticks=[-Clim -(-log10(Corrected_alpha)) -log10(Corrected_alpha) Clim ]
                                         %   colorbar
                                            axis([0 80 -105 70 -60 80])
                                            grid off
                                            axis off

                                             l = light('Position',[-12000 0 0],'Style','infinite')
                                             lighting gouraud
                                             material dull
                                            view([-90 0])
  hold on

   scatter3(X,Y,Z,30,'k');
   
x=floor(256*(-log10(Corrected_alpha))/Clim); 
NewBlueandRed=ones(512,3)
Element= linspace(0,1,256-x)'  ;
NewBlueandRed(1:256-x,[1 2])=[Element Element];
NewBlueandRed(256+x+1:512,[2 3])=[flipud(Element)  flipud(Element)];
colormap(NewBlueandRed);

   figure(4)
   c4=colorbar('location','southoutside')
     colormap(RandBcolor);
     c4.Ticks=[-10  0  10];
     c4.TickLabels=[{-10},{-log10(Corrected_alpha)},{10}];
          caxis([log10(0.0000000001)   -log10(0.0000000001)])
%%%%%%%%%%%%%%%%%%%%%%%% Subcortical structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('\\lc-rs-storage20.hpc.uiowa.edu\hbrl_upload\for_Sawada\BrainMapping_Lib'))
 f2=figure(2)
 f2.WindowState='maximized'
 f2.Color='white'
 Brain2.vertices=Structure.vertices;
 Brain2.faces=Structure.faces;
 Brain2.EdgeColor = 'none';
 CData=ones(1,numel(Structure.vertices(:,1)));
 Brain2.cdata =  CData;
 Brain2.FaceColor = 'interp'; 
 Brain2.FaceAlpha=0.3
 
 for i=1:7
Subcortical= load(['Hippo',num2str(i),'.mat'])
vertices=Subcortical.vertices;  faces=Subcortical.faces;
patch_config(vertices,faces,i,1)
 end
 
  hold on
   scatter3(X,Y,Z,30,'k');
 
 patch(Brain2)
 colormap gray
 axis equal
 caxis([-1 2])
 view(90,0)
 
 l=light('position', [-1000 0 0 ],'Style','infinite')
 axis([-100  100  -100 100 -100 100])
 view([-90 0])
 
 %%%%%%%%%%% demonstrate the evoked potential graph %%%%
 figure(3)
 showROI=  29; 
 showPT=511;
 side=0;
 Exp=90;
 A=find(Alldata(16005,:)==showROI)
 B=Alldata(:,A);
 C=find(B(16007,:)==showPT);
 D=B(:,C);
 E=find(D(16008,:)==Exp);
 F=D(:,E);

 t=transpose(linspace(-1,1,16000));
 %t=repmat(t,1,8)
 plot(t,F(5:16004,1))
 axis([-0.02 0.2 -40 40])
 hold on
 plot([0.07 0.07],[-40 40],':')
 
 %%%%%% Movie creattion  %%%%%%%%%
 AlldataBU=Alldata;
 %Alldata=AlldataBU;

 
 
 
 Total_medial=numel(AlldataBU(160))
 
 %%%Removal of out of brain electrode %%%%
 
  Apdx=Alldata([1:4 16005:16014],:);
 WMind=find((isnan(Apdx(5,:))==1));
 
 Alldata(:,WMind)=[];
 Apdx(:,WMind)=[];
 %%%%Removal of poor recording %%%%%%%
 Poorind=find((isnan(Alldata(5,:))==1));
 Alldata(:,Poorind)=[];
 Apdx(:,Poorind)=[];
 
%%% resampling %%%%
  Resdata=resample( Alldata(5:16004,:),1000,8000);
  t=linspace(-1,1,2000);
 
 %STEP1 Wavefroms that have over 50 SD  after stim are going to be deleted
    Outlier1=find(max(transpose(Resdata(1008:2000,:))) > 50);
    Resdata(:,Outlier1)=[];
    Apdx(:,Outlier1)=[];
    
    %STEP2 Wavefroms that have over 15 SD before stimare going to be deleted
    Outlier2=find(max(transpose(Resdata(900:990,:))) > 15);
    Resdata(:,Outlier2)=[];
    Apdx(:,Outlier2)=[]; 
  
%         % STEP 3%%%%% over 5 SD at 10ms are goint to be deleted %%%%
%     overfluct1= find(abs(Resdata(1010,:)) >5);
%     Resdata(:,overfluct1)=[];
%     Apdx(:,overfluct1)=[];
    
%     %STEP 4 %%%%% over 5 SD at -10ms are goint to be deleted %%%%
%     overfluct2= find(abs(Resdata(990,:)) >5);
%     Resdata(:,overfluct2)=[];
%     Apdx(:,overfluct2)=[];

       %%%devide %%%%%% into  lateral and medial  %%%%%%%
    Med_ind=find(Apdx(14,:)==0);
    Lat_ind=find(Apdx(14,:)==1);
    
    Med_Resdata=Resdata(:,Med_ind);
    Lat_Resdata=Resdata(:,Lat_ind);
    Med_Apdx=Apdx(:,Med_ind);
    Lat_Apdx=Apdx(:,Lat_ind);
    %%% store the data for movie  %%%%
    
    Info=Med_Apdx;
    ECoG=Med_Resdata;
    
    
    Allroi=unique(Info(5,:));
    Roiandmean=[];
    [b a]=butter(2,[0.5 25]/(1000/2),'bandpass');    
    for k=Allroi
            ROIdata=   mean(   ECoG(:,     find(Info(5,:) == k))     ,2)      ;
            
            ROIdata(1010:2000)=filtfilt(b,a,ROIdata(1010:2000));
               
            ROIdata=ROIdata-ROIdata(990);
            ROIdata=[ROIdata ;k];
            if   numel( find(Info(5,:) == k)) > 5;
                 Roiandmean= [Roiandmean ROIdata];
                 
            else
            end
               
    end
