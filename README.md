# Calculating the number of Average Radial Length Crossings (ARLC) 
This README file provides documentation pertaining to the script “AverageRadialLengthCrossings.m” developed for shape factor analysis of spheroids and organoids in the manuscript “Shape Factor Screening to Quantify Morphological Signatures of Spheroid/Organoid Malignancy and Invasiveness”. This analysis was inspired by radial length crossing metrics proposed by Kilday *et. al.* for mammagram analysis applications [[1]](https://pubmed.ncbi.nlm.nih.gov/18218460/)


### Average Radial Length Crossings 
Here, the radial length is defined as the Euclidian distance from the centroid to each perimeter point. 

$$\text{radial length}_i=\sqrt{(x_i-x_{\text{centroid}})^2+(y_i-y_{\text{centroid}})^2}$$

The average of all radial lengths is used as the crossing threshold (Average Radial Length).

### Determining an Average Radial Length Crossing with different sensitivities 
There are two parameters than can be adjusted to optimize the signal to noise ratio of your data set 
1. **Excursion Length** = number of points that need to consecutively fall to one side of the average
2. **Minimum Crossing Distance** = minimim distance between the radial length and the aveage radial length

<p align="center">
  <img src="./images/Min%20distance%20and%20ex%20lengthV2.png" width="350">
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

### Segment Analysis vs. full shape analysis 
This code is developed to allow for analysis of the whole shape or only a defined angular "slice"/segment. 0 degrees is 3 o'clock and the angle increases counterclockwise 
To analyse the whole ROI set the inputs of theta_start to 0 and theta_end to 360 degrees. 

## Usage 
Install **MATLAB**, JAVA and add the extension **Image Processing Toolbox** by Mathworks inside MATLAB (Home > Add-Ons > search for "Image Processing Toolbox"). 

Once you have prepared your software, put all the following files into **your working directory**:

* [AverageRadialLengthCrossings.m](https://github.com/BrittanySchutrum/AverageRadialLegnth-Spheroids/blob/main/AverageRadialLengthCrossings.m)
* [ReadImageJROI.m](https://github.com/DylanMuir/ReadImageJROI/blob/master/ROIs2Regions.m)
* [ROIs2Regions.m](https://github.com/DylanMuir/ReadImageJROI/blob/master/ROIs2Regions.m)

To use the code you only need to *open* AverageRadialLengthCrossings.m 

## Inputs 
1. ROI file (.roi file type) from FIJI
2. mimnimim excursion length in pixels
3. minimim crossing distance in pixels
4. theta_start
5. theta_end

## Functions 
### radiallengths() 
radiallengths(inputroi, [2048, 2048], theta_start, theta_end) -> Imports ROI into Matlab, calculates radial length to each perimeter point and creates the  [radialdistance_section] vector, plots the perimeter points of the ImageJ ROI with centroid in MATLAB coordinates (figure 1) % by default the pixel dimentions are defined as 2048x2048. The number does not matter unless your ROI is bigger than these dimensions in pixels

### plot_intersections () 
plot_intersections(radiallengths_section,excursion_length,minimum_distance) -> Plots the radial lengths and determines sustained crossings defined by the excursion length and minimum crossing distance(figure 2) Printed Quantitative Outputs = 1) number of Average Radial Length Crossing (ARLC) and 2) the Standard Deviation of the Radial Length (SDRL)

## Outputs
The following are example ouputs from SampleSpheroid.roi with an excursion length of 3 and minimim crossing distance of 5 
### Figure 1 
<p align="center">
  <img src="./images/Fig1.png" width="1000">
</p>

Figure 1: Plot of the imported ROI in MATLAB. The centroid is plotted as +.  Each perimeter point is a black outlined circle with points that are included in the selected segment filled with red. Here the entire spheroid was analyzed with `theta_start = 0` and `theta_end=360`. 
Please note that due to differences in the coordinate systems used by FIJI and MATLAB, the *ROIs will appear reflected over the X axis (upsidown)* compared to their original orienation in FIJI

### Figure 2 
<p align="center">
  <img src="./images/fig2.png" width="1600">
</p>

Figure 2: Radial Length plot of SampleSpheroid.roi. X-axis = perimeter points, y-axis = radial length (pixels), orange = radial lengths, magenta dotted line = the average radial length , purple points = valid average radial length crossings
### Results 
The script will print the number of average radial length crossings and the standard deviation of radial lengths 

## Open Source Scripts Required 
`ReadImageJROI.m`

This plugin (created by Dylan Muir, 2011) converts an ImageJ ROI to a MATLAB structure. A MATLAB structure is a container for data related to the structure, in this code the structures will contain geometric information about the ROI.

`ROIs2Regions.m`

This plugin (created by Dylan Muir, 2011) converts the ROI structures (returned by ReadImageJROI.m) into binary region masks. 



