function data = get_inPSD_data(XY, psd)

    data = struct();
    
    % receptor hdrs in PSD; all receptor locs in PSD
    num_psd = numRegions(psd); in_psd = cell(1,num_psd);
    for p = 1:num_psd
        tf = inShape(psd, XY, p);
        in_psd{p} = XY(tf,:);       
    end
    
    data.in_psd = in_psd;
end