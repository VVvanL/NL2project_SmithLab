function r_syn = randomize_synRegion(xy,shp)
    
    % create bounding-box [xmin, xmax, ymin, ymax]
    b_box = [min(xy(:,1)),max(xy(:,1)),min(xy(:,2)),max(xy(:,2))]; %#ok<*NASGU>
    box_area = (b_box(2) - b_box(1)) * (b_box(4) - b_box(3)); 
    
    % calculate number of random points to achive target density    
    n_locs = length(xy); syn_area = area(shp); syn_density = n_locs / syn_area; % density in locs per nm2
    n_ran = 2 * syn_density * box_area; % set number of random localizations to excess of what is required
    n_ran = round(n_ran);
    
    % generate random coordinates for bounding box (rand for uniform distribution)    
    r = rand([n_ran,2]); 
    r(:,1) = b_box(1) + (b_box(2) - b_box(1)) .* r(:,1);
    r(:,2) = b_box(3) + (b_box(4) - b_box(3)) .* r(:,2);
    
    % run inShape function to select coordinates within synaptic region boundary
    tf = inShape(shp,r); r_syn = r(tf,:);    
    % winnow coordinates to match experimental number of coordinates
    r_syn = r_syn(1:n_locs,:);

end