% working script to run high density-region analysis on analyzed datasets
% customized for Gaba/Gephryn datasets
% TODO: ammend to gather key statistics?
clearvars; close all

c_psd = 2; c_rcpt = 1; % channels for psd/receptors respectively
overlap_thrsh = 0.23; % Threshold for labeling hdrs as "overlaping"
% roi = 7; % can be single roi or range of rois; need to set roi loop as: 'for roi = roi' (line 33)
 
%% select and load SMLM file with coordinate data and density analysis
[file,path] = uigetfile('*.mat','Select SMLM file for analysis'); load([path,file],'roiData');
foldparts = strsplit(path,filesep); dirname = foldparts{end-1}; clear foldparts;

%% get ROI data information, 
roinames = fieldnames(roiData.ch1); roi_n = length(roinames);
roiPdir = [path,dirname,'_ROIdata',filesep];
n_alpha = roiData.clustParams.nanoAlpha;  % alpha value used to calcluate high-density regions(nano-regions)

for roi = 1:roi_n
    % check if synRegions have been deliniated for both channels: if not, skip analysis
    if isnan(roiData.synRegions{1,1}(roi,1)) || isnan(roiData.synRegions{1,2}(roi,1)) 
        continue
    end       

    titleroot = [dirname,'_',roinames{roi}]; r_fld = roinames{roi}; 
    roiEdges = roiData.ch1.(roinames{roi}).roiEdges_nm;
    roidir = [roiPdir,titleroot,filesep];            

    if ~isnan(roiData.nanoRegions{1,c_rcpt}(roi,1))
        %% Get data for hdr analysis          
        nano_rg = cell(1,2); XYsyn = cell(1,2); XYnr = cell(1,2);
        for c = 1:2
            c_fld = ['ch',num2str(c)];                                
            XYsyn{c} = roiData.(c_fld).(r_fld).synRegion.xy;
            if ~isnan(roiData.nanoRegions{1,c}(roi,1))
                nano_rg{c} = roiData.(c_fld).(r_fld).nanocluster.regions.shp;                    
            end
        end
        psd = roiData.(['ch',num2str(c_psd)]).(r_fld).synRegion.regions.shp;
        cbc = roiData.cbc.(r_fld).C; cbctitle = {'exp-exp',[],'exp-rand'};
        %% get hdRegion data (overlap, catagory, cbc values).  Also catagorize localizations
        % currently set to only retrieve receptor data vis-a-vis PSD (gephryin)            
        % data = get_hdRegion_data(XY, psd, nano, a, C, threshold)
        if ~isnan(roiData.nanoRegions{1,c_psd}(roi,1))
            data_hdRg = get_hdRegion_data(XYsyn, psd, nano_rg, n_alpha, cbc, overlap_thrsh,c_psd,c_rcpt); 
        else
            data_hdRg = get_R_hdRegion_data(XYsyn, psd, nano_rg, n_alpha, cbc, overlap_thrsh, c_rcpt);                
        end                                
    else
        XYsyn = roiData.(['ch',num2str(c_rcpt)]).(r_fld).synRegion.xy;
        psd = roiData.(['ch',num2str(c_psd)]).(r_fld).synRegion.regions.shp;
        data_hdRg = get_inPSD_data(XYsyn, psd);
    end % receptor hdr conditional 
    roiData.(['ch',num2str(c_rcpt)]).(r_fld).nanocluster.regions.hdr_data = data_hdRg; 

end % roi loop
save([path,file],'roiData','-append')


