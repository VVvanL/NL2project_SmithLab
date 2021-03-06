% prototyping script to segregate enface synaptic data (from 2D STORM images)
clearvars
% add function directory to search path
script_path = [fileparts(mfilename('fullpath')),filesep]; addpath([script_path,'functions'])

%% select and load SMLM file with coordinate data and density analysis
[file,path] = uigetfile('*.mat','Select SMLM file for analysis'); load([path,file],'roiData');
foldparts = strsplit(path,filesep); dirname = foldparts{end-1}; clear foldparts;
roinames = fieldnames(roiData.ch1); roi_n = length(roinames);

csvdir = [path,dirname(1:11),'csvFiles',filesep];
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
% roiData.ellipse_t = ellipse_t;
roiData.axis_ratios = ratio;
save([path,file],'roiData','-append')
ratioT = array2table(ratio,'VariableNames',{'ch1','ch2'});
writetable(ratioT,[csvdir,dirname,'_axis_ratios.csv'])


