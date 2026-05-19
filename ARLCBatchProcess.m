%Batch ARLC Process of a folder of ROIs 
%Average Radial Length Crossing Analysis - please see the README file

%Before you begin, you will need the following functions developed by Dylan
%Muir added to your working directory - use the forked version https://github.com/BrittanySchutrum/ReadImageJROI

% 1) ReadImageJROI.m 
% 2) ROIs2Regions.m 

% Non-function script
close all
clear 
clc 

% Adjust excursion length & minimum distance (measured in pixels)
excursion_length = 3; % number of points that need to consecutively fall to one side of the average 
minimum_distance = 5; % minimim distance between the radial length and the aveage radial length to be counted 

% Adjust angle of segmentation in degrees
%this is "slice" of the ROI you will analyze, 0 degrees is 3 o'clock and
%increases counterclockwise 
theta_start = 0;
theta_end = 360;

% Select folder containing ROI files
folder = uigetdir([], 'Select folder containing ROI files');

% Get list of all .roi files in the folder
files = dir(fullfile(folder, '*.roi'));

%collect results
results_filename = strings(length(files),1);
results_crossings = zeros(length(files),1);
results_std = zeros(length(files),1);

%Inputs 
% Select an ".roi" file to analyze (created in FIJI)
% Loop through each ROI file
for k = 1:length(files)

    % Build full path to the ROI file
    inputroi = fullfile(folder, files(k).name);
    fprintf('Processing: %s\n', inputroi);

    [radiallengths_section] = radiallengths(inputroi, [2048, 2048], theta_start, theta_end);

    [intersectionnumber, sd_RD] = plot_intersections(radiallengths_section, ...
                                            excursion_length, minimum_distance);
    %store results 
    results_filename(k) = files(k).name;
    results_crossings(k) = intersectionnumber;
    results_std(k) = sd_RD;

end 
%CSV export table for results of each ROI in the input folder
T = table(results_filename, results_crossings, results_std, ...
          'VariableNames', {'Filename', 'ARLC', 'StdRadialLength'});

writetable(T, fullfile(folder, 'ARLC_results.csv'));
fprintf('Results saved to: %s\n', fullfile(folder, 'ARLC_results.csv'));

% this version of the script does not include plots and only yeilds
% numberical results exported into a CSV table

%% All local functions defined here.
function [radiallengths_section]= radiallengths(filename, dimensions, theta_start, theta_end)
% PLOTINTERSECTIONS calulates the radial lengths from centroid perimeter
% points.
%
%   INPUT
%       filename = character string of the filname of the ROI to be
%       analyzed.
%       dimensions = [pixel_width pixel_height]
%
%   OUTPUT:
%       [radialdistance] array of distances from each perimeter point to
%       centroid.
    
    out = ReadImageJROI(filename); % function from Dylan Muir that reads ROI file into MATLAB struct "out".
    [filepath,name,ext] = fileparts(filename);
    i = length(out.mnCoordinates); % mnCoodinates are perimeter points.
    xcoords = out.mnCoordinates(:,1); % Extracing x and y coordinates from perimeter points.
    ycoords = out.mnCoordinates(:,2);
    
    max_size = max(dimensions);
    [sRegions] = ROIs2Regions(out, [max_size max_size]); % function from Dylan Muir that converts MATLAB structures to regions.
    centroid = regionprops(sRegions,'centroid'); % Built-in function to find centroid of shape
    centroidx = centroid.Centroid(1); % Extracting x and y coordinated of centroid
    centroidy = centroid.Centroid(2);
    
    % computing distance from centroid to each perimeter point
    xdiff = xcoords - centroidx;
    ydiff = ycoords - centroidy;
    radialdistance=sqrt((xdiff.^2)+(ydiff.^2)); % Euclidian distance from centroid -> perimeter = radial lengths

    % computing angle of each perimeter point
    theta = mod(atan2(ydiff, xdiff), 2*pi);
    
    % defining the start and end angles from degrees to radians
    theta_start = deg2rad(theta_start);
    theta_end = deg2rad(theta_end);

    % Mask = TRUE for angles that are within the specified boundary
    if theta_start <= theta_end
        % normal case where theta_start < theta_end (mask is TRUE for
        % indices bigger than theta_start AND smaller than theta_end)
        section = (theta >= theta_start & theta <= theta_end);
    else
        % wrapped case where theta_start > theta_end (mask is TRUE for
        % indices bigger than theta_start OR smaller than theta_end)
        section = (theta >= theta_start | theta <= theta_end);
    end

    % keeps only the radial distances that fall within this section
    radiallengths_section = radialdistance(section);
    
         

end

function [intersectionnumber, sd_RD] = plot_intersections(rad_dist, exlength, mindist)
% PLOTINTERSECTIONS calulates the number of average radial length crossings
% 
%
%   INPUT:
%       rad_dist = Array of radial distances from ROI centroid to perimeter
%       points as returned by the plotintersections function.
%       
%       exlength = excursion length. The number of sustained points above/below average, acts
%       as a smoother to avoid single point fluctuations.
%       
%       mindist = minimum distance. The number of pixels from the average, acts as a
%       smoother to avoid small/noisy deflections from the average.
%
%   OUTPUT:
%       [intersectionnumber] the number of radial length crossings.
%       [inflection_indexes] an array storing the inflection positions as
%       integers
   
% ARLCs are defined as points where adjacent points are on oppoiste
    % sides of the average radial length

    % A logical array of 1s and 0s. 1 = above ARL, 0 = below ARL. 
    side = rad_dist > mean(rad_dist); 
   
    % Intialize counting variables
    run_start = 1; 
    excursions = 0;
    inflection_indexes = [];
    inflection_points = [];

    % Starting at the second point, look at the point(s) behind it and
    % determine if there has been a flip to above or below the avg.

    for i = 2:length(rad_dist) % For-loop thats starts at i = 2 and iterates over no. of elements in rad_dist
        if side(i-1) ~= side(i) % If the previous point is not on the same side of the avg as the current point  
            run_end = i-1;      % Save the last index of the point right before flip occurs
            run_length = run_end - run_start + 1; % The number of points on the same side before flip occurs
            if run_length >= exlength % If there is at least a certain number of points on the same side
                excursion_values = rad_dist(run_start:run_end); % Save the radial distances of these points
                
                % Checking if the peak/valley of the set of points deviatate by -threshold 
                % or +threshold from the average radial distance
                if (max(excursion_values) >= mean(rad_dist) + mindist) || (min(excursion_values) <= mean(rad_dist) - mindist)
                    excursions = excursions + 1; % We count this event as an excursion 
                    inflection_indexes = [inflection_indexes i]; % Storing inflection position integ in an array
                    run_start = i; % We evaluated points up to, but excluding, the i-th position. The next loop will start at i. 
                end
            end 
        end 
    end

    
%   Linear interpolation to find inflection points between discrete perimeter points.

    %   Horizontal distance x = inflection_indexes
    %   Vertical distance y = rad_dist

    for a = 1:length(inflection_indexes) % For-loop thats starts at a = 1 and iterates over no. of elements in inflection_indexes
        prev_point = inflection_indexes(a)-1; % x0 = the index before the inflection point
        l = mean(rad_dist) - rad_dist(prev_point); % (y-y0) = The distance between average radial distance and the radial distance of previous point
        m = inflection_indexes(a) - prev_point; % (x1-x0) = 1, as this is the distance between index a and a-1
        n = rad_dist(inflection_indexes(a)) - rad_dist(prev_point); % (y1-y0) = Vertical distance between previous index and current index a
        inflection_pt = (l*m/n) + prev_point; % x = the position of inflection point, can be a fraction
        inflection_points = [inflection_points inflection_pt]; % saving all inflection point indices in an array
    end 
  
    intersectionnumber = length(inflection_points); % Count up all the number of inflection points
    sd_RD = std(rad_dist);
  
     % printing to command window    
    fprintf('Average Radial Length Crossings: %d\n', intersectionnumber);
    fprintf('Standard Deviation of Radial Lengths: %f\n', sd_RD);

end

