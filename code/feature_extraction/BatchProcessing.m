

% Start with a folder and get a list of all subfolders.
% Finds and prints names of all PNG, JPG, and TIF images in 
% that folder and all of its subfolders.
clc;    % Clear the command window.
workspace;  % Make sure the workspace panel is showing.
format longg;
format compact;

% Define a starting folder.
start_path = fullfile('C:\Users\Said\Desktop\PhD\matlab-hr-experiments\ILKYAR');
% Ask user to confirm or change.
topLevelFolder = uigetdir(start_path);
if topLevelFolder == 0
	return;
end
% Get list of all subfolders.
allSubFolders = genpath(topLevelFolder);
% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};
while true
	[singleSubFolder, remain] = strtok(remain, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames)

% Process all image files in those folders.
for k = 1 : numberOfFolders
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k};
	fprintf('Processing folder %s\n', thisFolder);
	
	% Get PNG files.
	filePattern = sprintf('%s/*EDA.csv', thisFolder);
	baseFileNames = dir(filePattern);  
	% Add on TIF files.
	filePattern1 = sprintf('%s/*HR.csv', thisFolder);
	baseFileNames = [baseFileNames; dir(filePattern1)];
	% Add on JPG files.
	filePattern2 = sprintf('%s/*IBI.csv', thisFolder);
	baseFileNames = [baseFileNames; dir(filePattern2)];
    
    filePattern3 = sprintf('%s/*TEMP.csv', thisFolder);
	baseFileNames = [baseFileNames; dir(filePattern3)];
    
    filePattern4 = sprintf('%s/*ACC.csv', thisFolder);
	baseFileNames = [baseFileNames; dir(filePattern4)];
    
    filePattern5 = sprintf('%s/*BVP.csv', thisFolder);
	baseFileNames = [baseFileNames; dir(filePattern5)];
	numberOfImageFiles = length(baseFileNames);
	% Now we have a list of all files in this folder.
	
	if numberOfImageFiles >= 1
		% Go through all those image files.
		for f = 1 : numberOfImageFiles
			fullFileName = fullfile(thisFolder, baseFileNames(f).name);
			fprintf('     Processing image file %s\n', fullFileName);
            
            
            % Added for Russell label and timestamp parsing
            
            %filename = fullfile(thisFolder, 'SuccessEvents.csv');
            %IBI = csvread(filename,2,1);
            %timestampArr=IBI(:,2);
            %labelArr=IBI(:,1);
            %lengthOf=length(labelArr);
            
            %labelArr is puzzle difficulty and lengthOf is the length of
            %this array.
            
            splitCsvFile(fullFileName,'A01B22',6,[2400,900,600,960,240,480])
		end
	else
		fprintf('     Folder %s has no image files in it.\n', thisFolder);
	end
end

