function [out,Mdl] = RForestClassifier(nX, nY, NTREE, Ntest, cNorm)

numT = Ntest;
fp=[]; tp=[];
for tindex = 1:numT
    tindex,
    if cNorm==1
        X = centernormalize(nX(:,:,1),1);
    else
        X=nX;
    end
  
    % Train RF.....
    Options.UseParallel = 'true';
    Options.UseSubstreams = 'false';
    Options.Streams = [];
     
    Mdl = TreeBagger(NTREE,X, nY, 'OOBPrediction','On','Surrogate','off',...
        'Method','classification','OOBPredictorImportance','on','Prior','empirical',...
        'PredictorSelection','allsplit','Options',Options);
    
    out.importance(:,tindex) = Mdl.OOBPermutedPredictorDeltaError';
    out.margin(:,tindex) = Mdl.oobMeanMargin';
    accu = 1-Mdl.oobError;
    [yfit, sfit] = oobPredict(Mdl);
    [temp1, temp2,T,auc] = perfcurve(Mdl.Y, sfit(:,2),'2');
    
    fp = [fp; temp1];
    tp = [tp; temp2];
    
    oobErrorBaggedEnsemble(:,tindex) = oobError(Mdl);
    figure(1001),clf; plot(oobErrorBaggedEnsemble); figure(gcf);

    [i,ii] = sort(accu,'descend'); % take the one with least error rate 
    out.accu(tindex) = accu(end);
    out.auc(tindex) = auc;
    
end
out.iacc = out.accu;
out.iauc = out.auc;
out.accu = mean(out.accu);
out.auc = mean(out.auc);
out.oobC = mean(oobErrorBaggedEnsemble,2);
out.fp = fp; 
out.tp = tp;
