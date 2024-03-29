% Program to analyze nuclear deformation in lipid-loaded hepatocytes
% Abigail Loneker, Wells Lab, UPenn

% [absArea, dentRadiiPix, concavity] = calcNucIrregularity(nuclei, minSize)
% absArea = Nuclear Irregularity Parameter
% dentRadiiPix = Array of indent curvature along the boundary
% concavity = Array of concavity of indent curvature along the boundary
% nuclei = Segmented BW image of nuclei
% minSize = Minimum nuclear area in pixels

% Program requires download of CircleFitByPratt 
% Nikolai Chernov (2023). Circle Fit (Pratt method) 
% (https://www.mathworks.com/matlabcentral/fileexchange/22643-circle-fit-pratt-method)

function [absArea, dentRadiiPix, concavity] = calcNucIrregularity(nuclei, minSize)
    
    nuclei2 = bwconncomp(nuclei); 
    L = labelmatrix(nuclei2);
    stats = regionprops(L,'Area');
    idx = find([stats.Area] > minSize); 
    nuclei = ismember(L,idx);

    
    stats = regionprops('table',nuclei,'Centroid','EquivDiameter','Area','Circularity','Eccentricity','Solidity'); % Quantifies image region properties
    centers = cat(1,stats.Centroid); % Makes array of center points
    radii = stats.EquivDiameter/2; % Array of radii of circles fit to nuclei

    % Finds and plots boundaries of nuclei
    B = bwboundaries(nuclei); % bwboundaries determines the points along the boundary of each image region
    numCenters = size(centers);
    numBoundary = size(B);
    nuc = min(numCenters,numBoundary);

    for n = 1:1:nuc
        
        % Clears intermediate variables
        clearvars circleRadii3 normalizedRadDist membrane angles radialDistances 

        boundary = B{n}; % pulls out individual boundary
        [r, ~] = size(boundary); % determines # of points in boundary "r"

        for boundpoint = 1:r % loops through points along the boundary
                radialDistances(n,boundpoint)=sqrt((centers(n,1)-boundary(boundpoint,2))^2+(centers(n,2)-boundary(boundpoint,1))^2); % pythagorean theorem to calculate distance
        end

        radialDistances(radialDistances==0) = NaN;
        normalizedRadDist = radialDistances(n,:)/radii(n); % normalizes radial distance to radius calculated from equivalent diameter

        membrane = normalizedRadDist; 
        membrane = membrane(~isnan(membrane)); % removes undefined # from membrane
        angles = 0:2*pi()/(length(membrane)-1):2*pi(); % linearizes circle into pixels per radian

        areaBoundary = membrane - 1; % calculates difference from perfect circle (line at y=1)
        absAreaBound = abs(areaBoundary); % takes absolute value
        absBoundaryInt = trapz(2*pi()/length(areaBoundary), absAreaBound); % calculates area between boundary and line
        absArea(n) = absBoundaryInt;

        y2 = smooth(membrane,0.05,'lowess'); 
       
        areaBoundarySmooth = y2-1;
        derivBoundary = diff(areaBoundarySmooth); % discrete 1st derivitive
        deriv2Boundary = diff(derivBoundary); % discrete 2nd derivative
        deriv2Sign = sign(deriv2Boundary); 
        deriv2SignDiff = diff(deriv2Sign); 
        inflectionPoints = find(deriv2SignDiff~=0); % finds zero points of second derivative = inflection points
        
        % Fits each boundary segment between inflection points with a
        % circle to estimate curvature
        circleCount = 0;
        for counter = 2:1:length(inflectionPoints)
            ySection = membrane([inflectionPoints(counter-1):inflectionPoints(counter)]);
            xcoord = angles([inflectionPoints(counter-1):inflectionPoints(counter)]);
            nucSection = [xcoord', ySection'];
            par = CircleFitByPratt(nucSection);
            circleCount = circleCount + 1;
            circleCenters(circleCount, 1) = par(1);
            circleCenters(circleCount, 2) = par(2);
            circleRadii3(circleCount) = par(3);
            midpoint = inflectionPoints(counter - 1) + floor((inflectionPoints(counter) - inflectionPoints(counter-1))/2);
            concavity(circleCount) = deriv2Sign(midpoint);
        end
        dentRadii = circleRadii3;
        dentRadiiPix = dentRadii.*radii;
        

    end

end