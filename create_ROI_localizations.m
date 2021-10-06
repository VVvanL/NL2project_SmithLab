% Working script to load ROI demarkation from ROIset.zip file; groups localizations by ROI
% 190205 Added option to load filtered or unfiltered localizations
% 191106 format overhaul to mesh with SMLM workflow in progress
% current pxl_xy value based on select ROI in SMLM workflow generated Gauss image

clearvars; close all

%% manually select localization .mat file and ROIset.zip folder
[matfile,matpath] = uigetfile('*.mat','Select .mat file with localization data...');
load([matpath,matfile]);
[roifile,roipath] = uigetfile('*.*','Select ROI file for import...');
sROI = ReadImageJROI([roipath,roifile]); roi_n = size(sROI,2);

s = data;
% retrive pixel size for SR image (used to generate ROIs for downstream analysis)
pxl_xy = p.image_gen.pixelsize_g;
% pxl_xy = 100; 
ch_n = p.acq.nchannels; 
%% loop through channels/ROI list to generate roi-specific localization sets, data saved in cell array ROIdata
roiData = struct;
for c = 1:ch_n
    s2 = ['ch',num2str(c)]; % channel fieldname, assigned here to improve downstream readability    
    for r = 1:roi_n
        s3 = ['roi',num2str(r)];
        roiData.(s2).(s3).colheaders = s.(s2).colheaders;        
        xmin = sROI{r}.vnRectBounds(2)*pxl_xy; xmax = sROI{r}.vnRectBounds(4)*pxl_xy; % for code readability
        ymin = sROI{r}.vnRectBounds(1)*pxl_xy; ymax = sROI{r}.vnRectBounds(3)*pxl_xy;
        ROIedges = [xmin xmax ymin ymax];  % ROIwh for plotting purposes
        xyLgc = (s.(s2).localizations(:,3) > ROIedges(1) & s.(s2).localizations(:,3) < ROIedges(2) ...
            & s.(s2).localizations(:,4) > ROIedges(3) & s.(s2).localizations(:,4) < ROIedges(4));
        roiData.(s2).(s3).localizations = s.(s2).localizations(xyLgc,:);
        roiData.(s2).(s3).vnRectBounds = sROI{r}.vnRectBounds;
        roiData.(s2).(s3).roiEdges_nm = ROIedges;        

    end; clear r xmin ymin xmax ymax xyLgc ROIedges
end
save([matpath,matfile],'roiData','-append')
% write ROI localization table in ThunderSTORM format
