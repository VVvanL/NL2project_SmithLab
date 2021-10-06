function h =  plot_nanoRegions(XY,LD,shp,cmap,clr,syn,clr2,sz,roiEdges,titlestr)  


    % normalize localizations to roi boundaries
    xy = XY - [roiEdges(1),roiEdges(3)]; % xysyn = XYsyn - [roiEdges(1),roiEdges(3)];
    normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
    aspect = normEdges(2) / normEdges(4);
    
%     figure; hold on
%     scatter(xy(:,1),xy(:,2),sz,clr,'filled','MarkerFaceAlpha',0.25); 
%     scatter(xysyn(:,1),xysyn(:,2),sz,clr,'filled','MarkerFaceAlpha',0.25);
    
    h = figure; hold on
    % plot local density scatter plot
    scatter(xy(:,1),xy(:,2),sz,LD,'filled','MarkerFaceAlpha',0.50);
    axis ij; axis(normEdges); xlabel('x(nm)'); ylabel('y(nm)'); pbaspect([aspect 1 1])
    colormap(cmap); % colorbar;
    
    syn.Points = syn.Points - [roiEdges(1),roiEdges(3)];
    plot(syn,'FaceColor',clr2,'FaceAlpha',0.25,'EdgeColor','none');
    
    % plot synaptic region boundary alpha-shape
    shp.Points = shp.Points - [roiEdges(1),roiEdges(3)];
    plot(shp,'FaceColor',clr,'FaceAlpha',0.50,'EdgeColor','none'); grid on   
    
    axis ij; axis(normEdges); pbaspect([aspect 1 1]); xlabel('x(nm)'); ylabel('y(nm)');
    title([titlestr,'_nanoRegions'],'Interpreter','none')
    


end