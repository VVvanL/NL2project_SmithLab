% working script to get per rHDR data, plot acqusition, experiment, multi -level data
%#ok<*AGROW>
%#ok<*SAGROW>
clearvars; % close all
%=============
multi = 0; % set to 1 if looping through multiple condition/experimental directories (each with acquisitional subdirectories)
ch_psd = 2; p_fld = ['ch',num2str(ch_psd)];
ch_hdr = 1; h_fld = ['ch',num2str(ch_hdr)];
% ch_str = {'Geph','NL2(203)'};
ratio_cutoff = 0.30; % minor/major axis ratio of PSD region to exclude orthogananl viewed synapses
% TODO: set switch block for above exclusion

if multi == 1
    folderP = uigetdir; foldparts = strsplit(folderP,filesep); parent_name = foldparts{end}; clear foldparts
    dirlist = dir(folderP); dirlist = dirlist([dirlist.isdir]); dirlist(1:2) = []; 
    dir_n = size(dirlist,1); folderP = [folderP,filesep];
    
    psd_data_multi = struct();
    psd_data_multi.experiment = {};
    psd_data_multi.acquisition = {};
    psd_data_multi.psd_area = [];
    psd_data_multi.pHDR_area = [];
    psd_data_multi.pHDR_total_area = [];
    psd_data_multi.pHDR_n = [];
else    
    folderN = uigetdir; folderN = [folderN,filesep];   
    dir_n = 1;
end

%% loop through experiments (dir_n = 1 in the case of single-experiment)
for d = 1:dir_n
    if multi == 1; folderN = [folderP,filesep,dirlist(d).name,filesep]; end
    foldparts = strsplit(folderN,filesep); dirname = foldparts{end-1}; clear foldparts 
    sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; sub_n = size(sublist,1);
    
    psd_data = struct();
    psd_data.acquisition = {};
    psd_data.psd_area = [];
    psd_data.pHDR_area = [];
    psd_data.pHDR_total_area = [];
    psd_data.pHDR_n = [];
    
    for s = 1:sub_n    
        subname = sublist(s).name; subpath = fullfile(sublist(s).folder,subname,filesep);
        smlm = dir([subpath,'*SMLM.mat']); load([subpath,smlm.name],'roiData')
        roinames = fieldnames(roiData.ch1); roi_n = length(roinames); 
        roi = find(roiData.axis_ratios(:,2) > ratio_cutoff)'; % only loop through non-orthogonal PSDs
        hdrdir = [subpath,subname,'_hdrSummary',filesep];
        if ~exist(hdrdir,'dir'); mkdir(hdrdir); end
        
        acquisition = {};
        psd_area = [];
        pHDR_area = [];
        pHDR_total_area = [];
        pHDR_n = [];
        
        for roi = roi
            r_fld = roinames{roi}; titleroot = [subname,'_',roinames{roi}];
            roi_padded = ['roi',num2str(roi,'%02.f')];
            if ~isfield(roiData.(p_fld).(r_fld),'nanocluster') || ...
                    ~isfield(roiData.(p_fld).(r_fld).nanocluster,'regions') || ...
                    ~isfield(roiData.(p_fld).(r_fld).nanocluster.regions, 'region_area'); continue;
            end
            hdr_n = roiData.(p_fld).(r_fld).nanocluster.regions.region_n;
            
            acquisition = ...
                vertcat(acquisition, repmat({[subname,'_',roi_padded]},[hdr_n 1]));
            psd_area = ...
                vertcat(psd_area, repmat(roiData.synRegions{1,ch_psd}(roi,2), [hdr_n 1]));
            pHDR_area = ...
                vertcat(pHDR_area, roiData.(p_fld).(r_fld).nanocluster.regions.region_area');
            pHDR_total_area = ...
                vertcat(pHDR_total_area, repmat(sum(roiData.(p_fld).(r_fld).nanocluster.regions.region_area), [hdr_n 1]));
            pHDR_n = ...
                vertcat(pHDR_n, repmat(hdr_n,[hdr_n 1]));            
        end % roi-loop
        roiData.psd = struct();        
        roiData.psd.psd_area = psd_area;
        roiData.psd.pHDR_area = pHDR_area;
        roiData.psd.pHDR_total_area = pHDR_total_area;
        roiData.psd.pHDR_n = pHDR_n;
        save([subpath,smlm.name],'roiData','-append')
        
        psd_data.acquisition = vertcat(psd_data.acquisition, acquisition);
        psd_data.psd_area = vertcat(psd_data.psd_area, psd_area);
        psd_data.pHDR_area = vertcat(psd_data.pHDR_area, pHDR_area);
        psd_data.pHDR_total_area = vertcat(psd_data.pHDR_total_area, pHDR_total_area);
        psd_data.pHDR_n = vertcat(psd_data.pHDR_n, pHDR_n);
        
    end % sub-loop (acquisition-level)
    save([folderN,dirname,'_psdData.mat'],'psd_data','ch_hdr','ch_psd')
    
    if multi == 1
        data_n = size(psd_data.acquisition,1);
        psd_data_multi.experiment = vertcat(psd_data_multi.experiment, repmat({dirname},data_n,1));
        psd_data_multi.acquisition = vertcat(psd_data_multi.acquisition, psd_data.acquisition);
        psd_data_multi.psd_area = vertcat(psd_data_multi.psd_area, psd_data.psd_area);
        psd_data_multi.pHDR_area = vertcat(psd_data_multi.pHDR_area, psd_data.pHDR_area);
        psd_data_multi.pHDR_total_area = vertcat(psd_data_multi.pHDR_total_area, psd_data.pHDR_total_area);
        psd_data_multi.pHDR_n = vertcat(psd_data_multi.pHDR_n, psd_data.pHDR_n);
    end
       
end % dir loop (experiment-level)
if multi == 1
    save([folderP, parent_name,'_psd_data_multi.mat'],'psd_data_multi','ch_hdr','ch_psd')
end