function ld = determine_localDensity(XY,radius,varargin)    
    
    [~,D] = rangesearch(XY,XY,radius);
    N = cellfun(@(x) size(x,2), D, 'UniformOutput', false); ld = cell2mat(N);
    % ld.mD = cellfun(@mean,D);
    % plot LD figure
    if nargin > 2
        aes = varargin{1}; titlestr = varargin{2}; roiEdges = varargin{3};
        % normalize XY and roiEdges
        XY = XY - [roiEdges(1),roiEdges(3)]; % normalize localizations to roi boundaries
        normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
        aspect = normEdges(2) / normEdges(4);

        figure
        scatter(XY(:,1),XY(:,2),aes.sz,ld,'filled','MarkerFaceAlpha',0.75);
        axis ij; axis(normEdges); xlabel('x(nm)'); ylabel('y(nm)'); pbaspect([aspect 1 1])
        colormap(aes.cmap_d); colorbar; grid on    
        title([titlestr,'_local density'],'Interpreter','none')
    end
    
end