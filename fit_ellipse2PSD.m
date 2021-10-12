% prototyping script to segregate enface synaptic data (from 2D STORM images)
clearvars

multi = 0; % set to 1 if looping through multiple condition/experimental directories (each with acquisitional subdirectories)

if multi == 1
    folderP = uigetdir; foldparts = strsplit(folderP,filesep); parent_name = foldparts{end}; clear foldparts
    dirlist = dir(folderP); dirlist = dirlist([dirlist.isdir]); dirlist(1:2) = []; 
    dir_n = size(dirlist,1); folderP = [folderP,filesep];
else    
    folderN = uigetdir; folderN = [folderN,filesep];   
    dir_n = 1;
end

for d = 1:dir_n
    if multi == 1; folderN = [folderP,filesep,dirlist(d).name,filesep]; end
    foldparts = strsplit(folderN,filesep); dirname = foldparts{end-1}; clear foldparts 
    sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; sub_n = size(sublist,1);     

    for s = 1:sub_n
        subname = sublist(s).name; subpath = fullfile(sublist(s).folder,subname,filesep);
        smlm = dir([subpath,'*SMLM.mat']); load([subpath,smlm.name],'roiData')
        roinames = fieldnames(roiData.ch1); roi_n = length(roinames);

        csvdir = [subpath,subname,'_csvFiles',filesep];
        if ~exist(csvdir,'dir'); mkdir(csvdir); end

        ellipse_t = struct(); ratio = NaN(roi_n,2);
        for roi = 1:roi_n    
            r_fld = roinames{roi};        
            for c = 1:2
                c_fld = ['ch',num2str(c)];
                if ~isfield(roiData.(c_fld).(r_fld),'synRegion'); continue; end
                xy = roiData.(c_fld).(r_fld).synRegion.xy;
                ellipse_t.(r_fld).(c_fld) = fit_ellipse(xy(:,1), xy(:,2));
                if numel(ellipse_t.(r_fld).(c_fld).short_axis) ~= 0
                    ratio(roi,c) = ...
                        ellipse_t.(r_fld).(c_fld).short_axis / ellipse_t.(r_fld).(c_fld).long_axis;
                end
            end
        end
        roiData.ellipse_t = ellipse_t;
        roiData.axis_ratios = ratio;
        save([subpath,smlm.name],'roiData','-append')
        ratioT = array2table(ratio,'VariableNames',{'ch1','ch2'});
        writetable(ratioT,[csvdir,subname,'_axis_ratios.csv'])
    end % subdir loop (acquisition-level)

end % dir loop (experiment-level)