# Calculating the number of Average Radial Length Crossings (ARLC) for applications in spheroid/organoid image analysis 
This README file provides documentation pertaining to the script “AverageRadialLengthCrossings.m” developed for shape factor analysis of spheroids and organoids in the manuscript “Shape Factor Screening to Quantify Morphological Signatures of Spheroid/Organoid Malignancy and Invasiveness”. This analysis was inspired by radial length crossing metrics proposed by Kilday *et. al.* for mammagram analysis applications [1] (https://pubmed.ncbi.nlm.nih.gov/18218460/)

### Average Radial Length Crossings 
Here, the radial length is defined as the Euclidian distance from the centroid to each perimeter point. 

$$\text{radial length}_i=\sqrt{(x_i-x_{\text{centroid}})^2+(y_i-y_{\text{centroid}})^2}$$

The average of all radial lengths is used as the crossing threshold (Average Radial Length).

### Determining an Average Radial Length Crossing with different sensitivities 
There are two parameters than can be adjusted to optimize the signal to noise ratio of your data set 
1. **Excursion Length** = the minimum horizontal span (along the average radial length axis) during which a peak or valley remains above or below the mean radial length for it to be classified as a valid crossing
2. **Minimum Crossing Distance** = A peak or valley must differ from the average radial length by at least this distance (in pixels) to qualify as a crossing

