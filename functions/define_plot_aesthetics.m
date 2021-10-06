function aes = define_plot_aesthetics()
% NOTE: required function rgb.m; to view color palette, enter [rgb chart] in command window
% Also required function hex2rgb
aes = struct();
%% Enter desired plotting aesthetics
% Marker size for scatterplots
aes.sz = 17;
% plot colors channel data, synaptic region
aes.clr_syn = {rgb('DarkCyan'),rgb('MediumOrchid'),rgb('DimGray'),rgb('Orange')}; %#ok<*NASGU>
% colormap for plotting local-density
aes.cmap_d = [rgb('MidnightBlue');rgb('CornflowerBlue');rgb('SkyBlue');...
    rgb('Gold');rgb('DarkOrange');rgb('OrangeRed');rgb('Red');rgb('DarkRed')];
aes.cmap_a = [rgb('MidnightBlue'); rgb('SkyBlue'); rgb('Gold'); rgb('Orange'); rgb('Red')];
% colormaps for plotting nanoclusters
aes.cmap0 = [rgb('MidnightBlue'); rgb('SkyBlue'); rgb('Gold')]; % colormap for non-nano cluster localizations
aes.cmap1 = [rgb('OrangeRed');rgb('Red');rgb('DarkRed')]; % colormap for nano-cluster localizations
aes.cmap_nr = [rgb('CornflowerBlue');rgb('SkyBlue'); rgb('Gold');rgb('DarkOrange');rgb('OrangeRed');rgb('Red');rgb('DarkRed')];

% colormaps for plotting 2ch nano-region scatters
aes.cmap_2nr = cell(1,2);
hex_nr1 = ['#4292c6';'#2171b5';'#084594']; %from single-hue sequential (7 class)
hex_nr2 = ['#807dba';'#6a51a3';'#4a1486']; %from single-hue sequential (7 class)
aes.cmap_2nr{1} = hex2rgb(hex_nr1); aes.cmap_2nr{2} = hex2rgb(hex_nr2);

aes.cbc = cell(1,2); % colorschemes for cbc scatter plotting (ch1,ch2)
hex1 = ['#f1eef6';'#d0d1e6';'#a6bddb';'#74a9cf';'#3690c0';'#0570b0';'#034e7b'];
hex2 = ['#edf8fb';'#bfd3e6';'#9ebcda';'#8c96c6';'#8c6bb1';'#88419d';'#6e016b'];
aes.cbc{1} = hex2rgb(hex1); aes.cbc{2} = hex2rgb(hex2);

% color scheme for cdf plots
cdf_hex1 = ['#3182bd';'#9ecae1']; cdf_hex2 = ['#756bb1';'#bcbddc'];
aes.cdf{1} = hex2rgb(cdf_hex1); aes.cdf{2} = hex2rgb(cdf_hex2); 

end