%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%    Processing FADTTS   %%%%%%%%%%%%
%%%%%%%%%%     FADTTSter $version$     %%%%%%%%%%%%
%%%%%%%%%% $date$ at $time$ %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
clc

disp('Running matlab script without plotting...')

% Number of thread used to run the script
$nbrCompThreads$

% Path to access FADTTS functions
addpath '$addMVCMPath$';


%% Set & Load
disp(' ')
disp('1. Set/Load')
disp('Setting inputs...')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Inputs %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading Folder
[ loadingFolder, loadingName, loadingExt ] = fileparts( mfilename( 'fullpath' ) );

% Saving Folder
savingFolder = strcat( loadingFolder, '/MatlabOutputs' );

% Input FiberName
$inputFiberName$
% Input Diffusion Properties
$inputDiffusionProperties$
% Input Files
$inputMatlabSubMatrixInputFile$
$inputDiffusionFiles$
% Input Covariates
$inputNbrCovariates$
$inputCovariates$
% Settings
$inputNbrPermutations$
$inputOmnibus$
$inputPostHoc$
$confidenceBandsThreshold$
$pvalueThreshold$
ySigLevel = -log10( pvalueThreshold );


% Y-Limite
% Change this limit to SouthEastOutside fit your data for visualization
ylimMin = -0.02;
ylimMax = 0.015;

% COLORS
red = [1 0 0];
lime = [0 1 0];
blue = [0 0 1];
yellow = [1 0.843 0];
cyan = [0 1 1];
magenta = [1 0 1];
olive = [0.5 0.5 0];
teal = [0 0.5 0.5];
purple = [0.5 0 0.5];
rosyBrown = [0.824 0.576 0.553];
darkSeaGreen = [0.553 0.824 0.576];
cornFlowerBlue = [0.576 0.553 0.824];
maroon = [0.5 0 0];
green = [0 0.392 0];
navy = [0 0 0.5];
orange = [1 0.5 0];
mint = [0 1 0.5];
pink = [1 0 0.5];
brown = [0.545 0.271 0.075];
black = [0 0 0];

color = cell(20,1);
color{1}=red;
color{2}=lime;
color{3}=blue;
color{4}=yellow;
color{5}=cyan;
color{6}=magenta;
color{7}=olive;
color{8}=teal;
color{9}=purple;
color{10}=rosyBrown;
color{11}=darkSeaGreen;
color{12}=cornFlowerBlue;
color{12}=maroon;
color{14}=green;
color{15}=navy;
color{16}=orange;
color{17}=mint;
color{18}=pink;
color{19}=brown;
color{20}=black;


disp('Loading covariate file...')
$matlabSubMatrixInputFile$
designdata = [ ones( size( data2, 1 ), 1 ) data2 ]; % intercept + covariates

Cnames = cell( nbrCovariates, 1 );
$covariates$

disp('Loading diffusion file...')
$diffusionFiles$
$diffusionProperties$

disp('Processing arclength...')
arclength = dataFiber1All( :, 1 );

% Creating (x,y,z) coordinates
CC_data = [ arclength zeros( size( arclength, 1 ), 1 ) zeros( size( arclength, 1 ), 1 ) ];

nofeatures = size( diffusionFiles, 1 );
[ NoSetup, arclength_allPos, Xdesign, Ydesign ] = MVCM_read( CC_data, designdata, diffusionFiles, nofeatures );
nbrSubjects = NoSetup( 1 );	% No of subjects
nbrArclengths = NoSetup( 2 ); % No of arclengths
nbrCovariates = NoSetup( 3 ); % No of covariates (including intercept)
nbrDiffusionProperties = NoSetup( 4 );	% No of diffusion properties = 1


disp('Plotting raw data...')
for pii=2:nbrCovariates
    if (designdata(1,pii) == 0 || designdata(1,pii) == 1)
        for Dii=1:nbrDiffusionProperties
            figure(Dii)
            for nii=1:nbrSubjects
                if (designdata(nii,pii) == 0)
                    h(1)=plot(arclength,Ydesign(nii,:,Dii),'-k','LineWidth', 1);
                else
                    h(2)=plot(arclength,Ydesign(nii,:,Dii),'-','Color',color{pii},'LineWidth', 1);
                end
                hold on
            end
            hold off
            xlabel('Arc Length','fontweight','bold');
            ylabel(Dnames{Dii},'fontweight','bold');
            xlim([min(arclength) max(arclength)]);
            legend([h(1) h(2)],sprintf('%s=0',Cnames{pii}),sprintf('%s=1',Cnames{pii}),'Location','SouthEastOutside');
            title(sprintf('%s\nRaw Data %s (%s)',fiberName,Cnames{pii},Dnames{Dii}),'fontweight','bold');
            clear h;
            saveas(gcf,sprintf('%s/%s_Raw_Data_%s_%s.pdf',savingFolder,fiberName,Cnames{pii},Dnames{Dii}),'pdf');
            close(Dii)
        end
    end
end


disp('Plotting raw data average and standard deviation...')
for pii=2:nbrCovariates
    if (designdata(1,pii) == 0 || designdata(1,pii) == 1)
        [Mavg]= mean(Ydesign(designdata(:,pii)==0,:,:)); % TD average for each diffusion paramter
        [Mstddev]= std(Ydesign(designdata(:,pii)==0,:,:)); % TD standard deviation for each diffusion paramter
        [Favg]= mean(Ydesign(designdata(:,pii)==1,:,:)); % SE average for each diffusion paramter
        [Fstddev]= std(Ydesign(designdata(:,pii)==1,:,:)); % SE standard deviation for each diffusion paramter
        for Dii=1:nbrDiffusionProperties
            figure(Dii)
            hold on
            h(1)=plot(arclength, Mavg(:,:,Dii),'-k','LineWidth', 1.25);
            plot(arclength, Mavg(:,:,Dii)+Mstddev(:,:,Dii),'--k','LineWidth', 1.25);
            plot(arclength, Mavg(:,:,Dii)-Mstddev(:,:,Dii),'--k','LineWidth', 1.25);
            h(2)=plot(arclength, Favg(:,:,Dii),'-','Color',color{pii},'LineWidth', 1.25);
            plot(arclength, Favg(:,:,Dii)+Fstddev(:,:,Dii),'--','Color',color{pii},'LineWidth', 1.25);
            plot(arclength, Favg(:,:,Dii)-Fstddev(:,:,Dii),'--','Color',color{pii},'LineWidth', 1.25);
            hold off
            xlabel('Arc Length','fontweight','bold');
            ylabel(Dnames{Dii},'fontweight','bold');
            xlim([min(arclength) max(arclength)]);
            legend([h(1) h(2)],sprintf('%s=0',Cnames{pii}),sprintf('%s=1',Cnames{pii}),'Location','SouthEastOutside');
            title(sprintf('%s\nAverage and Standard Deviation %s (%s)',fiberName,Cnames{pii},Dnames{Dii}),'fontweight','bold');
            clear h;
            saveas(gcf,sprintf('%s/%s_AverageStdDeviation_%s_%s.pdf',savingFolder,fiberName,Cnames{pii},Dnames{Dii}),'pdf');
            close(Dii)
        end
    end
end




%% 2. fit a model using local polynomial kernel smoothing
disp(' ')
disp('2. Betas')
disp('Calculating betas...')
[ mh ] = MVCM_lpks_wob( NoSetup, arclength_allPos, Xdesign, Ydesign );
[ efitBetas, efitBetas1, InvSigmats, efitYdesign ] = MVCM_lpks_wb1( NoSetup, arclength_allPos, Xdesign, Ydesign, mh );


disp('Plotting beta values...')
% betas are the coefficients that describe how related the covariate is to
% the parameter
for Dii=1:nbrDiffusionProperties
    figure()
    hold on
    h(1)=plot(arclength,efitBetas(1,:,Dii),'-k','LineWidth', 1.25);
    for pii=2:nbrCovariates
        h(pii)=plot(arclength,efitBetas(pii,:,Dii),'Color',color{pii},'LineWidth', 1.25);
    end
    hold off
    xlabel('Arc Length','fontweight','bold');
    ylabel(Dnames{Dii},'fontweight','bold');
    xlim([min(arclength) max(arclength)]);
    legend([h(:)],Cnames(1:nbrCovariates),'Location','SouthEastOutside');
    title(sprintf('%s\nBeta Values %s',fiberName,Dnames{Dii}),'fontweight','bold');
    clear h;
    saveas(gcf,sprintf('%s/%s_Betas_%s.pdf',savingFolder,fiberName,Dnames{Dii}),'pdf');
    disp(sprintf('Saving betas %s...',Dnames{Dii}))
    csvwrite(sprintf('%s/%s_Betas_%s.csv', savingFolder, fiberName, Dnames{Dii}),efitBetas(:,:,Dii));
    close()
end


disp('Smoothing individual function...')
ResYdesign = Ydesign - efitYdesign;
[ ResEtas, efitEtas, eSigEta ] = MVCM_sif( arclength_allPos, ResYdesign );
[ mSigEtaEig, mSigEta ] = MVCM_eigen( efitEtas );




%% 3. Omnibus Hypothesis Test
if( omnibus == 1 )
    disp(' ')
    disp('3. Omnibus')
    Gstats = zeros( 1, nbrCovariates-1 );
    Lstats = zeros( nbrArclengths, nbrCovariates-1 );
    Gpvals = zeros( 1, nbrCovariates-1 );
    
    disp('Calculating bias...')
    [ ebiasBetas ] = MVCM_bias( NoSetup, arclength_allPos, Xdesign, Ydesign, InvSigmats, mh );
    

    disp('Calculating omnibus individual and global statistics...')
    for pp=2:nbrCovariates
        cdesign=zeros( 1, nbrCovariates );
        cdesign( pp ) = 1;
        Cdesign = kron( eye( nbrDiffusionProperties ), cdesign );
        B0vector = zeros( nbrDiffusionProperties, nbrArclengths );
        [Gstat, Lstat] = MVCM_ht_stat( NoSetup, arclength_allPos, Xdesign, efitBetas, eSigEta, Cdesign, B0vector, ebiasBetas );
        Gstats( 1, pp-1 ) = Gstat;
        Lstats( :, pp-1 ) = Lstat;
        
        % Generate random samples and calculate the corresponding statistics and pvalues
        [Gpval] = MVCM_bstrp_pvalue3( NoSetup, arclength_allPos, Xdesign, Ydesign, efitBetas1, InvSigmats, mh, Cdesign, B0vector, Gstat, nbrPermutations );
        Gpvals( 1, pp-1 ) = Gpval;
    end

    disp('Saving omnibus global p-values...')
    csvwrite( sprintf( '%s/%s_Omnibus_Global_pvalues.csv', savingFolder, fiberName), Gpvals );
    Gpvals

    Lpvals = 1-chi2cdf( Lstats, nbrDiffusionProperties );
    disp('Saving omnibus local p-values...')
    csvwrite(sprintf('%s/%s_Omnibus_Local_pvalues.csv',savingFolder,fiberName),Lpvals);  % column for each covariate; local p-values are computed at each arclength
    
    
    disp('Plotting omnibus local p-values...')
    figure()
    hold on
    for pii=2:nbrCovariates
        h=plot(arclength,-log10(Lpvals(:,pii-1)),'Color',color{pii-1},'LineWidth', 1.25);
    end
    hold off
    xlabel('Arc Length','fontweight','bold');
    ylabel('-log10(p)','fontweight','bold');
    xlim([min(arclength) max(arclength)]);
    xL = get(gca,'XLim');
    line(xL,[ySigLevel ySigLevel],'Color','black'); % line at ySigLevel to mark significance level
    h=legend(Cnames(2:nbrCovariates),'Location','SouthEastOutside');
    title(sprintf('%s\nOmnibus Local p-values',fiberName),'fontweight','bold');
    clear h;
    saveas(gcf,sprintf('%s/%s_Omnibus_Local_pvalues.pdf',savingFolder,fiberName),'pdf');
    close()

    
    disp('Correcting omnibus local p-values...')
    % correct local p-values with FDR for multiple comparisons
    Lpvals_FDR = zeros( size( Lpvals ) );
    for pii = 2:nbrCovariates
        Lpvals_FDR( :, pii-1 ) = myFDR( Lpvals( :, pii-1 ));
    end
    
    disp('Saving omnibus FDR local p-values...')
    csvwrite( sprintf( '%s/%s_Omnibus_FDR_Local_pvalues.csv', savingFolder, fiberName), Lpvals_FDR );
    
    
    disp('Plotting omnibus FDR local p-values for all covariates...')
    figure()
    hold on
    for pii=2:nbrCovariates
        h=plot(arclength,-log10(Lpvals_FDR(:,pii-1)),'Color',color{pii-1},'LineWidth', 1.25);
    end
    hold off
    xlabel('Arc Length','fontweight','bold');
    ylabel('-log10(p)','fontweight','bold');
    xlim([min(arclength) max(arclength)]);
    xL = get(gca,'XLim');
    line(xL,[ySigLevel ySigLevel],'Color','black'); % line at ySigLevel to mark significance level
    h=legend(Cnames(2:nbrCovariates),'Location','SouthEastOutside');
    title(sprintf('%s\nOmnibus FDR Local p-values',fiberName),'fontweight','bold');
    clear h;
    saveas(gcf,sprintf('%s/%s_Omnibus_FDR_Local_pvalues.pdf',savingFolder,fiberName),'pdf');
    close()
    
    
    disp('Plotting omnibus FDR local p-values for each covariate...')
    for pii=2:nbrCovariates
        figure()
        plot(arclength, -log10(Lpvals_FDR(:,pii-1)), '-', 'Color', color{pii-1}, 'LineWidth', 1.25);
        xlabel('Arc Length','fontweight','bold');
        ylabel('-log10(p)','fontweight','bold');
        xlim([min(arclength) max(arclength)]);
        xL = get(gca,'XLim');
        line(xL,[ySigLevel ySigLevel],'Color','black'); % line at ySigLevel to mark significance level (0.05)
        h=legend(Cnames{pii},'Location','SouthEastOutside');
        title(sprintf('%s\nOmnibus FDR Local p-values %s',fiberName,Cnames{pii}),'fontweight','bold');
        clear h;
        saveas(gcf,sprintf('%s/%s_Omnibus_FDR_Local_pvalues_%s.pdf',savingFolder,fiberName,Cnames{pii}),'pdf');
        close()
    end
    
    
    disp('Plotting omnibus FDR significant beta values for each property...')
    for Dii=1:nbrDiffusionProperties % this may ned to be mii = 1:m
        figure()
        hold on
        for pii=2:nbrCovariates
            h(pii-1)=plot(arclength,efitBetas(pii,:,Dii),'Color',color{pii},'LineWidth', 1.25);
            ind=find(Lpvals_FDR(:,pii-1)<=pvalueThreshold);
            scatter(arclength(ind),efitBetas(pii,ind,Dii),25,color{pii},'filled')
        end
        hold off
        xlabel('Arc Length','fontweight','bold');
        ylabel(Dnames{Dii},'fontweight','bold');
        xlim([min(arclength) max(arclength)]);
        xL = get(gca,'XLim');
        line(xL,[0 0],'Color','black'); % line at zero
        legend([h(:)],Cnames(2:nbrCovariates),'Location','SouthEastOutside');
        title(sprintf('%s\nOmnibus FDR Significant Beta Values %s  %s=%s',fiberName,Dnames{Dii},'\alpha',num2str(pvalueThreshold)),'fontweight','bold');
        clear h;
        saveas(gcf,sprintf('%s/%s_Omnibus_FDR_SigBetas_Property_%s.pdf',savingFolder,fiberName,Dnames{Dii}),'pdf');
        close()
    end
    
    
    disp('Plotting omnibus FDR significant beta values for each covariate...')
    for pii = 2:nbrCovariates;
        figure()
        hold on
        for Dii=1:nbrDiffusionProperties
            h(Dii)=plot(arclength,efitBetas(pii,:,Dii),'-','Color',color{Dii},'LineWidth', 1.25);
            ind=find(Lpvals_FDR(:,pii-1)<=pvalueThreshold);
            scatter(arclength(ind),efitBetas(pii,ind,Dii),25,color{Dii},'filled')
        end
        hold off
        xlabel('Arc Length','fontweight','bold');
        ylabel('Beta Values','fontweight','bold');
        xlim([min(arclength) max(arclength)]);
        xL = get(gca,'XLim');
        line(xL,[0 0],'Color','black'); % line at zero
        legend([h(:)],Dnames(1:nbrDiffusionProperties),'Location','SouthEastOutside');
        title(sprintf('%s\nOmnibus FDR Significant Beta Values %s  %s=%s',fiberName,Cnames{pii},'\alpha',num2str(pvalueThreshold)),'fontweight','bold');
        clear h;
        saveas(gcf,sprintf('%s/%s_Omnibus_FDR_SigBetas_Covariate_%s.pdf',savingFolder,fiberName,Cnames{pii}),'pdf');
        close()
    end
    
    
    disp('Plotting omnibus FDR significant beta values for each covariate (y-limited)...')
    for pii = 2:nbrCovariates;
        figure()
        hold on
        for Dii=1:nbrDiffusionProperties
            h(Dii)=plot(arclength,efitBetas(pii,:,Dii),'-','Color',color{Dii},'LineWidth', 1.25);
            ind=find(Lpvals_FDR(:,pii-1)<=pvalueThreshold);
            scatter(arclength(ind),efitBetas(pii,ind,Dii),25,color{Dii},'filled')
        end
        hold off
        
        xlabel('Arc Length','fontweight','bold');
        ylabel('Beta Values','fontweight','bold');
        xlim([min(arclength) max(arclength)]);
        ylim([ylimMin ylimMax]);
        xL = get(gca,'XLim');
        line(xL,[0 0],'Color','black'); % line at zero
        legend([h(:)],Dnames(1:nbrDiffusionProperties),'Location','SouthEastOutside');
        title(sprintf('%s\nOmnibus FDR Significant Beta Values %s  %s=%s (y-limited)',fiberName,Cnames{pii},'\alpha',num2str(pvalueThreshold)),'fontweight','bold');
        clear h;
        
        saveas(gcf,sprintf('%s/%s_Omnibus_FDR_SigBetas_Covariate_ylimited_%s.pdf',savingFolder,fiberName,Cnames{pii}),'pdf');
        close()
    end
    
    
    disp('Calculating omnibus covariate confidence bands...')
    [Gvalue] = MVCM_cb_Gval( arclength_allPos, Xdesign, ResYdesign, InvSigmats, mh, nbrPermutations );
    [CBands] = MVCM_CBands( nbrSubjects, confidenceBandsThreshold, Gvalue, efitBetas, zeros( size( ebiasBetas ) ) );

    disp('Saving omnibus covariate confidence bands...')
    for Dii=1:nbrDiffusionProperties
        csvwrite( sprintf( '%s/%s_Omnibus_ConfidenceBands_%s.csv', savingFolder, fiberName, Dnames{Dii} ), CBands(:,:,Dii) );
    end
    
    
    disp('Plotting beta values with omnibus confidence bands...')
    for Dii=1:nbrDiffusionProperties
        for pii=1:nbrCovariates
            figure()
            hold on
            plot(arclength,efitBetas(pii,:,Dii),'-b','LineWidth', 1.25); % Parameter (FA,MD,RD,AD)
            plot(arclength,CBands(2*pii-1,:,Dii),'--r','LineWidth', 1.25); % Lower Conf Band
            plot(arclength,CBands(2*pii,:,Dii),'--r','LineWidth', 1.25); % Upper Conf Band
            hold off
            xlabel('Arc Length','fontweight','bold');
            ylabel(Dnames{Dii},'fontweight','bold');
            xlim([min(arclength) max(arclength)]);
            xL = get(gca,'XLim');
            line(xL,[0 0],'Color','black'); % line at zero
            title(sprintf('%s\nBeta Values %s (%s) with Omibus %s%% Confidence Bands',fiberName,Cnames{pii},Dnames{Dii},num2str( 100*( 1 - confidenceBandsThreshold ) )),'fontweight','bold');
            saveas(gcf,sprintf('%s/%s_Betas_Omnibus_ConfidenceBands_%s_%s.pdf',savingFolder,fiberName,Cnames{pii},Dnames{Dii}),'pdf');
            close()
        end
    end
    
    
end
% End of Omnibus Hypothesis Test




%% 4. Post-hoc Hypothesis Test --> Which Diffusion Parameter is significant where for each covariate? nbrArclengths univariate test in a multivariate model.
if( postHoc == 1 )
    if( omnibus == 1 )
        disp(' ')
        disp('4. Post-hoc')
    else
        disp(' ')
        disp('3. Post-hoc')
    end
    
    disp('Comparing the significance of each diffusion parameter for each covariate...')
    posthoc_Gpvals = zeros( nbrDiffusionProperties, nbrCovariates-1 );
    posthoc_Lpvals = zeros( nbrArclengths, nbrDiffusionProperties, nbrCovariates-1 );
    
    disp('Calculating post-hoc individual and global statistics...')
    for pii = 2:nbrCovariates;
        for Dii = 1:nbrDiffusionProperties
            Cdesign = zeros( 1, nbrDiffusionProperties*nbrCovariates );
            Cdesign( 1+( Dii-1 )*nbrCovariates+( pii-1 ) ) = 1;
            B0vector = zeros( 1, nbrArclengths );
            [Gstat, Lstat] = MVCM_ht_stat( NoSetup, arclength_allPos, Xdesign, efitBetas, eSigEta, Cdesign, B0vector, ebiasBetas );
            
            % Generate random samples and calculate the corresponding statistics and pvalues
            posthoc_Gpvals( Dii, pii-1 ) =  MVCM_bstrp_pvalue3( NoSetup, arclength_allPos, Xdesign, Ydesign, efitBetas1, InvSigmats, mh, Cdesign, B0vector, Gstat, nbrPermutations );
            posthoc_Lpvals( :, Dii, pii-1 ) = 1-chi2cdf( Lstat, 1 );
        end
    end

    disp('Saving post-hoc global p-values...')
    csvwrite( sprintf( '%s/%s_PostHoc_Global_pvalues.csv', savingFolder, fiberName ), posthoc_Gpvals );
    posthoc_Gpvals % for FA, RD, AD, MD for each covariate

    disp('Saving post-hoc local p-values...')
    for Dii = 1:nbrDiffusionProperties
        csvwrite( sprintf( '%s/%s_PostHoc_Local_pvalues_%s.csv', savingFolder, fiberName, Dnames{Dii} ), posthoc_Lpvals( :, Dii, : ) );
    end

    disp('Correcting post-hoc local p-values...')
    % correct posthoc test local p-values with FDR for multiple comparisons
    posthoc_Lpvals_FDR = zeros( size( posthoc_Lpvals ) );
    for Dii = 1:nbrDiffusionProperties
        for pii = 2:nbrCovariates
            posthoc_Lpvals_FDR( :, Dii, pii-1 ) = myFDR( posthoc_Lpvals( :, Dii, pii-1 ) );
        end
    end

    disp('Saving post-hoc FDR local p-values...')
    for Dii = 1:nbrDiffusionProperties
        csvwrite( sprintf( '%s/%s_PostHoc_FDR_Local_pvalues_%s.csv', savingFolder, fiberName, Dnames{Dii} ), posthoc_Lpvals_FDR( :, Dii, : ) );
    end

    disp('Plotting post-hoc FDR local p-values by property...')
    for pii = 2:nbrCovariates;
        figure()
        hold on
        for Dii=1:nbrDiffusionProperties
            plot(arclength, -log10(posthoc_Lpvals_FDR(:,Dii,pii-1)), '-', 'Color', color{Dii}, 'LineWidth', 1.25);
        end
        hold off
        xlabel('Arc Length','fontweight','bold');
        ylabel('-log10(p)','fontweight','bold');
        xlim([min(arclength) max(arclength)]);
        xL = get(gca,'XLim');
        line(xL,[ySigLevel ySigLevel],'Color','black'); % line at ySigLevel to mark significance level
        legend([Dnames(1:nbrDiffusionProperties)],'Location','SouthEastOutside');
        title(sprintf('%s\nPost-Hoc FDR Local p-values %s',fiberName,Cnames{pii}),'fontweight','bold');
        saveas(gcf,sprintf('%s/%s_PostHoc_FDR_Local_pvalues_%s.pdf',savingFolder,fiberName,Cnames{pii}),'pdf');
        close()
    end
    

    disp('Plotting post-hoc FDR significant beta values by property...')
    for Dii=1:nbrDiffusionProperties
        figure()
        hold on
        for pii=2:nbrCovariates
            h(pii-1)=plot(arclength,efitBetas(pii,:,Dii),'Color',color{pii},'LineWidth', 1.25);
            ind=find(posthoc_Lpvals_FDR(:,Dii,pii-1)<=pvalueThreshold);
            scatter(arclength(ind),efitBetas(pii,ind,Dii),25,color{pii},'filled')
        end
        hold off
        xlabel('Arc Length','fontweight','bold');
        ylabel(Dnames{Dii},'fontweight','bold');
        xlim([min(arclength) max(arclength)]);
        xL = get(gca,'XLim');
        line(xL,[0 0],'Color','black'); % line at zero
        legend([h(:)],Cnames(2:nbrCovariates),'Location','SouthEastOutside');
        title(sprintf('%s\nPost-Hoc FDR Significant Beta Values %s %s=%s',fiberName,Dnames{Dii},'\alpha',num2str(pvalueThreshold)),'fontweight','bold');
        clear h;
        saveas(gcf,sprintf('%s/%s_PostHoc_FDR_SigBetas_Property_%s.pdf',savingFolder,fiberName,Dnames{Dii}),'pdf');
        close()
    end

    
    disp('Plotting post-hoc FDR significant beta values by covariate...')
    for pii = 2:nbrCovariates;
        figure()
        hold on
        for Dii=1:nbrDiffusionProperties
            h(Dii)=plot(arclength,efitBetas(pii,:,Dii),'-','Color',color{Dii},'LineWidth', 1.25);
            ind=find(posthoc_Lpvals_FDR(:,Dii,pii-1)<=pvalueThreshold);
            scatter(arclength(ind),efitBetas(pii,ind,Dii),25,color{Dii},'filled')
        end
        hold off
        xlabel('Arc Length','fontweight','bold');
        ylabel('Beta Values','fontweight','bold');
        xlim([min(arclength) max(arclength)]);
        xL = get(gca,'XLim');
        line(xL,[0 0],'Color','black'); % line at zero
        legend([h(:)],Dnames(1:nbrDiffusionProperties),'Location','SouthEastOutside');
        title(sprintf('%s\nPost-Hoc FDR Significant Beta Values %s %s=%s',fiberName,Cnames{pii},'\alpha',num2str(pvalueThreshold)),'fontweight','bold');
        clear h;
        saveas(gcf,sprintf('%s/%s_PostHoc_FDR_SigBetas_Covariate_%s.pdf',savingFolder,fiberName,Cnames{pii}),'pdf');
        close()
    end
    
    
    disp('Plotting post-hoc FDR significant beta values by covariate (y-limited)...')
    for pii = 2:nbrCovariates;
        figure()
        hold on
        for Dii=1:nbrDiffusionProperties
            h(Dii)=plot(arclength,efitBetas(pii,:,Dii),'-','Color',color{Dii},'LineWidth', 1.25);
            ind=find(posthoc_Lpvals_FDR(:,Dii,pii-1)<=pvalueThreshold);
            scatter(arclength(ind),efitBetas(pii,ind,Dii),25,color{Dii},'filled')
        end
        hold off
        xlabel('Arc Length','fontweight','bold');
        ylabel('Beta Values','fontweight','bold');
        xlim([min(arclength) max(arclength)]);
        ylim([ylimMin ylimMax]);
        xL = get(gca,'XLim');
        line(xL,[0 0],'Color','black'); % line at zero
        legend([h(:)],Dnames(1:nbrDiffusionProperties),'Location','SouthEastOutside');
        title(sprintf('%s\nPost-Hoc FDR Significant Beta Values %s  %s=%s (y-limited)',fiberName,Cnames{pii},'\alpha',num2str(pvalueThreshold)),'fontweight','bold');
        saveas(gcf,sprintf('%s/%s_PostHoc_FDR_SigBetas_Covariate_ylimited_%s.pdf',savingFolder,fiberName,Cnames{pii}),'pdf');
        close()
    end   
    
    
end
% End of Post-hoc Hypothesis Test

disp(' ')
disp('End of script')
