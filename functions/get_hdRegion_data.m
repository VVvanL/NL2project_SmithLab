function [data_r, data_p] = get_hdRegion_data(XY, psd, nano, a, C, threshold, P, R)
    % P/R = psd and receptor channels, respectively
    % a = alpha value for genration of hdr alphaShape boundaries
    % data_hdRg = get_hdRegion_data(XYsyn, psd, nano_rg, n_alpha, cbc);
    %TODO: move to functions folder
    % currently set to only retrieve receptor data vis-a-vis PSD (gephryin)
    % 210704 Updated to retrieve pHDR xy data (for downstream distance analysis)
    data_r = struct(); data_p = struct();
    
    % hd-region specific receptor localizations    
    num_reg1 = numRegions(nano{R}); hdr_xy = cell(2,num_reg1); % row 1 logical, row 2 hd-region coordinates
    for n = 1:num_reg1
        hdr_xy{1,n} = inShape(nano{R},XY{R},n);
        hdr_xy{2,n} = (XY{R}(hdr_xy{1,n},:));    
    end 
    
    % hd-region overlap (receptor regions/psd hd-regions)    
    num_reg2 = numRegions(nano{P}); hdr_overlap = cell(num_reg2,num_reg1); phdr_xy = cell(2,num_reg2);
    for n2 = 1:num_reg2
        phdr_xy{1,n2} = inShape(nano{P}, XY{P},n2);
        phdr_xy{2,n2} = (XY{P}(phdr_xy{1,n2},:));
        for n1 = 1:num_reg1
            tf = inShape(nano{P}, hdr_xy{2,n1}, n2);
            if sum(tf) < 5 && sum(tf) ~= 0; tf = false(length(tf),1); end  % necessary to avoid shapes with inf alpha
            hdr_overlap{n2,n1} = alphaShape(hdr_xy{2,n1}(tf,1), hdr_xy{2,n1}(tf,2),a(R));
        end           
    end        
    
    % receptor hdrs in PSD; all receptor locs in PSD
    num_psd = numRegions(psd); in_psd = cell(1,num_psd); psd_overlap = cell(num_psd,num_reg1);
    for p = 1:num_psd
        tf = inShape(psd, XY{R}, p);
        in_psd{p} = XY{R}(tf,:);
        for n1 = 1:num_reg1
            tf = inShape(psd, hdr_xy{2,n1}, p);
            if sum(tf) < 5 && sum(tf) ~= 0; tf = false(length(tf),1); end  % necessary to avoid shapes with inf alpha
            psd_overlap{p,n1} = alphaShape(hdr_xy{2,n1}(tf,1), hdr_xy{2,n1}(tf,2),a(R));            
        end        
    end
    in_psd = cell(1,1);
    tf = inShape(psd, XY{R});
    in_psd{1} = XY{R}(tf,:);
    
    % per hd-region/overall cbc rank for receptor localizations
    cbc = cell(3,num_reg1);
    for n = 1:num_reg1
        cbc{1,n} = C{1,R}(hdr_xy{1,n},:); % exp-exp cbc per region(column)
        cbc{2,n} = C{2,R}(hdr_xy{1,n},:); % rand-rand cbc per region
        cbc{3,n} = C{3,R}(hdr_xy{1,n},:); % exp-rand cbc per region       
    end
    
    % catagorize receptor hd-regions ('inPSD','inPSDhdr','extraPSD') - use threshold
    regions = cell(4,num_reg1);
    for n = 1:num_reg1
        regions{1,n} = area(nano{R},n); % recpt-hdr area
        regions{2,n} = sum(cellfun(@area,hdr_overlap(:,n))) / regions{1,n}; % area fraction of recpt-hdr,psd-hdr overlap
        regions{3,n} = sum(cellfun(@area,psd_overlap(:,n))) / regions{1,n}; % area fraction of recpt-hdr, psd overlap
        if regions{2,n} >= threshold; regions{4,n} = 'inPSDhrd';
        elseif regions{3,n} >= threshold; regions{4,n} = 'inPSD';
        else; regions{4,n} = 'extraPSD';
        end        
    end
    
    data_r.hdr_rg = regions;
    data_r.hdr_xy = hdr_xy; % row1 logical for hd-regions, row2 coordinates for hd-region
    data_r.hdr_overlap = hdr_overlap; % hd-regions overlap (recpt. hdrs, psd hdrs)
    data_r.in_psd = in_psd; % all receptor localizations in PDS region
    data_r.psd_overlap = psd_overlap;  % row2 receptor hdrs in PSD (areas)
    data_r.cbc = cbc; % per hd-region cbc rank (1:exp-exp, 2:rand-rand, 3:exp-rand)
    
    data_p.hdr_xy = phdr_xy;

end
