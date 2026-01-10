% script_test_fcn_CollectSubmissions_archiveChanges.m
% tests fcn_CollectSubmissions_archiveChanges.m

% REVISION HISTORY:
%
% 2026_01_09 by Sean Brennan, sbrennan@psu.edu
% - wrote the code originally, using breakDataIntoLaps as starter

% TO-DO:
%
% 2026_01_09 by Sean Brennan, sbrennan@psu.edu
% - (fill in items here)


%% Set up the workspace
close all

%% Code demos start here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____                              ____   __    _____          _
%  |  __ \                            / __ \ / _|  / ____|        | |
%  | |  | | ___ _ __ ___   ___  ___  | |  | | |_  | |     ___   __| | ___
%  | |  | |/ _ \ '_ ` _ \ / _ \/ __| | |  | |  _| | |    / _ \ / _` |/ _ \
%  | |__| |  __/ | | | | | (_) \__ \ | |__| | |   | |___| (_) | (_| |  __/
%  |_____/ \___|_| |_| |_|\___/|___/  \____/|_|    \_____\___/ \__,_|\___|
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Demos%20Of%20Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 1

close all;
fprintf(1,'Figure: 1XXXXXX: DEMO cases\n');

%% DEMO case: basic example with defaults
figNum = 10001;
titleString = sprintf('DEMO case: basic example with defaults');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
% figure(figNum); clf;

% Make sure to run rclone config and use the OneDrivePSU as the name to
% point to the PSU OneDrive account
%
% Command to check folder:
% rclone lsd --max-depth 1 "OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions"

rcloneFolder = 'C:\rclone-v1.68.2-windows-amd64';
cloudFolder = 'OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions';
localFolder = fullfile(pwd,'Data','StudentSubmissions');
archiveFolder = fullfile(pwd,'Data','Archive');


[fileContent, ~, ~, timeString, ~] = ...
    fcn_CollectSubmissions_downloadFolders(rcloneFolder, cloudFolder, localFolder, syncTime, (-1));

subFolder = [];
flagArchiveEqualFiles = [];


%%%%%%%%%%
% Call the function
[totalSame, totalAdded, totalDeleted, totalModified, totalErrored] = ...
    fcn_CollectSubmissions_archiveChanges(...
    fileContent, localFolder, archiveFolder, timeString, ...
    (subFolder), (flagArchiveEqualFiles), (figNum));

% sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(totalSame));
assert(isnumeric(totalAdded));
assert(isnumeric(totalDeleted));
assert(isnumeric(totalModified));
assert(isnumeric(totalErrored));

% Check variable sizes
assert(isequal(size(totalSame),[1 1]));
assert(isequal(size(totalAdded),[1 1]));
assert(isequal(size(totalDeleted),[1 1]));
assert(isequal(size(totalModified),[1 1]));
assert(isequal(size(totalErrored),[1 1]));

% % Check variable values
% % Are the laps starting at expected points?
% assert(isequal(2,min(cell_array_of_lap_indices{1})));
% assert(isequal(102,min(cell_array_of_lap_indices{2})));
% assert(isequal(215,min(cell_array_of_lap_indices{3})));

% % Make sure plot opened up
% assert(isequal(get(gcf,'Number'),figNum));


%% DEMO case: basic example with flagArchiveEqualFiles true
figNum = 10002;
titleString = sprintf('DEMO case: basic example with flagArchiveEqualFiles true');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
% figure(figNum); clf;

% Make sure to run rclone config and use the OneDrivePSU as the name to
% point to the PSU OneDrive account
%
% Command to check folder:
% rclone lsd --max-depth 1 "OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions"

rcloneFolder = 'C:\rclone-v1.68.2-windows-amd64';
cloudFolder = 'OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions';
localFolder = fullfile(pwd,'Data','StudentSubmissions');
archiveFolder = fullfile(pwd,'Data','Archive');


[fileContent, ~, ~, timeString, ~] = ...
    fcn_CollectSubmissions_downloadFolders(rcloneFolder, cloudFolder, localFolder, syncTime, (-1));

subFolder = '';
flagArchiveEqualFiles = true;


%%%%%%%%%%
% Call the function
[totalSame, totalAdded, totalDeleted, totalModified, totalErrored] = ...
    fcn_CollectSubmissions_archiveChanges(...
    fileContent, localFolder, archiveFolder, timeString, ...
    (subFolder), (flagArchiveEqualFiles), (figNum));

% sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(totalSame));
assert(isnumeric(totalAdded));
assert(isnumeric(totalDeleted));
assert(isnumeric(totalModified));
assert(isnumeric(totalErrored));

% Check variable sizes
assert(isequal(size(totalSame),[1 1]));
assert(isequal(size(totalAdded),[1 1]));
assert(isequal(size(totalDeleted),[1 1]));
assert(isequal(size(totalModified),[1 1]));
assert(isequal(size(totalErrored),[1 1]));

% % Check variable values
% % Are the laps starting at expected points?
% assert(isequal(2,min(cell_array_of_lap_indices{1})));
% assert(isequal(102,min(cell_array_of_lap_indices{2})));
% assert(isequal(215,min(cell_array_of_lap_indices{3})));
% 
% % Make sure plot opened up
% assert(isequal(get(gcf,'Number'),figNum));



%% DEMO case: basic example with subFolder
figNum = 10003;
titleString = sprintf('DEMO case: basic example with subFolder');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
% figure(figNum); clf;

% Make sure to run rclone config and use the OneDrivePSU as the name to
% point to the PSU OneDrive account
%
% Command to check folder:
% rclone lsd --max-depth 1 "OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions"

rcloneFolder = 'C:\rclone-v1.68.2-windows-amd64';
cloudFolder = 'OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions';
localFolder = fullfile(pwd,'Data','StudentSubmissions');
archiveFolder = fullfile(pwd,'Data','Archive');


[fileContent, ~, ~, timeString, ~] = ...
    fcn_CollectSubmissions_downloadFolders(rcloneFolder, cloudFolder, localFolder, syncTime, (-1));

subFolder = 'DummyFolder';
flagArchiveEqualFiles = [];


%%%%%%%%%%
% Call the function
[totalSame, totalAdded, totalDeleted, totalModified, totalErrored] = ...
    fcn_CollectSubmissions_archiveChanges(...
    fileContent, localFolder, archiveFolder, timeString, ...
    (subFolder), (flagArchiveEqualFiles), (figNum));

% sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(totalSame));
assert(isnumeric(totalAdded));
assert(isnumeric(totalDeleted));
assert(isnumeric(totalModified));
assert(isnumeric(totalErrored));

% Check variable sizes
assert(isequal(size(totalSame),[1 1]));
assert(isequal(size(totalAdded),[1 1]));
assert(isequal(size(totalDeleted),[1 1]));
assert(isequal(size(totalModified),[1 1]));
assert(isequal(size(totalErrored),[1 1]));

% Check variable values
assert(totalSame == 0);
assert(totalAdded == 0);
assert(totalDeleted == 0);
assert(totalModified == 0);
assert(totalErrored == 0);

% % Make sure plot opened up
% assert(isequal(get(gcf,'Number'),figNum));



%% Test cases start here. These are very simple, usually trivial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  _______ ______  _____ _______ _____
% |__   __|  ____|/ ____|__   __/ ____|
%    | |  | |__  | (___    | | | (___
%    | |  |  __|  \___ \   | |  \___ \
%    | |  | |____ ____) |  | |  ____) |
%    |_|  |______|_____/   |_| |_____/
%
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 2

close all;
fprintf(1,'Figure: 2XXXXXX: TEST mode cases\n');

% %% TEST case: This one returns nothing since there is no portion of the path in criteria
% figNum = 20001;
% titleString = sprintf('TEST case: This one returns nothing since there is no portion of the path in criteria');
% fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
% figure(figNum); clf;
% 


%% Fast Mode Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ______        _     __  __           _        _______        _
% |  ____|      | |   |  \/  |         | |      |__   __|      | |
% | |__ __ _ ___| |_  | \  / | ___   __| | ___     | | ___  ___| |_ ___
% |  __/ _` / __| __| | |\/| |/ _ \ / _` |/ _ \    | |/ _ \/ __| __/ __|
% | | | (_| \__ \ |_  | |  | | (_) | (_| |  __/    | |  __/\__ \ |_\__ \
% |_|  \__,_|___/\__| |_|  |_|\___/ \__,_|\___|    |_|\___||___/\__|___/
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Fast%20Mode%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 8

close all;
fprintf(1,'Figure: 8XXXXXX: FAST mode cases\n');

%% Basic example - NO FIGURE
figNum = 80001;
fprintf(1,'Figure: %.0f: FAST mode, empty figNum\n',figNum);
figure(figNum); close(figNum);

% Make sure to run rclone config and use the OneDrivePSU as the name to
% point to the PSU OneDrive account
%
% Command to check folder:
% rclone lsd --max-depth 1 "OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions"

rcloneFolder = 'C:\rclone-v1.68.2-windows-amd64';
cloudFolder = 'OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions';
localFolder = fullfile(pwd,'Data','StudentSubmissions');
archiveFolder = fullfile(pwd,'Data','Archive');


[fileContent, ~, ~, timeString, ~] = ...
    fcn_CollectSubmissions_downloadFolders(rcloneFolder, cloudFolder, localFolder, syncTime, (-1));

subFolder = [];
flagArchiveEqualFiles = [];


%%%%%%%%%%
% Call the function
[totalSame, totalAdded, totalDeleted, totalModified, totalErrored] = ...
    fcn_CollectSubmissions_archiveChanges(...
    fileContent, localFolder, archiveFolder, timeString, ...
    (subFolder), (flagArchiveEqualFiles), ([]));

% sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(totalSame));
assert(isnumeric(totalAdded));
assert(isnumeric(totalDeleted));
assert(isnumeric(totalModified));
assert(isnumeric(totalErrored));

% Check variable sizes
assert(isequal(size(totalSame),[1 1]));
assert(isequal(size(totalAdded),[1 1]));
assert(isequal(size(totalDeleted),[1 1]));
assert(isequal(size(totalModified),[1 1]));
assert(isequal(size(totalErrored),[1 1]));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Basic fast mode - NO FIGURE, FAST MODE
figNum = 80002;
fprintf(1,'Figure: %.0f: FAST mode, figNum=-1\n',figNum);
figure(figNum); close(figNum);

% Make sure to run rclone config and use the OneDrivePSU as the name to
% point to the PSU OneDrive account
%
% Command to check folder:
% rclone lsd --max-depth 1 "OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions"

rcloneFolder = 'C:\rclone-v1.68.2-windows-amd64';
cloudFolder = 'OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions';
localFolder = fullfile(pwd,'Data','StudentSubmissions');
archiveFolder = fullfile(pwd,'Data','Archive');


[fileContent, ~, ~, timeString, ~] = ...
    fcn_CollectSubmissions_downloadFolders(rcloneFolder, cloudFolder, localFolder, syncTime, (-1));

subFolder = [];
flagArchiveEqualFiles = [];


%%%%%%%%%%
% Call the function
[totalSame, totalAdded, totalDeleted, totalModified, totalErrored] = ...
    fcn_CollectSubmissions_archiveChanges(...
    fileContent, localFolder, archiveFolder, timeString, ...
    (subFolder), (flagArchiveEqualFiles), (-1));

% sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(totalSame));
assert(isnumeric(totalAdded));
assert(isnumeric(totalDeleted));
assert(isnumeric(totalModified));
assert(isnumeric(totalErrored));

% Check variable sizes
assert(isequal(size(totalSame),[1 1]));
assert(isequal(size(totalAdded),[1 1]));
assert(isequal(size(totalDeleted),[1 1]));
assert(isequal(size(totalModified),[1 1]));
assert(isequal(size(totalErrored),[1 1]));


% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Compare speeds of pre-calculation versus post-calculation versus a fast variant
figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum);
close(figNum);


% Make sure to run rclone config and use the OneDrivePSU as the name to
% point to the PSU OneDrive account
%
% Command to check folder:
% rclone lsd --max-depth 1 "OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions"

rcloneFolder = 'C:\rclone-v1.68.2-windows-amd64';
cloudFolder = 'OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions';
localFolder = fullfile(pwd,'Data','StudentSubmissions');
archiveFolder = fullfile(pwd,'Data','Archive');


[fileContent, ~, ~, timeString, ~] = ...
    fcn_CollectSubmissions_downloadFolders(rcloneFolder, cloudFolder, localFolder, syncTime, (-1));

subFolder = [];
flagArchiveEqualFiles = [];

Niterations = 1;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations
    % Call the function
    [totalSame, totalAdded, totalDeleted, totalModified, totalErrored] = ...
        fcn_CollectSubmissions_archiveChanges(...
        fileContent, localFolder, archiveFolder, timeString, ...
        (subFolder), (flagArchiveEqualFiles), ([]));
end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;
for ith_test = 1:Niterations
    % Call the function
    [totalSame, totalAdded, totalDeleted, totalModified, totalErrored] = ...
        fcn_CollectSubmissions_archiveChanges(...
        fileContent, localFolder, archiveFolder, timeString, ...
        (subFolder), (flagArchiveEqualFiles), (-1));
end
fast_method = toc;

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

% Plot results as bar chart
figure(373737);
clf;
hold on;

X = categorical({'Normal mode','Fast mode'});
X = reordercats(X,{'Normal mode','Fast mode'}); % Forces bars to appear in this exact order, not alphabetized
Y = [slow_method fast_method ]*1000/Niterations;
bar(X,Y)
ylabel('Execution time (Milliseconds)')


% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% BUG cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ____  _    _  _____
% |  _ \| |  | |/ ____|
% | |_) | |  | | |  __    ___ __ _ ___  ___  ___
% |  _ <| |  | | | |_ |  / __/ _` / __|/ _ \/ __|
% | |_) | |__| | |__| | | (_| (_| \__ \  __/\__ \
% |____/ \____/ \_____|  \___\__,_|___/\___||___/
%
% See: http://patorjk.com/software/taag/#p=display&v=0&f=Big&t=BUG%20cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All bug case figures start with the number 9

% close all;

%% BUG

%% Fail conditions
if 1==0

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


% %% fcn_INTERNAL_loadExampleData
% function rosterTable = fcn_INTERNAL_loadExampleData_createSubmissionFolders
% 
% % Use the last data
% CSVPath = fullfile(cd,'Data','roster_2026_01_06.csv');
% rosterTable = fcn_LoadRoster_rosterTableFromCSV(CSVPath, (-1));
% 
% 
% end % Ends fcn_INTERNAL_loadExampleData
