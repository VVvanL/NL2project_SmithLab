function C = CBC(A,B,Rmax,r_step) 
    % A,B = xy coordinate lists for each channel
   
    step_n = Rmax / r_step; % needs to be interger value (TODO: code to check and adjust Rmax if necessary)
    
    Idx = rangesearch(A,A,Rmax); nAA_Rmax = cellfun(@length, Idx) -1;
    Idx = rangesearch(B,A,Rmax); nAB_Rmax = cellfun(@length, Idx);
    nAA_Rmax = nAA_Rmax/Rmax^2; nAB_Rmax = nAB_Rmax/Rmax^2; % normalize for Rmax area
    
    % preallocate arrays for distance distrubutrion 
    nAA_r = zeros(length(A),step_n); nAB_r = nAA_r;
    dAA_r = nAA_r; dAB_r = nAB_r;
    for r = 1:step_n
        radius = r_step * r; 
        Idx = rangesearch(A,A,radius); nAA_r(:,r) = cellfun(@length, Idx) -1; % Naa_r
        Idx = rangesearch(B,A,radius); nAB_r(:,r) = cellfun(@length, Idx); % Nab_r

        dAA_r(:,r) = nAA_r(:,r) ./ (nAA_Rmax * radius^2); 
        dAB_r(:,r) = nAB_r(:,r) ./ (nAB_Rmax * radius^2);   
    end
    
    S = zeros(length(A),1); 
    
    for s = 1:length(A)
        S(s,1) = corr(dAA_r(s,:)',dAB_r(s,:)','Type','Spearman');        
    end
    S(isnan(S)) = 0;
    
    [~,NND] = knnsearch(B,A); 
    C = S .* exp(-NND/Rmax);
end