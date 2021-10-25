% Call function, generate scatter plots for coordinate-based colocalization algorithm 
% TODO: remove nano-region only cbc calculation

clearvars; close all
% add function directory to search path
script_path = [fileparts(mfilename('fullpath')),filesep]; addpath([script_path,'functions'])
%% set up parameters for CBC
Rmax = 30; % max radius in nm 
r_step = 2; % radius step size (nm)
% check if r_max / r_step is integer, if not adjust r_max
if ~isinteger(Rmax / r_step); Rmax = ceil(Rmax/r_step) * r_step; end   
%----------parameters for optimization-------
% if using, disable roi loop 
% roi = [1,3:20];

%% select and load SMLM file with coordinate data and cluster analysis
[file,path] = uigetfile('*.mat','Select SMLM file for analysis'); load([path,file],'roiData');
foldparts = strsplit(path,filesep); dirname = foldparts{end-1}; clear foldparts;
roinames = fieldnames(roiData.ch1); roi_n = length(roinames);
roiPdir = [path,dirname,'_ROIdata',filesep];
if ~exist(roiPdir,'dir'); mkdir(roiPdir); end

%% load plotting aesthetics; requires function rgb/hex2rgb
aes = define_plot_aesthetics; 

for roi = 1:roi_n
        % check if synRegions have been deliniated for both channels: if not, skip analysis
    if isnan(roiData.synRegions{1,1}(roi,1)) || isnan(roiData.synRegions{1,2}(roi,1))
        continue
    end
    % get name and position/size of ROI; set up structure,cell arrays for storage of input/output data
    titleroot = [dirname,'_',roinames{roi}];
    roiEdges = roiData.ch1.(roinames{roi}).roiEdges_nm;
    roidir = [roiPdir,titleroot,filesep]; if ~exist(roidir,'dir'); mkdir(roidir); end
    
    AB = cell(3,2); titlestr = cell(1,2); % Storage of different localization sets from the data
    headersAB = {'synRegion experimental','synRegion randomized','nano-region experimental'};
    nano = zeros(1,2); % flag for presence of nano-regions in channel
    for c = 1:2  % channel loop
        s2 = ['ch',num2str(c)]; % channel string for data structures,titles (for code readability)
        titlestr{c} = [titleroot,s2];         
        AB{1,c} = roiData.(s2).(roinames{roi}).synRegion.xy; % synRegion experimental
        AB{2,c} = roiData.(s2).(roinames{roi}).synRegion.rand.xy; % synRegion randomized
        if isfield(roiData.(s2).(roinames{roi}).nanocluster,'regions')
            if isfield(roiData.(s2).(roinames{roi}).nanocluster.regions,'xy')  && ...
                    numel(roiData.(s2).(roinames{roi}).nanocluster.regions.xy) ~= 0
                AB{3,c} = roiData.(s2).(roinames{roi}).nanocluster.regions.xy; % nano-region experimental
                nano(c) = 1; % else; nano(c) = 0;
            end
        end        
    end
 
        C = cell(3,2); % run combinations: Exp-Exp(syn) rand-rand(syn); exp-rand(syn); nano-nano; nano-rand(syn)
        headersC = {'syn-syn','rand-rand','syn-rand'};
    
    for ab = 1:size(C,1)
        if ab < 3; rw = [ab ab]; elseif ab == 3; rw = [1 2]; elseif ab == 4; rw = [3 3]; else; rw = [3 2]; end 
        for c = 1:2
            if c == 1; a = 1; b = 2; else; a = 2; b = 1; end            
            A = AB{rw(1),a}; B = AB{rw(2),b};
            C{ab,c} = CBC(A,B,Rmax,r_step);             
        end    
    end
    
    % add cbc data to roiData structure
    roiData.cbc.(roinames{roi}).AB = AB;
    roiData.cbc.(roinames{roi}).rowlabelsAB = headersAB;
    roiData.cbc.(roinames{roi}).C = C;
    roiData.cbc.(roinames{roi}).rowlabelsC = headersC;         
 
    syn_region = struct(); % get synRegion for generation of scatterplots
    for c = 1:2
        s2 = ['ch',num2str(c)];    
        syn_region.(s2) = roiData.(s2).(roinames{roi}).synRegion.regions.shp;        
    end

end
% save cbc parameters to roiData structure
roiData.cbc.Params.Rmax = Rmax; roiData.cbc.Params.r_step = r_step;
save([path,file],'roiData','-append')



