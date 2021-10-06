function [syn] = create_synapticBoundary(XY,regionTh,a)    
    
    syn = struct();    
    for c = 2:-1:1        
        shp = alphaShape(XY,a,'HoleThreshold',5000,'RegionThreshold',regionTh); 
        % plot(shp,'FaceColor',clr{c},'FaceAlpha',0.3,'EdgeColor',clr{c},'EdgeAlpha',0.3);
        syn.shp = shp;
        syn.region_n = numRegions(shp);
        syn.region_area = area(shp,1:numRegions(shp));
        syn.region_perimeter = perimeter(shp,1:numRegions(shp));
    end
    
end