function h = plot_regionBoundaries(XY,roiEdges,region,clr,sz,title_str)

    normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
    aspect = normEdges(2) / normEdges(4);
    
    h = figure; hold on
    
    channels = fieldnames(region); % ch_n = length(channels);
    for c = 1:2
        xy = XY{c} - [roiEdges(1),roiEdges(3)];
        scatter(xy(:,1),xy(:,2),sz,clr{c},'filled','MarkerFaceAlpha',0.60);
    end
    for c = 1:length(channels)        
        if region.(channels{c}).regions.region_n ~= 0
            shp = region.(channels{c}).regions.shp;
            shp.Points = shp.Points - [roiEdges(1),roiEdges(3)];
            plot(shp,'FaceColor',clr{c},'FaceAlpha',0.50,'EdgeColor','none');
        end        
    end
    axis ij; axis(normEdges); pbaspect([aspect 1 1])
    xlabel('x(nm)'); ylabel('y(nm)'); grid on
    title([title_str,'_regions'],'Interpreter','none')
end