function h = plot_nanocluster(xy,xy_n0,xy_n1,ld0,ld1,roiEdges,aes) %#ok<*INUSD,*INUSL>

    %% normalize ROI, localizations
    normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
    aspect = normEdges(2) / normEdges(4); %#ok<*NASGU>
    xy = xy - [roiEdges(1),roiEdges(3)]; 
    xy_n0 = xy_n0 - [roiEdges(1),roiEdges(3)]; xy_n1 = xy_n1 - [roiEdges(1),roiEdges(3)];
    
    h = figure;       
    ax = axes; 
    scatter(ax,xy(:,1),xy(:,2),aes.sz,'k','filled','MarkerFaceAlpha',0.23);
    axis ij; axis(normEdges); pbaspect([aspect 1 1]); xlabel('x(nm)'); ylabel('y(nm)');
        
    ax0 = axes;    
    scatter(ax0,xy_n0(:,1),xy_n0(:,2),aes.sz,ld0,'filled','MarkerFaceAlpha',0.79);
    axis ij; axis(normEdges); pbaspect([aspect 1 1]); colormap(ax0,aes.cmap0);    
    
    ax1 = axes;
    scatter(ax1,xy_n1(:,1),xy_n1(:,2),aes.sz,ld1,'filled','MarkerFaceAlpha',0.79);
    axis ij; axis(normEdges); pbaspect([aspect 1 1]); colormap(ax1,aes.cmap1);
    
    linkaxes([ax,ax0,ax1]); ax0.Visible = 'off'; ax1.Visible = 'off';
    
    cb0 = colorbar(ax0,'Position',[.80 .11 0.029 .815]); cb0.Label.String = 'synaptic LD';
    cb1 = colorbar(ax1,'Position',[.90 .11 0.029 .815]); cb1.Label.String = 'nanocluster LD';    
   
end