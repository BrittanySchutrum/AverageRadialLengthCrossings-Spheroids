# Calculating the number of Average Radial Length Crossings (ARLC) 
This README file provides documentation pertaining to the script “AverageRadialLengthCrossings.m” developed for shape factor analysis of spheroids and organoids in the manuscript “Shape Factor Screening to Quantify Morphological Signatures of Spheroid/Organoid Malignancy and Invasiveness”. This analysis was inspired by radial length crossing metrics proposed by Kilday *et. al.* for mammagram analysis applications [[1]](https://pubmed.ncbi.nlm.nih.gov/18218460/)


### Average Radial Length Crossings 
Here, the radial length is defined as the Euclidian distance from the centroid to each perimeter point. 

$$\text{radial length}_i=\sqrt{(x_i-x_{\text{centroid}})^2+(y_i-y_{\text{centroid}})^2}$$

The average of all radial lengths is used as the crossing threshold (Average Radial Length).

### Determining an Average Radial Length Crossing with different sensitivities 
There are two parameters than can be adjusted to optimize the signal to noise ratio of your data set 
1. **Excursion Length** = the minimum horizontal span (along the average radial length axis) during which a peak or valley remains above or below the mean radial length for it to be classified as a valid crossing
2. **Minimum Crossing Distance** = A peak or valley must differ from the average radial length by at least this distance (in pixels) to qualify as a crossing

<p align="center">
  <img src="./images/Min%20distance%20and%20excurs%20length.png" width="350">
</p>

### Finding Inflection Points Using Linear Interpolation 
Because our perimeter points are discrete data, our inflection points may occur on the graph at values between perimeter points. To actually find these inflection points, we need to interpolate between the saved inflection indexes.

We assume that the slope is **linear** between the inflection point and the point just before the inflection. A line between two points $(x_0,y_0),(x_1,y_1)$ is given by the following equation,

$$y-y_0=\frac{y_1-y_0}{x_1-x_0}(x-x_0)$$

Where the terms are defined in the code as:

$$
\begin{aligned}
\text{previous point} &= x_0 \\
\text{inflection point} &= x \\
l &= y - y_0 \\
m &= x_1 - x_0 \\
n &= y_1 - y_0
\end{aligned}
$$

Solving for the inflection point $x$, this gives us a simplified equation for finding the linear interpolation between the two points,

$$\text{inflection point}=\frac{lm}{n}+\text{previous point}$$

## Usage 
Install **MATLAB**, JAVA and add the extension **Image Processing Toolbox** by Mathworks inside MATLAB (Home > Add-Ons > search for "Image Processing Toolbox"). 

Once you have prepared your software, put all the following files into **your working directory**:

* [AverageRadialLengthCrossings.m](https://github.com/amaliegao/Spheroid-Shape-Analysis---Schutrum/blob/main/mastercode.m)
* [ReadImageJROI.m](https://github.com/DylanMuir/ReadImageJROI/blob/master/ROIs2Regions.m)
* [ROIs2Regions.m](https://github.com/DylanMuir/ReadImageJROI/blob/master/ROIs2Regions.m)
