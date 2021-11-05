% Hub script to call up synaptic cluster analysis functions
%#ok<*SAGROW>
% 200712(kcc) Update from old workflow/evaluation scripts
% 210210 Added rhd-region area minimum
% 210518 added runId

clearvars; close all
%% ===========clustering parameters==============
min_roi_locs = [100 100]; % minimum localizations [ch1 ch2] required for continued analysis 
k = [0 0]; % k= [ch1 ch2] - placeholder for data determined k points value
cutoff = [0.10 0.10]; % cutoff = [ch1 ch2]; cutoff for synaptic region determination (option for range or quantile)
alphaSyn = [100 100]; % set alpha value for determining synaptic-level alphaShape
area_min = [1.0e3 1.5e3]; % minimum region area (nm^2)
k_r = [7 7]; % k points for randomized dataset
rand_itr = 7; % number of randomization iterations
nanoSD = [2.0 2.0]; % scaling factor; mean + (x)*SD for nanocluster cutoff
nano_alpha = [12 12]; % alpha value for delineation of nano-regions
hdr_min = [500 500]; % area minimum for rhd-regions
method_notes = 'syn_cutoffR'; % method for delineation of syn region
% runId = 'Fig_generation';
%----------parameters for optimization-------
% if using, disable roi loop and/or channel loop
% roi = 6; % roi to evaluate
% c = 1; % channel to evaluate
%===============================================
% add function directory to search path
script_path = [fileparts(mfilename('fullpath')),filesep]; addpath([script_path,'functions'])

%% select and load SMLM file with coordinate data and cluster analysis
[file,path] = uigetfile('*.mat','Select SMLM file for analysis'); load([path,file]);
foldparts = strsplit(path,filesep); dirname = foldparts{end-1}; clear foldparts;
rootname = file(1:end-4);

%% load plotting aesthetics; requires function rgb/hex2rgb
aes = define_plot_aesthetics; 

%% get ROI data information, create directory for storing analysis output
roinames = fieldnames(roiData.ch1); roi_n = length(roinames);
roiPdir = [path,dirname(1:11),'ROIdata',filesep];
if ~exist(roiPdir,'dir'); mkdir(roiPdir); end

% occupancy = zeros(roi_n,2);
synRegions = cell(1,2); nanoRegions = cell(1,2); % cell arrays for compiling data
for c = 1:2; synRegions{c} = zeros(roi_n,5); nanoRegions{c} = zeros(roi_n,5); end

%% Loop through ROIs 
for roi = 1:roi_n
    %% get name and position/size of ROI; set up structure,cell arrays for storage of input/output data
    titleroot = [dirname,'_',roinames{roi}];
    roiEdges = roiData.ch1.(roinames{roi}).roiEdges_nm;
    roidir = [roiPdir,titleroot,filesep]; if ~exist(roidir,'dir'); mkdir(roidir); end
    
    % preallocate cell arrays for storage of data
    XY = cell(1,2); titlestr = cell(1,2); XYsyn = cell(1,2);
    synRegion = struct(); nanocluster = struct(); 
    nano = cell(1,2);  XYn0 = cell(1,2); XYn1 = cell(1,2); 
    nano_r = cell(1,2);     
    
    %% channel loop
    for c = 1:2 
        s2 = ['ch',num2str(c)]; % channel string for data structures,titles (for code readability)
        titlestr{c} = [titleroot,s2];              
        
        % [XY{c},~,~,~,~] = get_roi_data(roiData,c,roinames{roi});
        XY{c} = roiData.(s2).(roinames{roi}).localizations(:,2:3);
        if length(XY{c}) < min_roi_locs(c)            
            synRegions{c}(roi,:) = NaN;
            nanoRegions{c}(roi,:) = NaN;
            continue
        end
        
        k(c) = ceil(length(XY{c})/50); [~,D] = knnsearch(XY{c},XY{c},'K',k(c)); 
        mNND = mean(D(:,k(c))); sdNND = std(D(:,k(c)));
        radius = mNND + 2*sdNND; 
        synRegion.(s2).params.k = k(c); synRegion.(s2).params.cutoff = cutoff(c);  
        synRegion.(s2).params.radius = radius;
        
        %% define synaptic/object regions        
        % calcuate local density    
        ld = determine_localDensity(XY{c},radius); % comment out for plotting, 
        % ld = determine_localDensity(XY{c},radius,aes,titlestr{c},roiEdges); % comment out for no plotting
        
        % syn_cutoff = round(quantile(ld,cutoff(c)));
        syn_cutoff = round(min(ld) + range(ld)*cutoff(c)); 
        syn = ld > syn_cutoff; XYsyn{c} = XY{c}(syn,:);   
        % Deliniate region boundary based on LD determinaion
        syn_region = create_synapticBoundary(XYsyn{c},area_min(c),alphaSyn(c));         
        % record data in structure
        synRegion.(s2).ldROI = ld; synRegion.(s2).xy = XYsyn{c}; synRegion.(s2).regions = syn_region;
        if syn_region.region_n == 0
            synRegions{c}(roi,:) = NaN;
            nanoRegions{c}(roi,:) = NaN;
            roiData.(s2).(roinames{roi}).synRegion = synRegion.(s2);
            continue 
        end
        
        %%  randomize localizations in synaptic region; calculate local density of r_syn
        % loop through randomization to increase robustness of cutoff
        radius = zeros(rand_itr,1); cutoff_nano = zeros(rand_itr,1);
        for r = 1:rand_itr
            r_syn = randomize_synRegion(XYsyn{c},syn_region.shp); %TODO(200425): rewrite functions to account for multiple regions
            [~,D] = knnsearch(r_syn,r_syn,'K',k_r(c)); mNND = mean(D(:,k_r(c))); sdNND = std(D(:,k_r(c)));
            radius(r,1) = mNND + 2*sdNND;       
            %%  calculate LD in randomized syn_region      
            ld_r = determine_localDensity(r_syn,radius(r));
            cutoff_nano(r) = (mean(ld_r) + nanoSD(c)*std(ld_r)); 
        end
        cutoff_nano = round(mean(cutoff_nano)); radius = mean(radius);
        % record last iteration of randomization, for plotting purposes  
        synRegion.(s2).rand.xy = r_syn;        
        synRegion.(s2).rand.ld = ld_r; 
         
        nanocluster.(s2).params.radius = radius; nanocluster.(s2).params.cutoff = cutoff_nano;
        ld = determine_localDensity(XYsyn{c},radius); synRegion.(s2).ld = ld;
          
        % segergate nanocluster localizations
        nano{c} = ld > cutoff_nano; XYn1{c} = XYsyn{c}(nano{c},:); XYn0{c} = XYsyn{c}(~nano{c},:);
        nano_r{c} = ld_r > cutoff_nano; r_syn_n1 = r_syn(nano_r{c},:); r_syn_n0 = r_syn(~nano_r{c},:);
        ldr1 = ld_r(nano_r{c},:); ldr0 = ld_r(~nano_r{c},:);        
        
        ld1 = ld(nano{c},:); ld0 = ld(~nano{c},:); % LD data for each class of syn localizations (n0 versu n1)
        
        % plot coordinate scatter with Local density heat-map
        boxstr = ['nano_cutoff: ',num2str(round(cutoff_nano))];
        h1 = plot_nanocluster(XY{c},XYn0{c},XYn1{c},ld0,ld1,roiEdges,aes);
        grid(h1.Children(5),'on'); title(h1.Children(5),[titlestr{c},' nano'],'Interpreter','none')
        annotation('textbox',[0.25 0.1 0.1 0.1],'String',boxstr,'Interpreter','none','EdgeColor','none');        
        savefig(h1,[roidir,titlestr{c},'_nanoclus.fig']); saveas(h1,[roidir,titlestr{c},'_nanoclus.png'])
        close(h1)
        
                % Save results in roiData structure (TODO: remove redundancies)
        nanocluster.(s2).nano = nano{c}; nanocluster.(s2).n1.xy = XYn1{c}; nanocluster.(s2).n0.xy = XYn0{c};        
        nanocluster.(s2).n1.ld = ld1; nanocluster.(s2).n0.ld = ld0;        
        roiData.(s2).(roinames{roi}).synRegion = synRegion.(s2);
        roiData.(s2).(roinames{roi}).nanocluster = nanocluster.(s2); 
        
        %% deliniate high-density regions
               
        if numel(XYn1{c}) ~= 0
            % idx = dbscan(XYn1{c},radius,cutoff_nano);
%             idx = dbscan(XYn1{c},radius,round(cutoff_nano/2));
%             
            % determine alphaShape to deliniate nano-regions
            % shp = alphaShape(xy_nR(:,1),xy_nR(:,2),nano_alpha(c)); 
            shp = alphaShape(XYn1{c},nano_alpha(c),'HoleThreshold',2000,'RegionThreshold',hdr_min(c));            
            N = numRegions(shp); A = area(shp,1:N);
            if N ~= 0
                idx = inShape(shp,XYn1{c});
                xy_nR = XYn1{c}(idx >0,:); ld_nR = ld1(idx > 0);            

                roiData.(s2).(roinames{roi}).nanocluster.regions.xy = xy_nR;
                roiData.(s2).(roinames{roi}).nanocluster.regions.ld = ld_nR;
                roiData.(s2).(roinames{roi}).nanocluster.regions.dbscan = idx;
                roiData.(s2).(roinames{roi}).nanocluster.regions.shp = shp;
                roiData.(s2).(roinames{roi}).nanocluster.regions.region_n = N;
                roiData.(s2).(roinames{roi}).nanocluster.regions.region_area = A;

                %% TODO: add column headers to datamatrix
                % region_n,region_area,loc#,mean_ld,std_ld
                nanoRegions{c}(roi,1) = roiData.(s2).(roinames{roi}).nanocluster.regions.region_n;
                nanoRegions{c}(roi,2) = sum(roiData.(s2).(roinames{roi}).nanocluster.regions.region_area);
                nanoRegions{c}(roi,3) = length(xy_nR);
                nanoRegions{c}(roi,4) = mean(ld_nR);
                nanoRegions{c}(roi,5) = std(ld_nR);

                % plot_nanoRegions(XY,LD,shp,cmap,clr,syn,clr2,sz,roiEdges,titlestr)
                h2 = plot_nanoRegions(xy_nR,ld_nR,shp,aes.cmap1,aes.clr_syn{4},syn_region.shp,aes.clr_syn{3},aes.sz,roiEdges,titlestr{c});
                savefig(h2,[roidir,titlestr{c},'_nanoRegions.fig']); saveas(h2,[roidir,titlestr{c},'_nanoRegions.png'])        
                close(h2)
            else; nanoRegions{c}(roi,:) = NaN;
            end
        else; nanoRegions{c}(roi,:) = NaN;            
        end
        % region_n,region_area,loc#,mean_ld,std_ld
        synRegions{c}(roi,1) = roiData.(s2).(roinames{roi}).synRegion.regions.region_n;
        synRegions{c}(roi,2) = sum(roiData.(s2).(roinames{roi}).synRegion.regions.region_area);
        synRegions{c}(roi,3) = length(XYsyn{c}); % TODO: directly access roiData structure
        synRegions{c}(roi,4) = mean(roiData.(s2).(roinames{roi}).synRegion.ld);
        synRegions{c}(roi,5) = std(roiData.(s2).(roinames{roi}).synRegion.ld);
                
    end % channel loop
   
    %% plot synaptic boundaries, overlayed   
    h9 = plot_regionBoundaries(XY,roiEdges,synRegion,aes.clr_syn,aes.sz,titleroot);
    savefig(h9,[roidir,titleroot,'_regions.fig']); saveas(h9,[roidir,titleroot,'_regions.png'])
    close(h9)
    
end % roi loop
% write global cluster parameters to roiData structure
roiData.clustParams.synMethod = method_notes;
roiData.clustParams.syn_cutoff = cutoff;
roiData.clustParams.syn_alpha = alphaSyn;
roiData.clustParams.area_min = area_min;
roiData.clustParams.k_rand = k_r;
roiData.clustParams.nanoSD = nanoSD;
roiData.clustParams.nanoAlpha = nano_alpha;

roiData.synRegions = synRegions;
roiData.nanoRegions = nanoRegions;

save([path,file],'roiData','-append')
