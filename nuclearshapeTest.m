% Nuclear Shape Analysis
% Abigail Loneker
% April 30th, 2020 (COVID-19 Quarentine)

% This program calculates the radial distance from the centroid of each
% nucleus to the nuclear boundary. Mean radial distance measures
% differences in nuclear size, variation in mean radial distance
% (normalized to account for nuclear size effects) is a measure of nuclear
% envelope roughness/deformation.

% Can also calculate a circular varience (the mean squared varience of the
% residuals). Residuals are calculated based on comparison to a circle with radius =
% major axis/minor axis/2
clc;
clear;
close;

% Reads in the image and converts to binary
% Images should be smoothed and thresholded in imageJ
nuclei = imread('Oleate_Soft_02.tif');
% nuclei = ~nuclei;
nuclei = nuclei>1;

% Displays image
figure(1)
imshow(nuclei);
hold on

% Finds and plots centroid of each nucleus
stats = regionprops('table',nuclei,'Centroid','EquivDiameter','Area','Circularity','Eccentricity','Solidity');
centers = stats.Centroid;
plot(centers(:,1),centers(:,2),'*')

% Fits circle to each nucleus

radii = stats.EquivDiameter/2;
viscircles(centers,radii);

% Finds and plots boundries of nuclei
[B, L] = bwboundaries(nuclei); 
nuc = size(B);

% radialDistances = zeros(nuc(1), 2000);
for k=1:nuc% loops through nuclei in image
    boundary = B{k};
    [r, c] =size(B{k});
    for boundpoint = 1:r % loops through points along the boundary
        radialDistances(k,boundpoint)=sqrt((centers(k,1)-boundary(boundpoint,2))^2+(centers(k,2)-boundary(boundpoint,1))^2); % pythagorean theorem to calculate distance
    end
    radialDistances(radialDistances==0)= NaN; % replaces zeros for accurate mean and stdev
    meanRadialDistances(k,1) = nanmean(radialDistances(k,:)); 
    standardDeviationRadDist(k,1) = nanstd(radialDistances(k,:)); 
    plot(boundary(:,2),boundary(:,1)) % plots boundary in the image
end
hold off

% MEASURE OF RADIAL DISTANCE VARIATION
normalizedRadialDistances = radialDistances./meanRadialDistances % normalizes radial distance measure to account for nuclear size differences
normalizedStdDevRadDist = nanstd(normalizedRadialDistances,0,2) 

% % MEASURE OF CIRCULAR VARIENCE
% residualDistances = radialDistances - radii;
% xresiduals = 0:size(residualDistances,2)-1;

% for resFig = 1:size(residualDistances,1)
%     fignum = resFig + 1;
%     figure(fignum) 
%     plot(xresiduals,residualDistances(resFig,:))
% end
% 
% squaredErrors = residualDistances.^2;
% meanSquaredErrors = nanmean(squaredErrors,2);


% OUTPUT
normalizedStdDevRadDist
areas = stats.Area
% eccentricity = stats.Eccentricity
% circularity = stats.Circularity
% solidity = stats.Solidity
bound = normalizedRadialDistances(1,:);
bound = bound(~isnan(bound));
angles = 0:2*pi()/(length(bound)-1):2*pi();
[angles, bound] = prepareCurveData(angles, bound);

[curve, goodness, output] = fit(angles, bound, 'smoothingspline');
plot(curve, angles, bound)


