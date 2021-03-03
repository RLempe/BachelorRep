% Fetch the blue for Romy
Col_in = [0 1 0; 1 .4 0];
Bckgrnd = [0.4 0.4 0.4];

[AdjConditions]=PRPX_IsolCol([Bckgrnd; Col_in],8,5,0,[540 540]);

mitOrange = AdjConditions;
MariasLum = mean([139.3 137.0 143.6 140.8 139.7 140.8 138.6 142.3; 190.8 192.3 193.4 186.4 187.5 192.3 185.7 187.4],2);
MariasILE= Col_in.*repmat(max(Col_in,[],2).*(MariasLum/255),[1 3]);

[AdjConditions]=PRPX_IsolCol([Bckgrnd; Col_in],8,5,0,[540 540]);

NormansILE = AdjConditions;

avgILE = (MariasILE + NormansILE(2:3,:))./2;


% color measurement with averaged ILE colors
[Col_out,bob] = CMmeasureColors(avgILE,'auto');

% calculate color with equal distance to avgILE colors
calc_colorbydist(Col_out(1,:), Col_out(2,:), 'ColorSpace_In','LAB','ColorSpace_Out','LAB','PlotColors',true)

Col_out(3,:) = [54.964 11.757 -80.572]; % green, orange and equidistant blue

% convert into RGB and Lxy space
Col_out_Lxy = zeros(size(Col_out));
Col_out_sRGB = Col_out_Lxy;
for i_in = 1:size(Col_out,1)
    Col_out_Lxy(i_in,[3 1 2]) = XYZToxyY(lab2xyz(Col_out(i_in,:))'); % 
    %0.5912    0.2289    0.2783
    %0.3927    0.2045    0.5543
    %0.1422    0.2289    0.1514
    Col_out_sRGB(i_in,:) = lab2rgb(Col_out(i_in,:))';
    %-0.1827    0.6073    0.1161
    %0.8019    0.3575    0.0452
    %-0.3948    0.5277    1.0710
end

% re-run colorimeter measurement to fetch the blue of [0 0.5 1]
bluecorrect = CMmeasureColors([0 0.5 1],'auto');

% do isoluminance adjustement with the new blue
[AdjConditions]=PRPX_IsolCol([Bckgrnd; Col_in; 0 0.5 1],8,5,0,[540 540]);

% new colormeasurement
[newCol_out] = CMmeasureColors(AdjConditions(2:end,:),'auto');

% compare positions on colorwheel
plot_colorwheel([newCol_out; 54.964 11.757 -80.572],'ColorSpace','LAB',...
    'SavePath','/home/pc/matlab/user/romy/LuckyFeat/BachelorRep','LAB_L',54.964,...
    'LumBackground',40,'disp_LAB_vals',true)

% ##
%color values:
%Colors2plot: [53.045 -62.370 49.088]; CIE L*a*b: [53.045 -62.370 49.088]; color hue in °: [141.795]
%Colors2plot: [49.104 40.814 55.708]; CIE L*a*b: [49.104 40.814 55.708]; color hue in °: [53.772]
%Colors2plot: [50.344 1.273 -57.653]; CIE L*a*b: [50.344 1.273 -57.653]; color hue in °: [271.265]
%Colors2plot: [54.964 11.757 -80.572]; CIE L*a*b: [54.964 11.757 -80.572]; color hue in °: [278.302]


%##
%color hue differences:
%color [50.344 1.273 -57.653] vs [54.964 11.757 -80.572]: 7.037°
%color [49.104 40.814 55.708] vs [54.964 11.757 -80.572]: 135.470°
%color [49.104 40.814 55.708] vs [50.344 1.273 -57.653]: 142.507°
%color [53.045 -62.370 49.088] vs [54.964 11.757 -80.572]: 136.507°
%color [53.045 -62.370 49.088] vs [50.344 1.273 -57.653]: 129.469°
%color [53.045 -62.370 49.088] vs [49.104 40.814 55.708]: 88.024°


RomysColors = AdjConditions(2:end,:);
%        0    0.5255         0
%    0.6784    0.2714         0
%         0    0.3980    0.7961