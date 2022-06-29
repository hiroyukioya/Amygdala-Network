function [ newX, newY, osamp, S ] = smote(X,Y)

a = size(X,1);
k = unique(Y);
for n =1:length(k)
      f = find(Y==k(n));
      eval(['y.c',num2str(n),'=f;'])
      N(n) = length(f);
end

[i,ii] = min(N);
eval(['mdat = X(y.c',num2str(ii),',:);']);

p = squareform(pdist(mdat));
p = 10^15*diag(ones(size(p,1),1))+p;

Ns = max(N)-i;
S = zeros(Ns,size(X,2));
for n = 1:Ns
    ni = 1+rem(n,i);
    [ki,kki] = sort(p(ni,:));
    irand = randi(5);
    sel = kki(irand);
    r = -1 + 2*rand(1);
    S(n,:) = mdat(ni,:) + r*(mdat(sel,:)-mdat(ni,:));
end
    
newX = [X;S];
newY = [Y ; ones(Ns,1)*k(ii)];
    
osamp(1:a) = 0;  
osamp(a+1:size(newX,1)) = 1;  
