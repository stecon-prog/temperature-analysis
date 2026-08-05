
% %TEMPURATURE ANALYSIS PROJECT- analyze tempurature across three different
% %scenarios with a 6x 8 grid of sensors
% 
% % Team Members- Chloe De Leon(Data Manager), Stephen Connoley(Algorithm
% % Developer), Abigail Beyrich(Visualization Specialist)
% 
% % Nov 25th 2025
% 
% Description:
% Detailed explanation of what the script does
% 
% This script analyzes data from three scenarios of temperature sensors. Each scenario has 48 sensors, which are arranged in a room in a 6x8 grid. Each scenario tracks the temperatures across a 20 hour period. Part 1 creates constrained, randomized data for each scenario. Those scenarios are written to CSV files. In Part 2, the CSV files are read back into MATLAB and reshaped into grids to analyze per hour. Then, several statistics are calculated including means, mins, maxes, ranges, STDs, hotspots, gradients, persistence, fastest warming sensors, and percentages above threshold. Key findings are written into a table in a CSV called summary_statistics. Part three uses the data collected from Part 1 to generate visualizations of the three different scenarios over time. Part three analyzes hot spots in the malfunction scenario, and tracks patterns across all three scenarios through scatter plots, heat maps, and line plots. 
% 
% Inputs: Description of required input files
% NONE
% 
% Outputs: Description of generated outputs
% From Task 1:
% Csvs with randomized data for each scenario 
% 
% From Task 2:
% "Dimensions Valid" for when the clean data is a 20x48 matrix
% Hotspot sensor indices
% Hotspot persistence messages
% Steepest gradient hours
% Fastest-warming sensor results
% Scenario summary table (CSV attached in submission)
% Percentage increases in mean temperatures
% 
% From Task 3:
% Visualization of heatmap comparison across normal, high load, and malfunction scenarios at hour 15
% Scatterplot of the two hotspots in the malfunction scenario over time
% Bar chart comparing average temperatures across all three scenarios in middle, front, and back sections of the room
% Gradient heatmap visualizations of the 15th hour in the malfunction scenario
% Series of line plots visualizing the number of sensors over 85 degrees for all scenarios, 
% change in temperature over time for all scenarios, the average temperature over time for all scenarios, 
% and a heatmap of hour 20 in the malfunction scenario
% 

%% PART ONE- STEPHEN

clear; clc; close all; 

%create main outside folder, 'Data' with the subfolder, 'Scenarios'
mainFolder = 'Data';
scenarioFolder = fullfile(mainFolder, 'Scenarios'); %make a path where the Scenario folder is inside the mainfolder, 'Data'
mkdir(scenarioFolder); %Make a folder with the folderpath from scenario Folder

%Create the subfolders within the 'Scenarios' folder
normalFolder = fullfile(scenarioFolder, 'Normal');
mkdir(normalFolder);

highLoadFolder = fullfile(scenarioFolder, 'HighLoad');
mkdir(highLoadFolder);

malfunctionFolder = fullfile(scenarioFolder, 'Malfunction');
mkdir(malfunctionFolder);

%Create the files within each folder
normalFile = fullfile(normalFolder, 'normal_temps.csv');
highLoadFile = fullfile(highLoadFolder, 'highload_temps.csv');
malfunctionFile = fullfile(malfunctionFolder, 'malfunction_temps.csv');
scenariosFile = fullfile(scenarioFolder, 'sensor_positions.txt');


%Create the setup with 48 sensors (6x8) grid where the first row represents
%the back wall of the room and the last row represents the front wall of
%the room

hourData = 1:20;
normalTempReadings = zeros(6,8,20); %Preallocates matrix with zeros where each temperature reading for all sensors per hour over 20 hours will be added
highLoadTempReadings = zeros(6,8,20);
malfunctionTempReadings = zeros(6,8,20);

%Senario 1, Normal Operation:
%creates random number set with a mean temp of 72 degrees F while adding 0.05 temp increase per hour with standard devation of 1.5 (about a 1.5 degree F fluctuation)
for hour = hourData
    normalHourlyTempChange = 72 + 0.05 * hour + 1.5*randn(6,8);
    normalTempReadings(:, :, hour) = normalHourlyTempChange;
end
    

%Senario 2, High Load
for hour = hourData
    highLoadHourlyTempChange = 72 + 1.5*randn(6,8); %set the base temperature to 72 with some variation
    for row = 1:6 %for each row per hour, increase the temperature by 0.3 degrees. 
        gradientFactor = (6 - row) / 5; %creates a facotor so that along each row , the temperature increase is decreased by 1/5th (as you get closer to the front wall, the temperatures decrease)
        highLoadTempReadings(row, :, hour) = highLoadHourlyTempChange(row, :) + 0.3 * hour + 2*gradientFactor ; %gradient factor is multiplied by two for a more substantial increase
    end 
end


%Senario 3, Malfunction
for hour = hourData
    malfunctionHourlyTempChange = 72 + 1.5*randn(6,8); %set the base temperature to 72 with some variation
    
    
    hotSpot1 = malfunctionHourlyTempChange(6,7); %create the first hot spot with the two sensors touching it labled as adjacent
    adjacentSpot11 = malfunctionHourlyTempChange(6,5);
    adjacentSpot12 = malfunctionHourlyTempChange(6,8);
    hotSpot2 = malfunctionHourlyTempChange(4,2);
    adjacentSpot21 = malfunctionHourlyTempChange(4,1);
    adjacentSpot22 = malfunctionHourlyTempChange(4,3);
    
    malfunctionTempReadings(:, :, hour) = malfunctionHourlyTempChange;
    
    %create the hotspot temperature increase at hotSpot1 as well as a
    %lesser temperature increase at the two sensors adjacent to the hotspot
   
    malfunctionTempReadings(6, 7, hour) = hotSpot1 + 15 + 0.25 * hour;
    malfunctionTempReadings(6, 5, hour) = adjacentSpot11 + 10 + 0.1 * hour;
    malfunctionTempReadings(6, 8, hour) = adjacentSpot12 + 10 + 0.1 * hour;

    
    malfunctionTempReadings(4, 2, hour) = hotSpot2 + 15 + 0.25 * hour;
    malfunctionTempReadings(4, 1, hour) = adjacentSpot21 + 10 + 0.1 * hour;
    malfunctionTempReadings(4, 3, hour) = adjacentSpot22 + 10 + 0.1 * hour;

end


%create tables for each scenario of data

%create the sensor names with a string of 48 items as the grid is 6 by 8
sensorNames = strings(1, 48);
counter = 1;
for row = 1:6
    for column = 1:8
        sensorNames(counter) = "S" + row  + "_" + column; %for each column per row, create the name Srow_column
        counter = counter + 1; %increase the counter so the next item in the grid is named
    end
end 

%convert the 3D matrix into a 2D structure for all 3 senarios
normal2D = reshape(permute(normalTempReadings, [2 1 3]), 48, 20)'; %just using the reshape command creates r1,c1 r2,c1 ... but the names are suppossed to be r1,c1, r1,c2
highLoad2D = reshape(permute(highLoadTempReadings, [2 1 3]), 48, 20)'; %to swap dimensions so that the rows and columns are swtiched to match the correct names, permute(normalTempReadings, [2 1 3]) is switched so the rows (1) are moved second and the columns (2) are first
malfunction2D = reshape(permute(malfunctionTempReadings, [2 1 3]), 48, 20)';

hoursCol = (1:20)';

%create table for all 3 senarios
normalTable = array2table(normal2D, 'VariableNames', sensorNames);
normalTable.Hour = hoursCol; %create an hours column
normalTable = movevars(normalTable, 'Hour', 'Before', 1); %place the hours column at the start

highLoadTable = array2table(highLoad2D, 'VariableNames', sensorNames);
highLoadTable.Hour = hoursCol; %create an hours column
highLoadTable = movevars(highLoadTable, 'Hour', 'Before', 1);

malfunctionTable = array2table(malfunction2D, 'VariableNames', sensorNames);
malfunctionTable.Hour = hoursCol; %create an hours column
malfunctionTable = movevars(malfunctionTable, 'Hour', 'Before', 1);

%write the tables to CSV files
writetable(normalTable, normalFile);
writetable(highLoadTable, highLoadFile);
writetable(malfunctionTable, malfunctionFile);



%create sensor_positions.txt

openFile = fopen(scenariosFile, "w");

fprintf(openFile, "Sensor Grid Layout (6 rows x 8 columns):\n");

for row = 1:6
    if row == 1
        rowLabel = "Row 1 (Back)";
    elseif row == 4
        rowLabel = "Row 4 (Middle)";
    elseif row == 6
        rowLabel = "Row 6 (Front)";
    else
        rowLabel = "Row " + row;
    end

    fprintf(openFile, "%s: ", rowLabel);

    
    for column = 1:8
        sensorName = sprintf("S%d_%d", row, column);
        %fprintf(openFile, "%s ", sensorName);
        if column < 8
            fprintf(openFile, "%s, ", sensorName);
        else
            fprintf(openFile, "%s", sensorName); %done to make sure that there is no , after the 8th sensor name
        end
    end
    fprintf(openFile, "\n");
end


fprintf(openFile, "Scenario Descriptions:\n");
fprintf(openFile, "Normal: Typical operation, 68-75°F, stable\n");
fprintf(openFile, "HighLoad: Heavy usage, 72-85°F, warming trend\n");
fprintf(openFile, "Malfunction: Cooling failure, 65-95°F, hot spots present\n");

fclose(openFile);

%create main outside folder, 'Data' with the subfolder, 'Scenarios'
mainFolder = 'Data';
scenarioFolder = fullfile(mainFolder, 'Scenarios'); %make a path where the 
% Scenario folder is inside the mainfolder, 'Data'
mkdir(scenarioFolder); %Make a folder with the folderpath from scenario 
% Folder

%Create the subfolders within the 'Scenarios' folder
normalFolder = fullfile(scenarioFolder, 'Normal');
mkdir(normalFolder);

highLoadFolder = fullfile(scenarioFolder, 'HighLoad');
mkdir(highLoadFolder);

malfunctionFolder = fullfile(scenarioFolder, 'Malfunction');
mkdir(malfunctionFolder);

%Create the files within each folder
normalFile = fullfile(normalFolder, 'normal_temps.csv');
highLoadFile = fullfile(highLoadFolder, 'highload_temps.csv');
malfunctionFile = fullfile(malfunctionFolder, 'malfunction_temps.csv');
scenariosFile = fullfile(scenarioFolder, 'sensor_positions.txt');


%Create the setup with 48 sensors (6x8) grid where the first row represents
%the back wall of the room and the last row represents the front wall of
%the room

hourData = 1:20;
normalTempReadings = zeros(6,8,20); %Preallocates matrix with zeros where 
% each temperature reading for all sensors per hour over 20 hours will be 
% added
highLoadTempReadings = zeros(6,8,20);
malfunctionTempReadings = zeros(6,8,20);

%Senario 1, Normal Operation:
%creates random number set with a mean temp of 72 degrees F while adding 
% 0.05 temp increase per hour with standard devation of 1.5 (about a 1.5 
% degree F fluctuation)
for hour = hourData
    normalHourlyTempChange = 72 + 0.05 * hour + 1.5*randn(6,8);
    normalTempReadings(:, :, hour) = normalHourlyTempChange;
end
    

%Senario 2, High Load
for hour = hourData
    highLoadHourlyTempChange = 72 + 1.5*randn(6,8); %set the base 
    % temperature to 72 with some variation
    for row = 1:6 %for each row per hour, increase the temperature by 0.3 
        % degrees. 
        gradientFactor = (6 - row) / 5; %creates a facotor so that along 
        % each row , the temperature increase is decreased by 1/5th 
        % (as you get closer to the front wall, the temperatures decrease)
        highLoadTempReadings(row, :, hour) = highLoadHourlyTempChange(row, :) + 0.3 * hour + 2*gradientFactor ; 
        %gradient factor is multiplied by two for a more substantial increase
    end 
end


%Senario 3, Malfunction
for hour = hourData
    malfunctionHourlyTempChange = 72 + 1.5*randn(6,8); %set the base 
    % temperature to 72 with some variation
    
    
    hotSpot1 = malfunctionHourlyTempChange(6,7); %create the first hot spot 
    % with the two sensors touching it labled as adjacent
    adjacentSpot11 = malfunctionHourlyTempChange(6,5);
    adjacentSpot12 = malfunctionHourlyTempChange(6,8);
    hotSpot2 = malfunctionHourlyTempChange(4,2);
    adjacentSpot21 = malfunctionHourlyTempChange(4,1);
    adjacentSpot22 = malfunctionHourlyTempChange(4,3);
    
    malfunctionTempReadings(:, :, hour) = malfunctionHourlyTempChange;
    
    %create the hotspot temperature increase at hotSpot1 as well as a
    %lesser temperature increase at the two sensors adjacent to the hotspot
   
    malfunctionTempReadings(6, 7, hour) = hotSpot1 + 15 + 0.25 * hour;
    malfunctionTempReadings(6, 5, hour) = adjacentSpot11 + 10 + 0.1 * hour;
    malfunctionTempReadings(6, 8, hour) = adjacentSpot12 + 10 + 0.1 * hour;

    
    malfunctionTempReadings(4, 2, hour) = hotSpot2 + 15 + 0.25 * hour;
    malfunctionTempReadings(4, 1, hour) = adjacentSpot21 + 10 + 0.1 * hour;
    malfunctionTempReadings(4, 3, hour) = adjacentSpot22 + 10 + 0.1 * hour;

end


%create tables for each scenario of data

%create the sensor names with a string of 48 items as the grid is 6 by 8
sensorNames = strings(1, 48);
counter = 1;
for row = 1:6
    for column = 1:8
        sensorNames(counter) = "S" + row  + "_" + column; %for each column 
        % per row, create the name Srow_column
        counter = counter + 1; %increase the counter so the next item in 
        % the grid is named
    end
end 

%convert the 3D matrix into a 2D structure for all 3 senarios
normal2D = reshape(permute(normalTempReadings, [2 1 3]), 48, 20)'; %just 
% using the reshape command creates r1,c1 r2,c1 ... but the names are 
% suppossed to be r1,c1, r1,c2
highLoad2D = reshape(permute(highLoadTempReadings, [2 1 3]), 48, 20)'; %to 
% swap dimensions so that the rows and columns are swtiched to match the 
% correct names, permute(normalTempReadings, [2 1 3]) is switched so the 
% rows (1) are moved second and the columns (2) are first
malfunction2D = reshape(permute(malfunctionTempReadings, [2 1 3]), 48, 20)';

hoursCol = (1:20)';

%create table for all 3 senarios
normalTable = array2table(normal2D, 'VariableNames', sensorNames);
normalTable.Hour = hoursCol; %create an hours column
normalTable = movevars(normalTable, 'Hour', 'Before', 1); %place the hours 
% column at the start

highLoadTable = array2table(highLoad2D, 'VariableNames', sensorNames);
highLoadTable.Hour = hoursCol; %create an hours column
highLoadTable = movevars(highLoadTable, 'Hour', 'Before', 1);

malfunctionTable = array2table(malfunction2D, 'VariableNames', sensorNames);
malfunctionTable.Hour = hoursCol; %create an hours column
malfunctionTable = movevars(malfunctionTable, 'Hour', 'Before', 1);

%write the tables to CSV files
writetable(normalTable, normalFile);
writetable(highLoadTable, highLoadFile);
writetable(malfunctionTable, malfunctionFile);

%create sensor_positions.txt

openFile = fopen(scenariosFile, "w");

fprintf(openFile, "Sensor Grid Layout (6 rows x 8 columns):\n");

for row = 1:6
    if row == 1
        rowLabel = "Row 1 (Back)";
    elseif row == 4
        rowLabel = "Row 4 (Middle)";
    elseif row == 6
        rowLabel = "Row 6 (Front)";
    else
        rowLabel = "Row " + row;
    end

    fprintf(openFile, "%s: ", rowLabel);

    
    for column = 1:8
        sensorName = sprintf("S%d_%d", row, column);
        %fprintf(openFile, "%s ", sensorName);
        if column < 8
            fprintf(openFile, "%s, ", sensorName);
        else
            fprintf(openFile, "%s", sensorName); %done to make sure that 
            % there is no , after the 8th sensor name
        end
    end
    fprintf(openFile, "\n");
end

fprintf(openFile, "Scenario Descriptions:\n");
fprintf(openFile, "Normal: Typical operation, 68-75°F, stable\n");
fprintf(openFile, "HighLoad: Heavy usage, 72-85°F, warming trend\n");
fprintf(openFile, "Malfunction: Cooling failure, 65-95°F, hot spots present\n");

fclose(openFile);

%% CHLOE'S SECTION

% TASK 1

% build a file path for each scenario, then use that file path to create a
% table
normal_temps_path = fullfile("Data", "Scenarios", "Normal", "normal_temps.csv");
normal_temps = readtable(normal_temps_path);

highload_temps_path = fullfile("Data", "Scenarios", "Highload" , "highload_temps.csv");
highload_temps = readtable(highload_temps_path);

malfunction_temps_path = fullfile("Data", "Scenarios", "Malfunction", "malfunction_temps.csv");
malfunction_temps = readtable(malfunction_temps_path);

% use tables created, excluding first column (labels), to create a matrix
% for each scenario
normal_matrix = normal_temps{:,2:end};
highload_matrix = highload_temps{:,2:end};
malfunction_matrix = malfunction_temps{:,2:end};

[rows, cols] = size(malfunction_matrix);
%fprintf('Rows: %d, Columns: %d\n', rows, cols);

matrices = {normal_matrix, highload_matrix, malfunction_matrix};

for matrix = matrices % prints 
    % if each matrix is valid or invalid, in the order: normal, highload,
    % malfunction
    if rows == 20 && cols == 48 
        fprintf('Dimensions Valid\n')
    else
        fprintf('Dimensions Invalid\n')
    end
end

fprintf('\n') 

% TASK 2

nRows = 6;
nCols = 8;

% create empty lists to store the matrices for each hour
normal_hour_list = {};
highload_hour_list = {};
malfunction_hour_list = {};

for hour = 1:lastHour % iterate through each hour

    % normal data
    hour_vector_normal = normal_matrix(hour,:); 
    % takes the row for a given hour
    reshaped_hour_vector_normal = reshape(hour_vector_normal, [nCols, nRows]);
    % uses reshape to make 1x48 into 8x6
    transpose_reshaped_hour_normal = reshaped_hour_vector_normal';
    % transpose 8x6 into 6x8, making the each column into a row
    normal_hour_list{hour} = transpose_reshaped_hour_normal;
    
% repeat process for each scenario
    
    % highload data
    hour_vector_highload = highload_matrix(hour,:);
    reshaped_hour_vector_highload = reshape(hour_vector_highload, [nCols, nRows]);
    transpose_reshaped_hour_highload = reshaped_hour_vector_highload';
    highload_hour_list{hour} = transpose_reshaped_hour_highload;
    
    % malfunction data
    hour_vector_malfunction = malfunction_matrix(hour,:);
    reshaped_hour_vector_malfunction = reshape(hour_vector_malfunction, [nCols, nRows]);
    transpose_reshaped_hour_malfunction = reshaped_hour_vector_malfunction';
    malfunction_hour_list{hour} = transpose_reshaped_hour_malfunction;

end

% TASK 3

% NOTE: returns means, maxes, mins, ranges, and STD as a col vector. Can 
% be indexed to get specific info for specific hour. Uses 2 are arg to calculate row-wise

% calculate mean temp. per hour with Normal HighLoad Malfunction
normal_means = mean(normal_matrix, 2); 
highload_means = mean(highload_matrix, 2); 
malfunction_means = mean(malfunction_matrix);

% calculate max temp. per hour for each
normal_maxes = max(normal_matrix, 2);
highload_maxes = max(highload_matrix, 2);
malfunction_maxes = max(malfunction_matrix, 2);

% calculate min temp. per hour for each
normal_mins = min(normal_matrix, 2);
highload_mins = min(highload_matrix, 2);
malfunction_mins = min(malfunction_matrix, 2);

% calculate temperature per hour range (min to max)
normal_range = normal_maxes - normal_mins;
highload_range = highload_maxes - highload_mins;
malfunction_range = malfunction_maxes - malfunction_mins;

% give 0 as second argument (weight), because std needs it
normal_STD = std(normal_matrix, 0, 2);
highload_STD = std(highload_matrix, 0, 2);
malfunction_STD = std(malfunction_matrix, 0, 2);

% TASK 4
threshold = 85;

% creates a matrix where values are 1 if the spot is greater than 85
normal_hotspots = normal_matrix > threshold;
highload_hotspots = highload_matrix > threshold;
malfunction_hotspots = malfunction_matrix > threshold;

% sums the hotspots 
normal_hotspots_per_hour = sum(normal_hotspots, 2);
highload_hotspots_per_hour = sum(highload_hotspots, 2);
malfunction_hotspots_per_hour = sum(malfunction_hotspots, 2);

find_hotspot_hour = 20; % set a time where you find hotspots

fprintf('Normal hotspots:')
% use find to find positions where hotspot is
normal_hot_indices = find(normal_hotspots(find_hotspot_hour,:));
disp(normal_hot_indices)
fprintf('\n')

% print hotspot sensor indices for the HighLoad scenario
fprintf('Highload hotspots:')
highload_hot_indices = find(highload_hotspots(find_hotspot_hour,:));
disp(highload_hot_indices)
fprintf('\n')

% print hotspot sensor indices for the Malfunction scenario
fprintf('Malfunction hotspots:')
malfunction_hot_indices = find(malfunction_hotspots(find_hotspot_hour,:));
disp(malfunction_hot_indices)
fprintf('\n')


mal_hot = malfunction_hotspots;   
nHours = 20;
nSensors = 48;

firstHot = nan(1, nSensors);      % when each sensor first becomes > 85°F
persistHours = zeros(1, nSensors); % longest streak of hotspot hours

for sensor = 1:nSensors

    streak = 0;        
    longest = 0;       

    for hour = 1:nHours

        % check if sensor is a hotspot
        if mal_hot(hour, sensor) == 1

            % record first hour it becomes hot 
            if isnan(firstHot(sensor))
                firstHot(sensor) = hour;
            end

            streak = streak + 1;

            if streak > longest
                longest = streak;
            end

        else
            streak = 0;
        end
    end

    persistHours(sensor) = longest;
end
% print data
fprintf("\n--- Malfunction Hotspot Persistence ---\n");

for s = 1:nSensors
    if persistHours(s) >= 3
        fprintf("Sensor %d: first hot at hour %d, lasted %d hours in a row\n", ...
            s, firstHot(s), persistHours(s));
    end
end


% Task 5
% initialize tracking variables for finding steepest gradients
max_left_right = 0;
max_top_bottom = 0;
hour_left_right = 0;
hour_top_bottom = 0;

% loop through all hours in the norm scenario to find steepest gradients
for gradient_hour = 1:lastHour
    grid = normal_hour_list{gradient_hour};
    
    % Calculate horizontal gradient by finding diff between adj. columns
    left_to_right = diff(grid, 1, 2);
    left_to_right_steep = max(abs(left_to_right(:)));
    
    % Calculate vert gradient by finding diff between adj. rows
    top_to_bottom = diff(grid, 1 ,1);
    top_to_bottom_steep = max(abs(top_to_bottom(:)));
  
    %fprintf('LR gradient: %.2f\n\n', left_to_right_steep)
    %fprintf('TB gradient: %.2f\n\n', top_to_bottom_steep)

    % keep track of hour with the steepest hor. gradient
    if left_to_right_steep > max_left_right
        max_left_right = left_to_right_steep;
        hour_left_right = gradient_hour;
    end

    % keep track of hour with the steepest vert gradient
    if top_to_bottom_steep > max_top_bottom
        max_top_bottom = top_to_bottom_steep;
        hour_top_bottom = gradient_hour;
    end
end
fprintf('\nNormal Scenario\n')
fprintf('Steepest left-right gradient across all hours: %.2f occurs at hour %d\n', max_left_right, hour_left_right);
fprintf('Steepest top-bottom gradient across all hours: %.2f occurs at hour %d\n\n', max_top_bottom, hour_top_bottom);

% reset variables and do gradient analysis for highload scenario
max_left_right = 0;
max_top_bottom = 0;
hour_left_right = 0;
hour_top_bottom = 0;

for gradient_hour = 1:lastHour
    grid = highload_hour_list{gradient_hour};
    
    % calculate horizontal gradient
    left_to_right = diff(grid, 1, 2);
    left_to_right_steep = max(abs(left_to_right(:)));

    % Calculate vert gradient
    top_to_bottom = diff(grid, 1 ,1);
    top_to_bottom_steep = max(abs(top_to_bottom(:)));
  
    %fprintf('LR gradient: %.2f\n\n', left_to_right_steep)
    %fprintf('TB gradient: %.2f\n\n', top_to_bottom_steep)
    
    % Keep track of hour with the steepest hor. gradient
    if left_to_right_steep > max_left_right
        max_left_right = left_to_right_steep;
        hour_left_right = gradient_hour;
    end

    % Keep track of hour with the steepest vert gradient
    if top_to_bottom_steep > max_top_bottom
        max_top_bottom = top_to_bottom_steep;
        hour_top_bottom = gradient_hour;
    end
end

fprintf('Highload Scenario\n')
fprintf('Steepest left-right gradient across all hours: %.2f occurs at hour %d\n', max_left_right, hour_left_right);
fprintf('Steepest top-bottom gradient across all hours: %.2f occurs at hour %d\n\n', max_top_bottom, hour_top_bottom);

max_left_right = 0;
max_top_bottom = 0;
hour_left_right = 0;
hour_top_bottom = 0;

for gradient_hour = 1:lastHour
    grid = malfunction_hour_list{gradient_hour};

    % calculate horizontal gradient
    left_to_right = diff(grid, 1, 2);
    left_to_right_steep = max(abs(left_to_right(:)));
    
    % calculate vert gradient
    top_to_bottom = diff(grid, 1 ,1);
    top_to_bottom_steep = max(abs(top_to_bottom(:)));
  
    %fprintf('LR gradient: %.2f\n\n', left_to_right_steep)
    %fprintf('TB gradient: %.2f\n\n', top_to_bottom_steep)

    % Keep track of hour with the steepest hor. gradient
    if left_to_right_steep > max_left_right
        max_left_right = left_to_right_steep;
        hour_left_right = gradient_hour;
    end

    % Keep track of hour with the steepest vert gradient
    if top_to_bottom_steep > max_top_bottom
        max_top_bottom = top_to_bottom_steep;
        hour_top_bottom = gradient_hour;
    end
end

fprintf('Malfunction Scenario\n')
fprintf('Steepest left-right gradient across all hours: %.2f occurs at hour %d\n', max_left_right, hour_left_right);
fprintf('Steepest top-bottom gradient across all hours: %.2f occurs at hour %d\n\n', max_top_bottom, hour_top_bottom);

% TASK 6

% calculate hourly temp changes and find avg for normal
normal_temp_change = diff(normal_matrix, 1, 1);
avg_normal_temp_change = mean(normal_temp_change, 2);
cumsum_avg_normal_temp_change = cumsum(avg_normal_temp_change);

% hour 20 - hour 1
normal_temp_rise_across_hours = normal_matrix(end,:) - normal_matrix(1,:);
[normal_fastest_rise, normal_sensor_num] = max(normal_temp_rise_across_hours);
fprintf('Normal Scenario\n')
fprintf('Fastest-warming sensor: %d, Total rise: %.2f°F\n\n', normal_sensor_num, normal_fastest_rise);

% repeat temp analysis for highload 
highload_temp_change = diff(highload_matrix, 1, 1);
avg_highload_temp_change = mean(highload_temp_change, 2);
cumsum_avg_highload_temp_change = cumsum(avg_highload_temp_change);
highload_temp_rise_across_hours = highload_matrix(end,:) - highload_matrix(1,:);
[highload_fastest_rise, highload_sensor_num] = max(highload_temp_rise_across_hours);
fprintf('Highload Scenario\n')
fprintf('Fastest-warming sensor: %d, Total rise: %.2f°F\n\n', highload_sensor_num, highload_fastest_rise);

% repeat temp analysis for malfunction 
malfunction_temp_change = diff(malfunction_matrix, 1 ,1);
avg_malfunction_temp_change = mean(malfunction_temp_change, 2);
cumsum_avg_malfunction_temp_change = cumsum(avg_malfunction_temp_change);
malfunction_temp_rise_across_hours = malfunction_matrix(end,:) - malfunction_matrix(1,:);
[malfunction_fastest_rise, malfunction_sensor_num] = max(malfunction_temp_rise_across_hours);
fprintf('Malfunction Scenario\n')
fprintf('Fastest-warming sensor: %d, Total rise: %.2f°F\n\n', malfunction_sensor_num, malfunction_fastest_rise);

% TASK 7

% stats for all sensors and hours for norm, higload, malfunction
overall_mean_normal = mean(normal_matrix(:));
overall_mean_highload = mean(highload_matrix(:));
overall_mean_malfunction = mean(malfunction_matrix(:));

overall_max_normal = max(normal_matrix(:));
overall_max_highload = max(highload_matrix(:));
overall_max_malfunction = max(malfunction_matrix(:));

overall_min_normal = min(normal_matrix(:));
overall_min_highload = min(highload_matrix(:));
overall_min_malfunction = min(malfunction_matrix(:));

overall_range_normal = overall_max_normal - overall_min_normal;
overall_range_highload = overall_max_highload - overall_min_highload;
overall_range_malfunction = overall_max_malfunction - overall_min_malfunction;

avg_normal_STD = mean(normal_STD);
avg_highload_STD = mean(highload_STD);
avg_malfunction_STD = mean(malfunction_STD);

% calculate percentage of readings above the 85°F 
percent_above_normal = sum(normal_matrix(:) > threshold) / numel(normal_matrix) * 100;
percent_above_highload = sum(highload_matrix(:) > threshold) / numel(highload_matrix) * 100;
percent_above_malfunction = sum(malfunction_matrix(:) > threshold) / numel(malfunction_matrix) * 100;

% organize into scenario table
Scenario = {'Normal'; 'HighLoad'; 'Malfunction'};
mean_temp = [overall_mean_normal; overall_mean_highload; overall_mean_malfunction];
max_temp = [overall_max_normal; overall_max_highload; overall_max_malfunction];
min_temp = [overall_min_normal; overall_min_highload; overall_min_malfunction];
range_temp = [overall_range_normal; overall_range_highload; overall_range_malfunction];
avg_uniformity = [avg_normal_STD; avg_highload_STD; avg_malfunction_STD];
percent_above_85 = [percent_above_normal; percent_above_highload; percent_above_malfunction];

summaryTable = table(Scenario, mean_temp, max_temp, min_temp, range_temp, avg_uniformity, percent_above_85);

disp(summaryTable)

% TASK 8

% calculate percentage inc in mean temp compared to normal scenario
perc_increase_HL = ((overall_mean_highload - overall_mean_normal) / overall_mean_normal) * 100;
perc_increase_MF = ((overall_mean_malfunction - overall_mean_normal) / overall_mean_normal) * 100;

fprintf('Percentage increase in mean temperature from Normal to HighLoad: %.2f%%\n', perc_increase_HL);
fprintf('Percentage increase in mean temperature from Normal to Malfunction: %.2f%%\n\n', perc_increase_MF);

% TASK 9

% calculate avg temp at each sensor location for every hour
avg_per_sensor_normal = mean(normal_matrix, 1);
avg_per_sensor_highload = mean(highload_matrix, 1);
avg_per_sensor_malfunction = mean(malfunction_matrix, 1);

% find overall avg temperature for each sensor across all three scenarios
avg_per_sensor_all = (avg_per_sensor_normal + avg_per_sensor_highload + avg_per_sensor_malfunction) / 3;

[sorted_avg_temps, sorted_indices] = sort(avg_per_sensor_all, 'descend');

% display the top 3 hot sensors with their grid poses
fprintf('Top 3 consistently hot sensors across all scenarios:\n');
for i = 1:3
    sensor_index = sorted_indices(i);
    [row, col] = ind2sub([nRows, nCols], sensor_index);
    fprintf('%d. Sensor at row %d, column %d: %.2f°F\n', i, row, col, sorted_avg_temps(i));
end

% TASK 10

% Create Results folder

resultsFolder = fullfile('Data', 'Results'); % create the path to the results folder

if ~exist(resultsFolder, 'dir') % if resultsFolder does not exist, create it
    mkdir(resultsFolder);
end

% save into .mat files inside "Results" folder
save(fullfile(resultsFolder, 'temperature_analysis.mat'));

% path for summary statistics CSV file
summaryFile = fullfile('Data', 'Scenarios', 'summary_statistics.csv');

% write summaryTable to CSV file
writetable(summaryTable, summaryFile);

% REFER TO README FOR COMPARATIVE ANALYSIS

%% PART THREE- Abigail

% Figure 1 - Heatmap comparison ( all three secnarios)

hour = 15;

normGrid = normalTempReadings(:, :, hour);
highGrid = highLoadTempReadings(:, :, hour);
malGrid = malfunctionTempReadings(:, :, hour);

f1 = figure; 
% first subplot
subplot(3, 1, 1)
imagesc(normGrid)
colorbar;
caxis([65, 95]);
colormap('hot');
title('Normal Tempurature Readings Heatmap')
xlabel('Sensor Number')
ylabel('Room Section')

% second sublot
subplot(3, 1, 2)
imagesc(highGrid)
colorbar;
caxis([65, 95]);
colormap('hot')
title("High Load Tempurature Readings Heatmap")
xlabel('Sensor Number')
ylabel('Room Section')

% third subplot
subplot(3, 1, 3)
imagesc(malGrid)
colorbar;
caxis([65, 95]);
colormap('hot')
title("Malfunction Tempurature Readings Heatmap")
xlabel('Sensor Number')
ylabel('Room Section')

% save figure to png 
saveas(f1, 'heatmap_comparison.png')

%% Figure 2 - Tempurature evolution at hot spots

f2 = figure;
hold on; 

% to find the top three sensors in the malfunction scenario:
% put them in descending order and then extract the top three values

average_temps = mean(malfunctionTable{:, 2:end}, 1);

% find the 2 hottest 

[vals, index] = sort(average_temps, 'descend');

sensor1Name = sensorNames(index(1));
sensor2Name = sensorNames(index(2));

% then extract column in from malfunction table by the name of the column
% to graph

sensor1Col = malfunctionTable.(sensor1Name);
sensor2Col = malfunctionTable.(sensor2Name);

hours = malfunctionTable.Hour; 

% plot hour vs temp for 2 hottest at all hours (over 20 hrs) 

scatter(hours, sensor1Col)
scatter(hours, sensor2Col, 'red')
yline(90, '--k')

legend(sensor1Name, sensor2Name);
grid on;

xlabel('Hour')
ylabel('Tempurature')

title('Hot Spot Tempurature over 20 Hours')
saveas(f2, 'hotspot_evolution.png')

%% Figure 3 
f3 = figure; 

allScenarios = {normalTempReadings, highLoadTempReadings, malfunctionTempReadings};

%front middle and back of the room zones
zones = {
    1:2;
    3:4;
    5:6;
    };

% 3 zones, bar chart with temp on y axis 

zoneMeans = zeros(3,3); 

for i = 1:3
    data = allScenarios{i}(:, :, hour);
    for f = 1:3
        zoneMeans(i, f) = mean(data(zones{i}, :), 'all');% get the mean for each scenario at each hour
    end
end

% make the bar chart
bar(zoneMeans)

%legend/ labels
set(gca, 'XTickLabel', {'Normal','High Load','Malfunction'}) 
legend('Back', 'Middle', 'Front') % section of room

title('Average Tempurature for Each Secnario at Different Sections of the Room')
ylabel("Tempurature (Deg Farenheight)")
xlabel('Scenario')
saveas(f3, 'zone_comparison.png')


%% Figure 4 

f4 = figure; 

% find temp mal at 1 hour (15 hr)

hour_15 = malfunctionTempReadings(:, :, 15);

subplot(1, 3, 1)
imagesc(hour_15)
colorbar
colormap('hot')
title('Original Tempurature Grid')
xlabel('Room section')
ylabel('Tempurature')

% subplot 2

subplot(1, 3, 2)

imagesc(abs(diff(hour_15, 1, 2)))
colorbar
colormap('hot')
title('Horizontal Tempurature Gradient')
xlabel('Room section')
ylabel('Tempurature')


% subplot 3 

subplot(1, 3, 3)

imagesc(abs(diff(hour_15, 1, 1)))
colorbar
colormap('hot')
title('Vertical Tempurature Gradient')
xlabel('Room section')
ylabel('Tempurature')


sgtitle('Gradient Visualizations of Hour 15')

saveas(f4, 'gradient_analysis.png')

%% Figure 5 
f5 = figure('Position', [100, 100, 1200, 800]);% make larger figure, not mentioned until 4th subplot but if you dont impliment it until then it looks wack

%first subplot
subplot(2, 2, 1)

% use squeeze to get row vectors

over85_normal = squeeze(sum(normalTempReadings > 85, [1, 2]));
over85_high = squeeze(sum(highLoadTempReadings > 85, [1, 2]));
over85_mal = squeeze(sum(malfunctionTempReadings > 85, [1, 2]));

hours = 1:20; % hours i 1 to 20 inclusive vector

% plot three lines on first subplot

hold on;
plot(hours, over85_normal)
plot(hours, over85_high, 'red')
plot(hours, over85_mal, 'green')
grid on;
title("Hot Sensor Count Over Time")
ylabel("Num of Sensors Over 85 Deg")
xlabel("Hour")
legend('Normal', 'High Load', 'Malfunction', 'Location', 'best')
hold off;

% second subplot

subplot(2, 2, 2)

% range: squeeze the max and subtract the min to get the range

range_normal = squeeze(max(normalTempReadings, [], [1, 2]) - min(normalTempReadings, [], [1, 2]));
range_high = squeeze(max(highLoadTempReadings, [], [1, 2]) - min(highLoadTempReadings, [], [1, 2]));
range_mal = squeeze(max(malfunctionTempReadings, [], [1, 2]) - min(malfunctionTempReadings, [], [1, 2]));

hold on; 

% plot all scenarios
plot(hours, range_normal)
plot(hours, range_high)
plot(hours, range_mal)

grid on;

%labels
title('Tempurature Range Over Time For All Scenarios')
ylabel("Max temp - Min Temp")
xlabel("Hour")
legend('Normal', 'High Load', 'Malfunction', 'Location', 'best')

hold off;

% subplot three

subplot(2, 2, 3)

%make vectors
avg_normal = squeeze(mean(normalTempReadings, [1, 2]));
avg_high = squeeze(mean(highLoadTempReadings, [1, 2]));
avg_mal = squeeze(mean(malfunctionTempReadings, [1, 2]));

%plot graph
grid on;
hold on;
plot(hours, avg_normal)
plot(hours, avg_high)
plot(hours, avg_mal)

% threshold line 
yline(75, '--k')

hold off;

% lables
title("Average Tempurature Over Time")
xlabel("Hour")
ylabel("Tempurature")
legend('Normal', 'High Load', 'Malfunction', 'Location', 'best')

% fourth subplot

subplot(2, 2, 4)
grid on;

% heatmap of hour 20 in mal scenario

imagesc(malfunctionTempReadings(:, :, 20))
colorbar
colormap('hot')

%Lables
title("Heatmap for Malfunction Scenario @ Hour 20")
xlabel('Sensor Column Number')
ylabel("Sensor Row Number")

saveas(f5, 'alert_dashboard.png')