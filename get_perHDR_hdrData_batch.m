% working script to get per rHDR data, plot acqusition, experiment, multi -level data
% 210607 Added check of metrics file to skip ROIs with no deliniated synaptic regions
%#ok<*AGROW>
%#ok<*SAGROW>
clearvars; % close all
%=============
multi = 0; % set to 1 if looping through multiple condition/experimental directories (each with acquisitional subdirectories)
ch_psd = 2; p_fld = ['ch',num2str(ch_psd)];
ch_hdr = 1; h_fld = ['ch',num2str(ch_hdr)];
% ch_str = {'Geph','NL2(203)'};
job_str = ''; % optional string to distinguish analysis runs
ratio_cutoff = 0.30; % minor/major axis ratio of PSD region to exclude orthogananl viewed synapses
% TODO: set switch block for above exclusion

if multi == 1
    folderP = uigetdir; foldparts = strsplit(folderP,filesep); parent_name = foldparts{end}; clear foldparts
    dirlist = dir(folderP); dirlist = dirlist([dirlist.isdir]); dirlist(1:2) = [];
    dir_n = size(dirlist,1); folderP = [folderP,filesep];

    hdr_data_multi = struct();
    hdr_data_multi.experiment = {};
    hdr_data_multi.acquisition = {};
    hdr_data_multi.cbc_values = [];
    hdr_data_multi.overlap_frac_pHDR = [];
    hdr_data_multi.overlap_frac_psd = [];
    hdr_data_multi.overlap_class = {};
    hdr_data_multi.rHDR_area = [];
    hdr_data_multi.rHDR_n = [];
    hdr_data_multi.psd_area = [];
    hdr_data_multi.pHDR_area_total = [];
    hdr_data_multi.pHDR_n = [];
    % hdr_data_multi.nnD = [];
else
    folderN = uigetdir; folderN = [folderN,filesep];
    dir_n = 1;
end

%% loop through experiments (dir_n = 1 in the case of single-experiment)
for d = 1:dir_n
    if multi == 1; folderN = [folderP,filesep,dirlist(d).name,filesep]; end
    foldparts = strsplit(folderN,filesep); dirname = foldparts{end-1}; clear foldparts
    sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; sub_n = size(sublist,1);    

    hdr_data = struct();
    hdr_data.acquisition = {};
    hdr_data.cbc_values = [];
    hdr_data.overlap_frac_pHDR = [];
    hdr_data.overlap_frac_psd = [];
    hdr_data.overlap_class = {};
    hdr_data.rHDR_area = [];
    hdr_data.rHDR_n = [];
    hdr_data.psd_area = [];
    hdr_data.pHDR_area_total = [];
    hdr_data.pHDR_n = [];
    % hdr_data.nnD = [];

    for s = 1:sub_n
        subname = sublist(s).name; subpath = fullfile(sublist(s).folder,subname,filesep);
        smlm = dir([subpath,'*SMLM.mat']); load([subpath,smlm.name],'roiData')
        roinames = fieldnames(roiData.ch1); roi_n = length(roinames);
        roi = find(roiData.axis_ratios(:,2) > ratio_cutoff)'; % only loop through non-orthogonal PSDs
        % roi = find(~isnan(roiData.synRegions{1,1}(:,1)) & ~isnan(roiData.synRegions{1,2}(:,1)))';
        hdrdir = [subpath,subname,'_hdrSummary',filesep];
        if ~exist(hdrdir,'dir'); mkdir(hdrdir); end

        acquisition = {};
        cbc_values = [];
        overlap_frac_pHDR = [];
        overlap_frac_psd = [];
        overlap_class = {};
        rHDR_area = [];
        rHDR_n = [];
        psd_area = [];
        pHDR_area_total = [];
        pHDR_n = [];
        % nnD = [];

        for roi = roi
            r_fld = roinames{roi}; titleroot = [subname,'_',roinames{roi}];
            roi_padded = ['roi',num2str(roi,'%02.f')];
            if ~isfield(roiData.(h_fld).(r_fld),'nanocluster') || ...
                    ~isfield(roiData.(h_fld).(r_fld).nanocluster, 'regions') || ...
                    ~isfield(roiData.(h_fld).(r_fld).nanocluster.regions,'region_n') || ...
                    ~isfield(roiData.(p_fld).(r_fld),'nanocluster') || ...
                    ~isfield(roiData.(p_fld).(r_fld).nanocluster,'regions') || ...
                    ~isfield(roiData.(p_fld).(r_fld).nanocluster.regions, 'region_area')
            continue
            end
            
            hdr_n = roiData.(h_fld).(r_fld).nanocluster.regions.region_n;
            cbc_values = ...
                vertcat(cbc_values, cellfun(@mean, roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.cbc(1,:))');
            overlap_frac_pHDR = ...
                vertcat(overlap_frac_pHDR, [roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.hdr_rg{2,:}]');
            overlap_frac_psd = ...
                vertcat(overlap_frac_psd, [roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.hdr_rg{3,:}]');
            overlap_class = ...
                vertcat(overlap_class, roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.hdr_rg(4,:)');
            acquisition = ...
                vertcat(acquisition, repmat({[subname,'_', roi_padded]},[hdr_n 1]));
            rHDR_area = ...
                vertcat(rHDR_area, roiData.(h_fld).(r_fld).nanocluster.regions.region_area');
            rHDR_n = ...
                vertcat(rHDR_n, repmat(hdr_n,[hdr_n 1]));
            psd_area = ...
                vertcat(psd_area, repmat(roiData.synRegions{1,ch_psd}(roi,2), [hdr_n 1]));
            pHDR_area_total = ...
                vertcat(pHDR_area_total, repmat(sum(roiData.(p_fld).(r_fld).nanocluster.regions.region_area), [hdr_n 1]));
            pHDR_n = ...
                vertcat(pHDR_n, repmat(roiData.nanoRegions{1,ch_psd}(roi,1), [hdr_n 1]));
           % nnD = vertcat(nnD, roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.nnD);
        end % roi loop
        roiData.hdr = struct();
        roiData.hdr.cbc_values = cbc_values;
        roiData.hdr.overlap_frac_pHDR = overlap_frac_pHDR;
        roiData.hdr.overlap_frac_psd = overlap_frac_psd;
        roiData.hdr.overlap_class = overlap_class;
        roiData.hdr.rHDR_area = rHDR_area;
        roiData.hdr.rHDR_n = rHDR_n;
        roiData.hdr.psd_area = psd_area;
        roiData.hdr.pHDR_area_total = pHDR_area_total;
        roiData.hdr.pHDR_n = pHDR_n;
        % roiData.hdr.nnD = nnD;
        save([subpath,smlm.name],'roiData','-append')

        hdr_data.acquisition = vertcat(hdr_data.acquisition, acquisition);
        hdr_data.cbc_values = vertcat(hdr_data.cbc_values, cbc_values);
        hdr_data.overlap_frac_pHDR = vertcat(hdr_data.overlap_frac_pHDR, overlap_frac_pHDR);
        hdr_data.overlap_frac_psd = vertcat(hdr_data.overlap_frac_psd, overlap_frac_psd);
        hdr_data.overlap_class = vertcat(hdr_data.overlap_class, overlap_class);
        hdr_data.rHDR_area = vertcat(hdr_data.rHDR_area, rHDR_area);
        hdr_data.rHDR_n = vertcat(hdr_data.rHDR_n, rHDR_n);
        hdr_data.psd_area = vertcat(hdr_data.psd_area, psd_area);
        hdr_data.pHDR_area_total = vertcat(hdr_data.pHDR_area_total, pHDR_area_total);
        hdr_data.pHDR_n = vertcat(hdr_data.pHDR_n, pHDR_n);
        % hdr_data.nnD = vertcat(hdr_data.nnD, nnD);

    end % sub loop (acquisition-level)
        save([folderN,dirname,job_str,'_hdrData.mat'],'hdr_data','ch_hdr','ch_psd')
        
        if multi == 1
            data_n = size(hdr_data.acquisition,1);
            hdr_data_multi.experiment = vertcat(hdr_data_multi.experiment, repmat({dirname},data_n,1));
            hdr_data_multi.acquisition = vertcat(hdr_data_multi.acquisition, hdr_data.acquisition);
            hdr_data_multi.cbc_values = vertcat(hdr_data_multi.cbc_values, hdr_data.cbc_values);
            hdr_data_multi.overlap_frac_pHDR = vertcat(hdr_data_multi.overlap_frac_pHDR, hdr_data.overlap_frac_pHDR);
            hdr_data_multi.overlap_frac_psd = vertcat(hdr_data_multi.overlap_frac_psd, hdr_data.overlap_frac_psd);
            hdr_data_multi.overlap_class = vertcat(hdr_data_multi.overlap_class, hdr_data.overlap_class);
            hdr_data_multi.rHDR_area = vertcat(hdr_data_multi.rHDR_area, hdr_data.rHDR_area);
            hdr_data_multi.rHDR_n = vertcat(hdr_data_multi.rHDR_n, hdr_data.rHDR_n);
            hdr_data_multi.psd_area = vertcat(hdr_data_multi.psd_area, hdr_data.psd_area);
            hdr_data_multi.pHDR_area_total = vertcat(hdr_data_multi.pHDR_area_total, hdr_data.pHDR_area_total);
            hdr_data_multi.pHDR_n = vertcat(hdr_data_multi.pHDR_n, hdr_data.pHDR_n);
            % hdr_data_multi.nnD = vertcat(hdr_data_multi.nnD, hdr_data.nnD);
        end

end %dir loop (experiement-level)
if multi == 1
    save([folderP, parent_name,job_str,'_hdr_data_multi.mat'],'hdr_data_multi','ch_hdr','ch_psd')
end
