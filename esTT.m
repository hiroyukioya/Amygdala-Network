classdef esTT
    % esTT class. Analysis of esTT data.

    properties (Access = public)
        pid
        block
        validCH
        rmCH
        t
        Av
        indiv
        rej
        fs
        bp
        sorttime
        stimch
        amp
        V
        trange
        aep
    end

    methods
        % Read data
        function dat = readNLX(dat)
            % Read data        
            % Triggered by ES -------
            I.trgch = 2;
            [I] = NLXconversion_TT2(dat.pid, dat.block, dat.validCH, I, I.trgch, dat.trange);
            estrg = I.trgtime;
            
            % Artifact removal -------- 
            ndat = [];
            for c = 1:size(I.dat,3)
                [ndat(:,:,c)] = rmStimArtifact5(I.dat(:,:,c), I.tind, [-0.008 0.008],I.fs); 
            end
        
            % Resample -------   
            esresp = [];ratio = 8;
            for c = 1:size(I.dat,3)
%                 [esresp(:,:,c)] = detrend(resample(I.dat(:,:,c),1,ratio),'constant');
                [esresp(:,:,c)] = detrend(resample(I.dat(:,:,c),1,ratio),'constant');
            end
            fs = I.fs/ratio;
            t = linspace(I.tind(1),I.tind(end),size(esresp,1));
                       
            orig = detrend(squeeze(trimmean(esresp,10,2)),'constant');
            Av = trimmean(orig,0,3);
            dat.Av = detrend(Av,'constant');
            dat.t = t;
            dat.indiv = esresp;
            dat.fs = fs;
        end

        % Plot single ch data
        function [h] = singlechplot(dat,ch,m)
           chan = find(dat.validCH==ch);
            if isempty(chan)~=1
                % Baseline value correction
                ff = find(dat.t>-0.625 & dat.t<=-0.01);
                m0 = squeeze(mean(dat.indiv(ff,:,chan),1));
                %chdat = dat.indiv(:,:,chan)-repmat(m0,length(dat.t),1);
                chdat = dat.indiv(:,:,chan);
                % N1 amplitude 
                f = find(dat.t> dat.sorttime(1) & dat.t <= dat.sorttime(2));
                % rejection 
                tem = setdiff([1:size(chdat,2)],dat.rej(chan).rej);
                chdat = chdat(:,tem);

                clf;
                m = m(tem);
                mt = sin(m);

                efficients{:,1};
                P = mdl.Coefficients{2,end};
                hold on;
                k =  linspace(min(mt), max(mt), 200);
                y = b(1) + b(2).*k;
                h = plot(k,y,'m','linewidth',2);
                xlabel('sin(\theta)'); set(gca,'fontsize',16)
                ax = axis; pp = sprintf('%s%1.5f','p=',P);
                text(ax(2)*0.5, ax(4)*0.95, pp)
                if P>0.05/length(dat.validCH)
                    set(h,'color','k')
                elseif P<0.01/length(dat.validCH)
                    set(h,'color','r')
                end
                
                mt = cos(m);
%                 mt = m0(tem);
                [i,ii] = sort(mt);
                m2 = squeeze(mean(abs(chdat(f,:)),1));m2=m2(:);
                subplot(2,3,6); plot(mt(ii),m2(ii),'o','linewidth',2);axis square
                mdl = fitlm(mt(ii), m2(ii));
                b = mdl.Coefficients{:,1};
                P = mdl.Coefficients{2,end};
                hold on;
                k =  linspace(min(mt), max(mt), 200);
                y = b(1) + b(2).*k;
                h = plot(k,y,'m','linewidth',2);xlabel('cos(\theta)');set(gca,'fontsize',16);
                ax = axis;pp = sprintf('%s%1.5f','p=',P);
                text(ax(2)*0.5, ax(4)*0.95,pp)
                if P>0.05/length(dat.validCH)
                    set(h,'color','k')
                elseif P<0.01/length(dat.validCH)
                    set(h,'color','r')
                end
                
                m0 = squeeze(mean(abs(chdat(f,:)),1));
                ma = m;
                mt = m0;
                [i,ii] = sort(mt);
                subplot(2,4,[1 2]);imagesc(dat.t, 1:length(ii),chdat(:,ii)');
                caxis([-100 100]); xlim([-0.2 0.5]);
                title([num2str(dat.pid) '-' dat.block,' ch ', num2str(ch)]); colorbar; grid on;
                set(gca,'linewidth',1,'fontsize',12); ylabel('Trial'); xlabel('Time (s)')
              
                subplot(2,4,3); 
                col = parula(length(ii));
                h = polarscatter(ma(ii),mt(ii),50,col,'filled','markeredgecolor','k');
                set(h,'linewidth',1);
                
                sAv = trimmean(chdat(:,ii(1:15)),0,3);grid on ;
                Av = mean(chdat(:,ii),2);
                subplot(2,3,4); plot(dat.t,mean(sAv,2),'LineWidth',1);
                ylim([-100 100]);xlim([-0.2 0.5]);hold on;
                subplot(2,3,4); plot(dat.t,mean(Av,2),'LineWidth',1.5,'color','k');
                ylim([-100 100]);xlim([-0.2 0.5]);hold on;
                
                sAv = trimmean(chdat(:,ii(end-14:end)),0,3);grid on ; hold on;
                subplot(2,3,4); plot(dat.t,mean(sAv,2),'LineWidth',1,'color','r');ylim([-150 150]);xlim([-0.2 0.5])
                set(gca,'linewidth',1,'fontsize',12); ylabel('\muV');xlabel('Time (s)')

                subplot(2,4,4); plot(dat.t, dat.V,'LineWidth',1);xlim([-0.5 1]);        
                set(gca,'linewidth',1,'fontsize',12);ylim([-200 600])
                figure(gcf);h = gcf; grid on;subtitle('Normalized inter-trial variability')
                
            else error('ch not found');
            end
        end
        
        % Multi-channel AEP plotting
        function [h] = gPlot64(dat)
            nch = size(dat.Av,2);
            k = ceil(nch/64);
            for i = 1:k
                clf;
                mm = min(i*64, nch);
                selch = (i-1)*64+1:mm;
                [h] = FGplot64chEP (dat.aep(:,selch), dat.t ,[-0.1 0.5],...
                    200,dat.validCH(selch));hold on;
                p = [num2str(dat.pid) '-' dat.block ]
                title(p)
                ss = ['~/TT/' num2str(dat.pid) '/' num2str(dat.pid) '-' dat.block '/AEP-' num2str(i)];
                print(gcf,ss,'-dpng','-r150') 
            end
        end
        
        % Find Rejection 
        function [dat, R] = findRejtr(dat)
            [a,tr,ch] = size(dat.indiv);
            base = find(dat.t>=-0.1 & dat.t<=-0.025);
            tt = find(dat.t>0.01 & dat.t<=0.5);
            bM = squeeze(mean(abs(dat.indiv(base,:,:)),1));
            bS = squeeze(std(abs(dat.indiv(base,:,:)),[],1));
            for n = 1:ch
                tem = bM(:,n);
                th = mean(tem) + 5*std(tem);
                f = find(abs(tem)>100);
                th2 = find(max(abs(dat.indiv(tt,:,n)),[],1) > 500);
                [J] = RJTrial_R3(dat.indiv(tt,:,n),3,500);
                J = union(J,th2);
                R(n).rej = union(J,f);
                fprintf('%s%s%s%d%s\n','     Rejected trial ch ',num2str(n),' = ',length(R(n).rej),'')
            end
            dat.rej=R;
        end

        % Phase calc.
        function [ang,amp,dat] = findphase(dat,freq,ch)
            chan = find(dat.validCH==ch);
            tem = dat.indiv(:,:,chan);
            % BP filt
            bp = (WindowedBandPassFilter(tem,dat.fs, 250, freq-1, freq+1));
            hp = hilbert(bp);
            ph = angle(hp);  
            an = abs(hp);
            f = find(dat.t>=-0.1 & dat.t<=-0.05);
            ang = mean(ph(f,:),1)';
            amp = mean(an(f,:),1)';
            dat.bp = bp;       
            dat.amp = amp;
        end
        
        % Trial-by-trial variability
        function [x] = variability_time(x,ch)
            f = find(x.validCH == ch);
            tem = setdiff([1:size(x.indiv,2)],x.rej(f).rej);
            tem = x.indiv(:,tem,f);
            V = var(tem,[],2);
            baseline  = find(x.t >=-0.5 & x.t<=-0.2);
            mv = mean(V(baseline));
            x.V = 100*(V/mv - 1);
        end
        
        % mtm-FFT
        function [S,f] = mtmSpec(dat,ch,timerange,tw)
            addpath ~/chronux_2_12/spectral_analysis/continuous;
            f = find(dat.validCH == ch);
            tem = setdiff([1:size(dat.indiv,2)],dat.rej(f).rej);
            params.tapers =[tw 2*tw-1];
            params.pad =1;
            params.Fs = dat.fs;
            params.err = 0;
            dati = dat.indiv(:,tem,f); dati = dati - mean(dati,2);
            ff = find(dat.t>=timerange(1) & dat.t<=timerange(2));
            [S,f] = mtspectrumc(dati(ff,:),params);
        end
    end
end