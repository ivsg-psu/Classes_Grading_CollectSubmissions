%% Introduction to and Purpose of the Code
% This is the explanation of the code that can be found by running
%
%       script_demo_CollectSubmissions.m
%
% This is a script to demonstrate the functions within the CollectSubmissions code
% library. This code repo is typically located at:
%
%   https://github.com/ivsg-psu/Classes_Grading_CollectCloudMirror
%
% If you have questions or comments, please contact Sean Brennan at
% sbrennan@psu.edu
%
% This code repo contains tools that do the following steps:
%
% * Downloads student folders from OneDrive
%
% * Compares these submissions to a local copy, identifying any differences
%
% * For files/directories that are different, creates a backup copy of the
% old version
%
% * Keeps a tally of which submissions are complete
% 
% * Send emails to students automatically that their submissions were
% received
% 
% As well, step-by-step instructions for using this code are provided in
% the README.md file.

% REVISION HISTORY:
% 
% 2026_01_09 by Sean Brennan, sbrennan@psu.edu
% - Created the first version for use in the Vehicle Dynamics course
%
% 2026_01_16 by Sean Brennan, sbrennan@psu.edu
% - Wrote fcn_CollectSubmissions_confirmSubmissions
%   % * Used archiveChanges as starter
%   % * This is a function that emails students to confirm submissions
%   % * Lets users know that the file(s) were received 
%   % * How it works:
%   %   % * Loops through change list between cloud and local mirror, 
%   %   % * Finds if any match an assignment string, 
%   %   % * Checks if the user preferences indicate that confirmations are
%   %   %   % desired.
%   %   % * Sends confirmation emails to the associated emails 
% - Wrote fcn_CollectSubmissions_setRcloneFolder
%   % * Sets the path to the local install of the rclone software based on 
%   %   % the current computer
%
% (new release)
%
% 2026_01_23 by Sean Brennan, sbrennan@psu.edu
% - In main script
%   % * Simplified the call sequence to match, exactly, the usage expected
%   %   % in practice
% - Wrote fcn_CollectSubmissions_confirmGrades
%   % * Used confirmSubmissions as starter
%   % * This is a function that emails students to let them know grades
%   % * How it works:
%   %   % * Loops through change list between cloud and local mirror, 
%   %   % * Finds if any match an assignment string, 
%   %   % * Checks if the user preferences indicate that grades are
%   %   %   % desired.
%   %   % * Sends summary emails to the associated emails 
% - In fcn_CollectSubmissions_confirmSubmissions
%   % * Updated to use correct preferences field
%   % * Updated to send verifications on modification AND addition
%   % * Fixed bug where PSU email used, not preferred email. Now using
%   %   % preferred email.
% - In fcn_CollectSubmissions_updateLog
%   % * Added plotting of results
%   % * Added automatic header if new log is being made
% - Wrote fcn_CollectSubmissions_gradeAssignment
%   % * Used fcn_CollectSubmissions_confirmSubmissions as starter
%   % * Grades assignments and enters results into the student roster
%
% (new release)
%
% 2026_01_24 by Sean Brennan, sbrennan@psu.edu
% - In fcn_CollectSubmissions_updateLog
%   % * Changed plot style to see locations of data collection
%
% (new release)
%
% 2026_01_24 by Sean Brennan, sbrennan@psu.edu
% - In fcn_CollectSubmissions_setRcloneFolder
%   % * Updated folder for E5-ME-SEBR02
%
% (new release)
%
% 2026_01_25 by Sean Brennan, sbrennan@psu.edu
% - In fcn_CollectSubmissions_updateLog
%   % * Removed unused function
%   % * Removed debug supression comment that is now unneeded
% - In fcn_CollectSubmissions_confirmGrades
%   % * Added a debug mode where students are NEVER emailed unless -1 is
%   %   % passed as the figure number.
%   % * Emails snb10+debug@psu.edu as debug email
% - In fcn_CollectSubmissions_confirmSubmissions
%   % * Added a debug mode where students are NEVER emailed unless -1 is
%   %   % passed as the figure number.
%   % * Emails snb10+debug@psu.edu as debug email
% - In fcn_CollectSubmissions_downloadFolders
%   % * Added more detail to input arguments, for clarity
%
% (new release)
%
% 2026_01_25 by Sean Brennan, sbrennan@psu.edu
% - In fcn_CollectSubmissions_loopOverCollections
%   % * Addes safeMode for student emails
%
% (new release)
%
% 2026_01_25 by Sean Brennan, sbrennan@psu.edu
% - In fcn_CollectSubmissions_confirmGrades
%   % * Fixed bug where -1 was used to cause safeMode, causing errors with
%   %   % fastMode. Fixed to use -10 instead.
% - In fcn_CollectSubmissions_confirmSubmissions
%   % * Fixed bug where -1 was used to cause safeMode, causing errors with
%   %   % fastMode. Fixed to use -10 instead.
% - In fcn_CollectSubmissions_loopOverCollections
%   % * Fixed bug where -1 was used to cause safeMode, causing errors with
%   %   % fastMode. Fixed to use -10 instead.
%
% (new release)
%

% TO-DO:
% - 2026_01_09 by Sean Brennan, sbrennan@psu.edu
%   * (add items here)


%% Make sure we are running out of root directory
st = dbstack; 
thisFile = which(st(1).file);
[filepath,name,ext] = fileparts(thisFile);
cd(filepath);

%%% START OF STANDARD INSTALLER CODE %%%%%%%%%

%% Clear paths and folders, if needed
if 1==1
    clear flag_CollectSubmissions_Folders_Initialized
end

if 1==0
    fcn_INTERNAL_clearUtilitiesFromPathAndFolders;
end

if 1==0
    % Resets all paths to factory default
    restoredefaultpath;
end

%% Install dependencies
% Define a universal resource locator (URL) pointing to the repos of
% dependencies to install. Note that DebugTools is always installed
% automatically, first, even if not listed:
clear dependencyURLs dependencySubfolders
ith_repo = 0;

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/Classes_Grading_LoadRoster';
dependencySubfolders{ith_repo} = {'Functions','Data'};
 
% ith_repo = ith_repo+1;
% dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_PlotRoad';
% dependencySubfolders{ith_repo} = {'Functions','Data'};

% ith_repo = ith_repo+1;
% dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_GeomTools_GeomClassLibrary';
% dependencySubfolders{ith_repo} = {'Functions','Data'};

% ith_repo = ith_repo+1;
% dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_MapTools_MapGenClassLibrary';
% dependencySubfolders{ith_repo} = {'Functions','testFixtures','GridMapGen'};



%% Do we need to set up the work space?
if ~exist('flag_CollectSubmissions_Folders_Initialized','var')
    
    % Clear prior global variable flags
    clear global FLAG_*

    % Navigate to the Installer directory
    currentFolder = pwd;
    cd('Installer');
    % Create a function handle
    func_handle = @fcn_DebugTools_autoInstallRepos;

    % Return to the original directory
    cd(currentFolder);

    % Call the function to do the install
    func_handle(dependencyURLs, dependencySubfolders, (0), (-1));

    % Add this function's folders to the path
    this_project_folders = {...
        'Functions','Data'};
    fcn_DebugTools_addSubdirectoriesToPath(pwd,this_project_folders)

    flag_CollectSubmissions_Folders_Initialized = 1;
end

%%% END OF STANDARD INSTALLER CODE %%%%%%%%%

%% Set environment flags for input checking in Laps library
% These are values to set if we want to check inputs or do debugging
setenv('MATLABFLAG_COLLECTSUBMISSIONS_FLAG_CHECK_INPUTS','1');
setenv('MATLABFLAG_COLLECTSUBMISSIONS_FLAG_DO_DEBUG','0');

%% Set environment flags that define the ENU origin
% This sets the "center" of the ENU coordinate system for all plotting
% functions
% Location for Test Track base station
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.86368573');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-77.83592832');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','344.189');


%% Set environment flags for plotting
% These are values to set if we are forcing image alignment via Lat and Lon
% shifting, when doing geoplot. This is added because the geoplot images
% are very, very slightly off at the test track, which is confusing when
% plotting data
setenv('MATLABFLAG_PLOTROAD_ALIGNMATLABLLAPLOTTINGIMAGES_LAT','-0.0000008');
setenv('MATLABFLAG_PLOTROAD_ALIGNMATLABLLAPLOTTINGIMAGES_LON','0.0000054');

%% Start of Demo Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____ _             _            __   _____                          _____          _
%  / ____| |           | |          / _| |  __ \                        / ____|        | |
% | (___ | |_ __ _ _ __| |_    ___ | |_  | |  | | ___ _ __ ___   ___   | |     ___   __| | ___
%  \___ \| __/ _` | '__| __|  / _ \|  _| | |  | |/ _ \ '_ ` _ \ / _ \  | |    / _ \ / _` |/ _ \
%  ____) | || (_| | |  | |_  | (_) | |   | |__| |  __/ | | | | | (_) | | |___| (_) | (_| |  __/
% |_____/ \__\__,_|_|   \__|  \___/|_|   |_____/ \___|_| |_| |_|\___/   \_____\___/ \__,_|\___|
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Start%20of%20Demo%20Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Welcome to the demo code for the CollectSubmissions library!')

%% Create test folders?
% Done once
if 1==1

	%%%%%%%%%%%%%%%%%%%%%%%%%%
	fprintf(1,'Loading the class roster.\n');
	CSVPath = fullfile(cd,'Data','roster_2026_01_19.csv');
	emailForAddedTestStudents = 'snb10@psu.edu';
	rosterTable = fcn_LoadRoster_rosterTableFromCSV(CSVPath, (emailForAddedTestStudents), (1));



	%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Create the mirror folder
	fprintf(1,'Preparing the CloudMirror folders.\n');
	pathToMirrorFolder = fullfile(pwd,'Data','CloudMirror');

	if 1==1
		if exist(pathToMirrorFolder,'dir')
			% Remove the directory
			rmdir(pathToMirrorFolder, 's');
		end
		assert(~exist(pathToMirrorFolder,'dir'));
	end

	if ~exist(pathToMirrorFolder,'dir')
		% Create the student directories
		fprintf(1,'Creating student template folders in the data folder.\n');
		fcn_LoadRoster_createSubmissionFolders(pathToMirrorFolder, rosterTable, (1))
	end
	assert(exist(pathToMirrorFolder,'dir'));


	%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Create the archive folder
	fprintf(1,'Preparing the Archive folders.\n');
	pathToArchiveFolder = fullfile(pwd,'Data','Archive');

	if 1==1
		if exist(pathToArchiveFolder,'dir')
			% Remove the directory
			rmdir(pathToArchiveFolder, 's');
		end
		assert(~exist(pathToArchiveFolder,'dir'));
	end

	if ~exist(pathToArchiveFolder,'dir')
		% Create the student directories
		fprintf(1,'Creating archive folders in the data folder.\n');
		fcn_LoadRoster_createSubmissionFolders(pathToArchiveFolder, rosterTable, (1))
	end
	assert(exist(pathToArchiveFolder,'dir'));

end % Ends done-once items

%% Set variables
% Make sure to run rclone config and use the OneDrivePSU as the name to
% point to the PSU OneDrive account
%
% Command to check folder:
% rclone lsd --max-depth 1 "OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions"

rcloneFolder = fcn_CollectSubmissions_setRcloneFolder;
cloudFolder = 'OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions';
localFolder = fullfile(pwd,'Data','CloudMirror');
archiveFolder = fullfile(pwd,'Data','Archive');
subFolderArchive = [];
flagArchiveEqualFiles = [];
assignmentFileString = 'SUBMISSION_Week01_HW01_';
gradingFunction = @fcn_INTERNAL_gradeAssignment;
assignmentString = 'Week01_HW01';
logFile     = fullfile(pwd,'Data','logFile.csv');
logSubFolder = '';
figNum = 10001;

%% Loop through time, gathering, grading, and emailing submissions

if exist('blockingFile.txt','file')
	delete('blockingFile.txt');
end

while 1==1
	clc;
	fprintf(1, '\nSTARTING TURN: %.0f\n', ith_turn);
	if exist('blockingFile.txt','file')
		fprintf(1, 'Process is being blocked ... waiting.\n');
	else
		% Create a blocking file
		fcn_DebugTools_fileTouch('blockingFile.txt');

		%%%% fcn_CollectSubmissions_downloadFolders
		fprintf(1,'Downloading the class submissions from the cloud.\n');
		% figure(figNum); clf;

		startTime = datetime('now');

		% Call the function
		[fileContent, flagWasSuccessful, errorMsg, timeString, ~] = ...
			fcn_CollectSubmissions_downloadFolders(rcloneFolder, cloudFolder, localFolder, startTime, (figNum));

		%%%% fcn_CollectSubmissions_archiveChanges
		fprintf(1,'Archiving submissions.\n');

		%%%%%%%%%%
		% Call the function
		totalsCollected = ...
			fcn_CollectSubmissions_archiveChanges(...
			fileContent, localFolder, archiveFolder, timeString, ...
			(subFolderArchive), (flagArchiveEqualFiles), (figNum));

		%%%% fcn_CollectSubmissions_gatherSubmissionsIntoTable
		fprintf(1,'Gathering submissions.\n');


		%%%%%%
		% Gather all results into a table
		ungradedSubmissionTable = ...
			fcn_CollectSubmissions_gatherSubmissionsIntoTable(fileContent, assignmentFileString, localFolder, (figNum));

		%%%% fcn_CollectSubmissions_gradeAssignment
		fprintf(1,'Grading submissions.\n');

		%  Call the function
		gradedRosterTable = ...
			fcn_CollectSubmissions_gradeAssignment(assignmentString, rosterTable, ungradedSubmissionTable, gradingFunction, (figNum));


		%%%% fcn_CollectSubmissions_confirmSubmissions
		fprintf(1,'Confirming submissions.\n');

		%%%%%%%%%%
		% Call the function
		confirmedGradedRosterTable = ...
			fcn_CollectSubmissions_confirmSubmissions(...
			fileContent, gradedRosterTable, (assignmentString), (figNum));


		%%%% fcn_CollectSubmissions_confirmGrades
		fprintf(1,'Confirming grades.\n');

		%%%%%%%%%%
		% Call the function
		finalGradedRosterTable = ...
			fcn_CollectSubmissions_confirmGrades(...
			fileContent, confirmedGradedRosterTable, (assignmentString), (figNum));

		%%%% fcn_CollectSubmissions_updateLog
		fprintf(1,'Updating the log file.\n');

		endTime = datetime('now');
		processDuration = seconds(endTime - startTime);

		% Call the function
		fcn_CollectSubmissions_updateLog(logFile, endTime, processDuration, flagWasSuccessful, logSubFolder, totalsCollected, (figNum))


		rosterTable = finalGradedRosterTable;

		% Delete the blocking file
		delete('blockingFile.txt');


	end % Ends check for blocking file
	
	pause(10);
end

%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§

%% function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
% Clear out the variables
clear global flag* FLAG*
clear flag*
clear path

% Clear out any path directories under Utilities
path_dirs = regexp(path,'[;]','split');
utilities_dir = fullfile(pwd,filesep,'Utilities');
for ith_dir = 1:length(path_dirs)
    utility_flag = strfind(path_dirs{ith_dir},utilities_dir);
    if ~isempty(utility_flag)
        rmpath(path_dirs{ith_dir});
    end
end

% Delete the Utilities folder, to be extra clean!
if  exist(utilities_dir,'dir')
    [status,message,message_ID] = rmdir(utilities_dir,'s');
    if 0==status
        error('Unable remove directory: %s \nReason message: %s \nand message_ID: %s\n',utilities_dir, message,message_ID);
    end
end

end % Ends fcn_INTERNAL_clearUtilitiesFromPathAndFolders


% %% fcn_INTERNAL_loadExampleData
% function CSVpath = fcn_INTERNAL_loadExampleData_rosterTableFromCSV
% 
% % Use the last data
% CSVpath = fullfile(cd,'Data','roster_2026_01_06.csv');
% end % Ends fcn_INTERNAL_loadExampleData

%% fcn_INTERNAL_gradeAssignment
function [percent, comments] = fcn_INTERNAL_gradeAssignment(answers)
numAnswers = length(answers);
percent = 0;
for ith_answer = 1:numAnswers
	percent = percent + 1/numAnswers;
	comments{ith_answer} = sprintf('Prob %.0f: correct',ith_answer);
end
end % ends fcn_INTERNAL_gradeAssignment

