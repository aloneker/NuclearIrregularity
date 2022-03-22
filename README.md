# Nuclear Irregularity

This repository will host the code used to calculate and analyze nuclear membrane irregularity for my thesis work. It will be cited in all relevant publications. 

Irregularity describes the normalized area of deviation from a perfect circle with the average radius of the nucleus. Additional measures of irregularity are also measured, including the normalized standard deviation of the radius, and the curvature of membrane indentations. 

# NuclearShapeAnalysis

This program calculates the radial distance from the centroid of each nucleus to the nuclear boundary. Mean radial distance measures differences in nuclear size, variation in mean radial distance (normalized to account for nuclear size effects) is a measure of nuclear envelope roughness/deformation.

Can also calculate a circular varience (the mean squared varience of the residuals). Residuals are calculated based on comparison to a circle with radius = major axis/minor axis/2
