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


disp('Loading covariate file...')
$matlabSubMatrixInputFile$
designdata = [ ones( size( data2, 1 ), 1 ) data2 ]; % intercept + covariates

Cnames = cell( nbrCovariates, 1 );
$covariates$

disp('Loading diffusion file...')
$diffusionFiles$
$diffusionProperties$

disp('Processing arclength...')
% ARCLENGTH
% Get arclength from input file
arclength = dataFiber1All( :, 1 ); % take first column => arclength from dtiCC_statCLP fiber file

% Creating (x,y,z) coordinates
CC_data = [ arclength zeros( size( arclength, 1 ), 1 ) zeros( size( arclength, 1 ), 1 ) ];

nofeatures = size( diffusionFiles, 1 );
[ NoSetup, arclength_allPos, Xdesign, Ydesign ] = MVCM_read( CC_data, designdata, diffusionFiles, nofeatures );
nbrSubjects = NoSetup( 1 );	% No of subjects
nbrArclengths = NoSetup( 2 ); % No of arclengths
nbrCovariates = NoSetup( 3 ); % No of covariates (including intercept)
nbrDiffusionProperties = NoSetup( 4 );	% No of diffusion properties = 1



%% 2. fit a model using local polynomial kernel smoothing
disp(' ')
disp('2. Betas')
disp('Calculating betas...')
[ mh ] = MVCM_lpks_wob( NoSetup, arclength_allPos, Xdesign, Ydesign );
[ efitBetas, efitBetas1, InvSigmats, efitYdesign ] = MVCM_lpks_wb1( NoSetup, arclength_allPos, Xdesign, Ydesign, mh );

disp('Saving betas...')
for i = 1:nbrDiffusionProperties
    csvwrite(sprintf('%s/%s_Betas_%s.csv', savingFolder, fiberName, Dnames{Dii}),efitBetas(:,:,Dii));
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
        %individual and global statistics calculation
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

    disp('Correcting omnibus local p-values...')
    %% correct local p-values with FDR
    % this corrects the local p-values for multiple comparisons
    Lpvals_FDR = zeros( size( Lpvals ) );
    for i = 1:( nbrCovariates-1 )
        Lpvals_FDR( :, i ) = myFDR( Lpvals( :, i ));
    end
    
    disp('Saving omnibus FDR local p-values...')
    csvwrite( sprintf( '%s/%s_Omnibus_FDR_Local_pvalues.csv', savingFolder, fiberName), Lpvals_FDR );
    
    
    disp('Calculating omnibus covariate confidence bands...')
    [Gvalue] = MVCM_cb_Gval( arclength_allPos, Xdesign, ResYdesign, InvSigmats, mh, nbrPermutations );
    [CBands] = MVCM_CBands( nbrSubjects, confidenceBandsThreshold, Gvalue, efitBetas, zeros( size( ebiasBetas ) ) );

    disp('Saving omnibus covariate confidence bands...')
    for Dii=1:nbrDiffusionProperties
        csvwrite( sprintf( '%s/%s_Omnibus_ConfidenceBands_%s.csv', savingFolder, fiberName, Dnames{Dii} ), CBands(:,:,Dii) );
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
    %% correct posthoc test local p-values with FDR
    % this corrects the posthoc local p-values for multiple comparisons
    posthoc_Lpvals_FDR = zeros( size( posthoc_Lpvals ) );
    for Dii = 1:nbrDiffusionProperties
        for pii = 1:( nbrCovariates-1 )
            posthoc_Lpvals_FDR( :, Dii, pii ) = myFDR( posthoc_Lpvals( :, Dii, pii ) );
        end
    end
    
    disp('Saving post-hoc FDR local p-values...')
    for Dii = 1:nbrDiffusionProperties
        csvwrite( sprintf( '%s/%s_PostHoc_FDR_Local_pvalues_%s.csv', savingFolder, fiberName, Dnames{Dii} ), posthoc_Lpvals_FDR( :, Dii, : ) );
    end


end
% End of Post-hoc Hypothesis Test

disp(' ')
disp('End of script')
