
%% Introduction to and Purpose of the Code
% This is the explanation of the code that can be found by running
%       script_demo_LoadRoster.m
% This is a script to demonstrate the functions within the LoadRoster code
% library. This code repo is typically located at:
%
%   https://github.com/ivsg-psu/Classes_Grading_LoadRoster
%
% If you have questions or comments, please contact Sean Brennan at
% sbrennan@psu.edu
%
% This code repo contains tools that prepare a course's roster for use in
% the automated grading tools used by Dr. Brennan in his courses. These
% tools require a roster of student names, emails, and ID numbers. As well,
% the tools require directories to be formed with student-specific
% information (typically, the student number), and students to be contacted
% with this information. This repo contains codes that:
% 
% * Convert a downloaded CSV roster into MATLAB table formats for automated
% use
% 
% * Automatically create student-specific directories for students to send
% or receive items, for example to provide students with specific codes or
% to receive graded items from students
% 
% * Send emails to students automatically (using MATLAB) so they have
% access information to their folders
% 
% As well, step-by-step instructions for using this code are provided in
% the README.md file.

% REVISION HISTORY:
% 
% 2026_01_06 by Sean Brennan, sbrennan@psu.edu
% - Created the first version for use in the Vehicle Dynamics course
% (new release)


% TO-DO:
% - 2026_01_06 by Sean Brennan, sbrennan@psu.edu
%   (add to-do items here)


%% Make sure we are running out of root directory
st = dbstack; 
thisFile = which(st(1).file);
[filepath,name,ext] = fileparts(thisFile);
cd(filepath);

%%% START OF STANDARD INSTALLER CODE %%%%%%%%%

%% Clear paths and folders, if needed
if 1==1
    clear flag_LoadRoster_Folders_Initialized
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
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary';
dependencySubfolders{ith_repo} = {'Functions','Data'};
 
ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_PathTools_GetUserInputPath';
dependencySubfolders{ith_repo} = {''};
 
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
if ~exist('flag_LoadRoster_Folders_Initialized','var')
    
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

    flag_LoadRoster_Folders_Initialized = 1;
end

%%% END OF STANDARD INSTALLER CODE %%%%%%%%%

%% Set environment flags for input checking in Laps library
% These are values to set if we want to check inputs or do debugging
setenv('MATLABFLAG_LOADROSTER_FLAG_CHECK_INPUTS','1');
setenv('MATLABFLAG_LOADROSTER_FLAG_DO_DEBUG','0');

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

disp('Welcome to the demo code for the LoadRoster library!')


%% fcn_LoadRoster_rosterTableFromCSV
figNum = 10001;
titleString = sprintf('fcn_LoadRoster_rosterTableFromCSV');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
% figure(figNum); clf;

% Load some test data
CSVPath = fcn_INTERNAL_loadExampleData_rosterTableFromCSV;

rosterTable = fcn_LoadRoster_rosterTableFromCSV(CSVPath, (figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(istable(rosterTable));

% Check variable sizes
Nstudents = 34;
assert(height(rosterTable)==Nstudents);

% % Check variable values
% % Are the laps starting at expected points?
% assert(isequal(2,min(cell_array_of_lap_indices{1})));
% assert(isequal(102,min(cell_array_of_lap_indices{2})));
% assert(isequal(215,min(cell_array_of_lap_indices{3})));
% 
% % Make sure plot opened up
% assert(isequal(get(gcf,'Number'),figNum));

%% fcn_LoadRoster_createSubmissionFolders
figNum = 10001;
titleString = sprintf('fcn_LoadRoster_createSubmissionFolders');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
% figure(figNum); clf;

rootPath = fullfile(pwd,'Data','StudentSubmissions');

if exist(rootPath,'dir')
    % Remove the directory
    rmdir(rootPath, 's');
end

assert(~exist(rootPath,'dir'));

% Load some test data
rosterTable = fcn_INTERNAL_loadExampleData_createSubmissionFolders;

% Call the function
fcn_LoadRoster_createSubmissionFolders(rootPath, rosterTable, (figNum))

assert(exist(rootPath,'dir'));

% Remove the directory
rmdir(rootPath, 's');

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


%% fcn_INTERNAL_loadExampleData
function CSVpath = fcn_INTERNAL_loadExampleData_rosterTableFromCSV

% Use the last data
CSVpath = fullfile(cd,'Data','roster_2026_01_06.csv');
end % Ends fcn_INTERNAL_loadExampleData
