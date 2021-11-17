% NOTE: script not needed
%#ok<*AGROW>

clearvars; % close all
%=============
multi = 0; % set to 1 if looping through multiple condition/experimental directories (each with acquisitional subdirectories)
ch_psd = 2; p_fld = ['ch',num2str(ch_psd)];
ch_hdr = 1; h_fld = ['ch',num2str(ch_hdr)];
% ch_str = {'Gaba','Geph'};
ratio_cutoff = 0.30; % minor/major axis ratio of PSD region to exclude orthogananl viewed synapses
% TODO: set switch block for above exclusion

if multi == 1
    folderP = uigetdir; foldparts = strsplit(folderP,filesep); parent_name = foldparts{end}; clear foldparts
    dirlist = dir(folderP); dirlist = dirlist([dirlist.isdir]); dirlist(1:2) = []; 
    dir_n = size(dirlist,1); folderP = [folderP,filesep];    
    
    load([folderP, parent_name,'_psd_data_multi.mat'],'psd_data_multi')    
    exp = unique(psd_data_multi.experiment);
    psd_data_multi.perROI.experiment = {};
    psd_data_multi.perROI.acquisition = {};
    psd_data_multi.perROI.psd_area = [];    
    psd_data_multi.perROI.pHDR_total_area = [];
    psd_data_multi.perROI.pHDR_n = [];
    psd_data_multi.perROI.pHDR_mean_area = [];
else    
    folderN = uigetdir; folderN = [folderN,filesep];   
    dir_n = 1;
end

%% loop through experiments (dir_n = 1 in the case of single-experiment)
for d = 1:dir_n
    if multi == 1; folderN = [folderP,filesep,dirlist(d).name,filesep]; end
    foldparts = strsplit(folderN,filesep); dirname = foldparts{end-1}; clear foldparts
    sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; sub_n = size(sublist,1);    
    load([folderN,dirname,'_psdData.mat'],'psd_data') % experiment-level data
    
    acq_exp = {};
    psd_area_exp = [];    
    pHDR_total_area_exp = [];
    pHDR_n_exp = [];
    pHDR_mean_area_exp = [];
    
    for s = 1:sub_n
        subname = sublist(s).name; subpath = fullfile(sublist(s).folder,subname,filesep);
        smlm = dir([subpath,'*SMLM.mat']); load([subpath,smlm.name],'roiData') % acquisition-level data
        roinames = fieldnames(roiData.ch1); roi_n = length(roinames);
        roi = find(roiData.axis_ratios(:,2) > ratio_cutoff)'; % only loop through non-orthogonal PSDs
        
        acq = cell(roi_n,1);
        psd_area =  NaN(roi_n,1);    
        pHDR_total_area =  NaN(roi_n,1);
        pHDR_n =  NaN(roi_n,1);
        pHDR_mean_area =  NaN(roi_n,1);
        
        for r = roi
            r_fld = roinames{r}; titleroot = [subname,'_',roinames{r}];
            roi_padded = ['roi',num2str(r,'%02.f')];
            if ~isfield(roiData.(p_fld).(r_fld),'nanocluster')|| ...
                    ~isfield(roiData.(p_fld).(r_fld).nanocluster,'regions') || ...
                    ~isfield(roiData.(p_fld).(r_fld).nanocluster.regions, 'region_area'); continue;
            end
            
            acq{r} = [subname,'_',roi_padded];
            psd_area(r) = roiData.synRegions{1,ch_psd}(r,2);
            pHDR_total_area(r) = sum(roiData.(p_fld).(r_fld).nanocluster.regions.region_area);
            pHDR_n(r) = roiData.(p_fld).(r_fld).nanocluster.regions.region_n;
            pHDR_mean_area(r) = pHDR_total_area(r) / pHDR_n(r);
            
        end % roi loop
        
        acq(isnan(psd_area)) = []; 
        psd_area(isnan(psd_area)) = [];
        pHDR_total_area(isnan(pHDR_total_area)) = [];        
        pHDR_n(isnan(pHDR_n)) = [];
        pHDR_mean_area(isnan(pHDR_mean_area)) = [];
        
        acq_exp = vertcat(acq_exp,acq);
        psd_area_exp = vertcat(psd_area_exp, psd_area);
        pHDR_n_exp = vertcat(pHDR_n_exp, pHDR_n);
        pHDR_total_area_exp = vertcat(pHDR_total_area_exp, pHDR_total_area);
        pHDR_mean_area_exp = vertcat(pHDR_mean_area_exp, pHDR_mean_area);
        
    end % subdirectory loop (acquisition-level)
    
    psd_data.perROI.acq = acq_exp;
    psd_data.perROI.psd_area = psd_area_exp;
    psd_data.perROI.pHDR_total_area = pHDR_total_area_exp;
    psd_data.perROI.pHDR_n = pHDR_n_exp;
    psd_data.perROI.pHDR_mean_area = pHDR_mean_area_exp;
    save([folderN,dirname,'_psdData.mat'],'psd_data','-append')
    
    if multi == 1
        roi_n = length(acq_exp);
        psd_data_multi.perROI.experiment = vertcat(psd_data_multi.perROI.experiment,repmat(exp(d),roi_n,1));
        psd_data_multi.perROI.acquisition = vertcat(psd_data_multi.perROI.acquisition, acq_exp);
        psd_data_multi.perROI.psd_area = vertcat(psd_data_multi.perROI.psd_area, psd_area_exp);
        psd_data_multi.perROI.pHDR_total_area = vertcat(psd_data_multi.perROI.pHDR_total_area, pHDR_total_area_exp);
        psd_data_multi.perROI.pHDR_n = vertcat(psd_data_multi.perROI.pHDR_n, pHDR_n_exp);
        psd_data_multi.perROI.pHDR_mean_area = vertcat(psd_data_multi.perROI.pHDR_mean_area, pHDR_mean_area_exp);        
    end
    
end % directory loop (experiment-level)
if multi == 1; save([folderP, parent_name,'_psd_data_multi.mat'],'psd_data_multi','-append'); end