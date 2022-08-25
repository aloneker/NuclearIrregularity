# Nuclear Irregularity

This repository will host the code used to calculate and analyze nuclear membrane irregularity for my thesis work. It will be cited in all relevant publications. 

Nuclear irregularity describes the normalized area of deviation from a perfect circle with the average radius of the nucleus. The linearized membrane boundary is also analyzed for points of inflection and then each portion of the membrane is fit with a circle to find the local radius of curvature for each indentation. 

Send the function a binary image of the nuclei and the minimum cross-sectional nuclear area. Function will send back the nuclear irregularity, a vector of all of the radii of curvature, and a vector indicating the concavity of the curvature. Positive and negative radii can be seperated using conditional indexing, see below example. 

[nuclearIrregularity, dentRadiiPix, concavity] = calcNucIrregularity(nuclei, minSize)
negRadii = dentRadiiPix(concavity == -1)
posRadii = denRadiiPix(concavity == 1)
