function [xy,uncertainty,sigma,photons,frame] = get_roi_data(roiData,c,roiname)

    xy = roiData.(['ch',num2str(c)]).(roiname).localizations(:,3:4);
    % xy = xy / scale; % temporary rescaling due to wrong pixel-size in ThunderSTORM analysis (191108)
    % load and scale quality metrics
    uncertainty = roiData.(['ch',num2str(c)]).(roiname).localizations(:,10);
    % uncertainty = uncertainty / scale;
    sigma = roiData.(['ch',num2str(c)]).(roiname).localizations(:,5);
    % sigma = sigma / scale;
    photons = roiData.(['ch',num2str(c)]).(roiname).localizations(:,6);
    
    frame = roiData.(['ch',num2str(c)]).(roiname).localizations(:,2);    
end