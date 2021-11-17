 % working script to write summary HDR data to .csv file(s)
% Note: currently works with parent folder (multi) directory structure only
clearvars; % close all
%=============
% multi = 0; % set to 1 if looping through multiple condition/experimental directories (each with acquisitional subdirectories)
% %
% if multi == 1
%     folderP = uigetdir; foldparts = strsplit(folderP,filesep); parent_name = foldparts{end}; clear foldparts
%     dirlist = dir(folderP); dirlist = dirlist([dirlist.isdir]); dirlist(1:2) = [];
%     dir_n = size(dirlist,1); folderP = [folderP,filesep];    
% else
    folderN = uigetdir; folderN = [folderN,filesep];
    dir_n = 1;
% end

%% loop through experiments (dir_n = 1 in the case of single-experiment)
for d = 1:dir_n
    % if multi == 1; folderN = [folderP,filesep,dirlist(d).name,filesep]; end
    foldparts = strsplit(folderN,filesep); dirname = foldparts{end-1}; clear foldparts
    % sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; sub_n = size(sublist,1);
    % write HDR data to .csv table
    load([folderN,dirname,'_hdrData.mat'],'hdr_data')
    hdr_perROI_T = struct2table(hdr_data.perROI);
    writetable(hdr_perROI_T,[folderN,dirname,'_hdrTable_perROI.csv'])
    
    hdr_temp = rmfield(hdr_data,{'perROI'});
    hdr_T = struct2table(hdr_temp);
    writetable(hdr_T,[folderN,dirname,'_hdrTable_perObj.csv'])

    %write PSD data to .csv table
    load([folderN,dirname,'_psdData.mat'],'psd_data')
    psd_perROI_T = struct2table(psd_data.perROI);
    writetable(psd_perROI_T,[folderN,dirname,'_psdTable_perROI.csv'])
    
    psd_temp = rmfield(psd_data,{'perROI'});
    psd_T = struct2table(hdr_temp);
    writetable(psd_T,[folderN,dirname,'_psdTable_perObj.csv'])
    
end





