function updatedRosterTable = fcn_CollectSubmissions_loopOverCollections(...
	rosterTable, ...
	cloudFolder, localFolder, archiveFolder, ...
	assignmentString, gradingFunction, logFile, varargin)

%% fcn_CollectSubmissions_loopOverCollections
%     fcn_CollectSubmissions_loopOverCollections loops over the
%     CollectSubmissions functions to collect, archive, grade, and email
%     results to students.
%
% FORMAT:
%
%      updatedRosterTable = fcn_CollectSubmissions_loopOverCollections(...
%      rosterTable, ...
%      cloudFolder, localFolder, archiveFolder, ...
%      assignmentString, gradingFunction, logFile, (exitCounter), (figNum));
%
% INPUTS:
%
%      rosterTable: a table of the class roster
%
%      cloudFolder: a string containing the path to the folder on the
%      cloud resource where data should be copied from. This is typically
%      linked to a path set in the 'rclone config' process. An example
%      path: 'OneDrivePSU:/Classes/ME452 Vehicle Dynamics/00_Submissions'
%
%      localFolder: a string containing the path to the folder on the
%      local computer where the data should be copied to. After the
%      successful rclone operation, this is a mirror copy of the
%      cloudFolder.
%
%      archiveFolder: a string containing the path to the folder on the
%      local computer where the archives should be copied to
%
%      assignmentString: a string denoting which assignment to check. Any
%      assignment containing this will trigger a submission email
%      verification. Default is the word 'SUBMISSION' which will trigger
%      all submissions.
%
%      gradingFunction: a function handle to a MATLAB function that is
%      called to assess answers and assign grades
%
%      logFile: a string containing the path to the file used for logging
%
%      (OPTIONAL INPUTS)
%
%      exitCounter: an integer specifying how many iterations to run the
%      while loop. The while loop will continue until iterations is larger
%      than exitCounter. Default is 'inf'.
%
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed. If set to a negative number less than -1,
%      figNum is set to the positive value of this AND safeMode is shut
%      off, so that students are emailed.
%
% OUTPUTS:
%
%      updatedRosterTable: a table representing the class roster, with a
%      field added for the submission that it was confirmed
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_CollectSubmissions_loopOverCollections
%     for a full test suite.
%
% This function was written on 2026_01_25 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_01_25 by Sean Brennan, sbrennan@psu.edu
% - Wrote fcn_CollectSubmissions_loopOverCollections
%   % * Used fcn_CollectSubmissions_confirmSubmissions as starter
%   % * This is a function that loops over the collection process
%   % * How it works:
%   %   % * Enters a while loop for a user-defined number of cycles, and in
%   %   %   % each while loop, does the following:
%   %   % * Creates a blocking file so that other instances cannot run
%   %   % * Downloads submissions 
%   %   %   % fcn_CollectSubmissions_downloadFolders
%   %   % * Archives changes 
%   %   %   % fcn_CollectSubmissions_archiveChanges
%   %   % * Gathers specific assignment into a table
%   %   %   % fcn_CollectSubmissions_gatherSubmissionsIntoTable
%   %   % * Grades the assignment using user-defined function
%   %   %   % fcn_CollectSubmissions_gradeAssignment
%   %   % * Confirms submissions by emailing students
%   %   %   % fcn_CollectSubmissions_confirmSubmissions
%   %   % * Confirms grades by emailing students
%   %   %   % fcn_CollectSubmissions_confirmGrades
%   %   % * Updates the log of entries (which makes a plot)
%   %   %   % fcn_CollectSubmissions_updateLog
%   %   % * Saves a mat file, with time stamp, of rosterTable
%   %   % * Deletes the blocking file when done
%   %   % * Pauses 1 second before next loop iteration
%
% 2026_01_25 by Sean Brennan, sbrennan@psu.edu
% - In fcn_CollectSubmissions_loopOverCollections
%   % * Addes safeMode for student emails
%
% 2026_01_25 by Sean Brennan, sbrennan@psu.edu
% - In fcn_CollectSubmissions_loopOverCollections
%   % * Fixed bug where -1 was used to cause safeMode, causing errors with
%   %   % fastMode. Fixed to use -10 instead.


% TO-DO:
%
% 2026_01_25 by Sean Brennan, sbrennan@psu.edu
% - (fill in items here)



%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 9; % The largest Number of argument inputs to the function
flag_max_speed = 0; % The default. This runs code with all error checking
if (nargin==MAX_NARGIN && isequal(varargin{end},-1))
	flag_do_debug = 0; % Flag to plot the results for debugging
	flag_check_inputs = 0; % Flag to perform input checking
	flag_max_speed = 1;
else
	% Check to see if we are externally setting debug mode to be "on"
	flag_do_debug = 0; % Flag to plot the results for debugging
	flag_check_inputs = 1; % Flag to perform input checking
	MATLABFLAG_COLLECTSUBMISSIONS_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_COLLECTSUBMISSIONS_FLAG_CHECK_INPUTS");
	MATLABFLAG_COLLECTSUBMISSIONS_FLAG_DO_DEBUG = getenv("MATLABFLAG_COLLECTSUBMISSIONS_FLAG_DO_DEBUG");
	if ~isempty(MATLABFLAG_COLLECTSUBMISSIONS_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_COLLECTSUBMISSIONS_FLAG_DO_DEBUG)
		flag_do_debug = str2double(MATLABFLAG_COLLECTSUBMISSIONS_FLAG_DO_DEBUG);
		flag_check_inputs  = str2double(MATLABFLAG_COLLECTSUBMISSIONS_FLAG_CHECK_INPUTS);
	end
end

% flag_do_debug = 1;

if flag_do_debug % If debugging is on, print on entry/exit to the function
	st = dbstack; %#ok<*UNRCH>
	fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
	debug_figNum = 999978; %#ok<NASGU>
else
	debug_figNum = []; %#ok<NASGU>
end

%% check input arguments?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0==flag_max_speed
	if flag_check_inputs
		% Are there the right number of inputs?
		narginchk(MAX_NARGIN-2,MAX_NARGIN);

		% Check the cloudFolder to be sure it is a text style
		fcn_DebugTools_checkInputsToFunctions(cloudFolder, '_of_char_strings');

		% Check the localFolder to be sure it is a text style and a folder
		fcn_DebugTools_checkInputsToFunctions(localFolder, '_of_char_strings');
		fcn_DebugTools_checkInputsToFunctions(localFolder, 'DoesDirectoryExist');

		% Check the archiveFolder to be sure it is a text style and a folder
		fcn_DebugTools_checkInputsToFunctions(archiveFolder, '_of_char_strings');
		fcn_DebugTools_checkInputsToFunctions(archiveFolder, 'DoesDirectoryExist');

		% Check the assignmentString to be sure it is a text style
		fcn_DebugTools_checkInputsToFunctions(assignmentString, '_of_char_strings');

        % Check the logFile to be sure it is a string or char
        fcn_DebugTools_checkInputsToFunctions(logFile, '_of_char_strings');

	end
end


% The following area checks for variable argument inputs (varargin)

% Does the user want to specify the exitCounter input?
% Set defaults first:
exitCounter = inf;
if 3 <= nargin
	temp = varargin{1};
	if ~isempty(temp)
		exitCounter = temp;
	end
end

% Does user want to show the plots?
flag_do_plots = 0; % Default is to NOT show plots
if (0==flag_max_speed) && (MAX_NARGIN == nargin)
	temp = varargin{end};
	if ~isempty(temp) % Did the user NOT give an empty figure number?
		figNum = temp; 
		flag_do_plots = 1;
	end
end


%% Main code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if figNum<-1
	safeMode = -10; % Set to -10 to email students
	figNum = -1*figNum;
else
	safeMode = 1; % Set to -1 to email students
end

rcloneFolder = fcn_CollectSubmissions_setRcloneFolder;

if exist('blockingFile.txt','file')
	delete('blockingFile.txt');
end

thisTurn = 0;
while thisTurn<exitCounter % One shot

	thisTurn = thisTurn+1;
	fprintf(1, '\nSTARTING TURN: %.0f of %.0f\n', thisTurn, exitCounter);
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
		[fileContent, flagWasSuccessful, ~, timeString, ~] = ...
			fcn_CollectSubmissions_downloadFolders(rcloneFolder, cloudFolder, localFolder, startTime, (figNum));

		%%%% fcn_CollectSubmissions_archiveChanges
		fprintf(1,'Archiving submissions.\n');
		subFolderArchive = [];
		flagArchiveEqualFiles = [];

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
		assignmentFileString = cat(2,'SUBMISSION_',assignmentString,'_');
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
			fileContent, gradedRosterTable, (assignmentString), (safeMode));


		%%%% fcn_CollectSubmissions_confirmGrades
		fprintf(1,'Confirming grades.\n');

		%%%%%%%%%%
		% Call the function
		finalGradedRosterTable = ...
			fcn_CollectSubmissions_confirmGrades(...
			fileContent, confirmedGradedRosterTable, (assignmentString), (safeMode));

		%%%% fcn_CollectSubmissions_updateLog
		fprintf(1,'Updating the log file.\n');

		endTime = datetime('now');
		processDuration = seconds(endTime - startTime);

		% Call the function
		fcn_CollectSubmissions_updateLog(logFile, endTime, processDuration, flagWasSuccessful, assignmentString, totalsCollected, (figNum))

		rosterTable = finalGradedRosterTable;
		updatedRosterTable = rosterTable;

		% Save the most recent roster
		timeString = fcn_DebugTools_time2String(datetime('now'),-1);
		rosterDataFileName = sprintf('roster_%s.mat',timeString(1:end-4));

		rostersFolder = fullfile(pwd,'Rosters');
		if ~exist(rostersFolder,'dir')
			warning('backtrace','on');
			warning('Roster archive folder not found: \n\t%s\n.',rostersFolder);
			error('Unable to continue. Cannot backup rosters.');
		end

		rosterDataFilePath = fullfile(rostersFolder,rosterDataFileName);
		if ~exist(rosterDataFilePath,'file')
			save(rosterDataFilePath,'rosterTable');
			fprintf(1,'Saved new roster data file: %s\n',rosterDataFileName)
		end
		
		% Delete the blocking file
		delete('blockingFile.txt');


	end % Ends check for blocking file
	
	pause(1); % Pause to let user see plot
end % Ends while loop

%% Plot the results (for debugging)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_plots
	%  disp(rosterTable);
	% % plot the final XY result
	% figure(figNum);
	% clf;
	%
	% % Everything put together
	% subplot(1,2,1);
	% hold on;
	% grid on
	% title('Results of breaking data into laps');
	%
	%
	%
	% % Plot the indices per lap
	% all_ones = ones(length(input_path(:,1)),1);
	%
	% % fill in data
	% start_of_lap_x = [];
	% start_of_lap_y = [];
	% lap_x = [];
	% lap_y = [];
	% end_of_lap_x = [];
	% end_of_lap_y = [];
	% for ith_lap = 1:Nlaps
	%     start_of_lap_x = [start_of_lap_x; cell_array_of_entry_indices{ith_lap}; NaN]; %#ok<AGROW>
	%     start_of_lap_y = [start_of_lap_y; all_ones(cell_array_of_entry_indices{ith_lap})*ith_lap; NaN]; %#ok<AGROW>;
	%     lap_x = [lap_x; cell_array_of_lap_indices{ith_lap}; NaN]; %#ok<AGROW>
	%     lap_y = [lap_y; all_ones(cell_array_of_lap_indices{ith_lap})*ith_lap; NaN]; %#ok<AGROW>;
	%     end_of_lap_x = [end_of_lap_x; cell_array_of_exit_indices{ith_lap}; NaN]; %#ok<AGROW>
	%     end_of_lap_y = [end_of_lap_y; all_ones(cell_array_of_exit_indices{ith_lap})*ith_lap; NaN]; %#ok<AGROW>;
	% end
	%
	% % Plot results
	% plot(start_of_lap_x,start_of_lap_y,'g-','Linewidth',3,'DisplayName','Prelap');
	% plot(lap_x,lap_y,'b-','Linewidth',3,'DisplayName','Lap');
	% plot(end_of_lap_x,end_of_lap_y,'r-','Linewidth',3,'DisplayName','Postlap');
	%
	% h_legend = legend;
	% set(h_legend,'AutoUpdate','off');
	%
	% xlabel('Indices');
	% ylabel('Lap number');
	% axis([0 length(input_path(:,1)) 0 Nlaps+0.5]);
	%
	%
	% subplot(1,2,2);
	% % Plot the XY coordinates of the traversals
	% hold on;
	% grid on
	% title('Results of breaking data into laps');
	% axis equal
	%
	% cellArrayOfPathsToPlot = cell(Nlaps+1,1);
	% cellArrayOfPathsToPlot{1,1}     = input_path;
	% for ith_lap = 1:Nlaps
	%     temp_indices = cell_array_of_lap_indices{ith_lap};
	%     if length(temp_indices)>1
	%         dummy_path = input_path(temp_indices,:);
	%     else
	%         dummy_path = [];
	%     end
	%     cellArrayOfPathsToPlot{ith_lap+1,1} = dummy_path;
	% end
	% h = fcn_Laps_plotLapsXY(cellArrayOfPathsToPlot,figNum);
	%
	% % Make input be thin line
	% set(h(1),'Color',[0 0 0],'Marker','none','Linewidth', 0.75);
	%
	% % Make all the laps have thick lines
	% for ith_plot = 2:(length(h))
	%     set(h(ith_plot),'Marker','none','Linewidth', 5);
	% end
	%
	% % Add legend
	% legend_text = {};
	% legend_text = [legend_text, 'Input path'];
	% for ith_lap = 1:Nlaps
	%     legend_text = [legend_text, sprintf('Lap %d',ith_lap)]; %#ok<AGROW>
	% end
	%
	% h_legend = legend(legend_text);
	% set(h_legend,'AutoUpdate','off');
	%
	%
	%
	% %     % Plot the start, excursion, and end conditions
	% %     % Start point in green
	% %     if flag_start_is_a_point_type==1
	% %         Xcenter = start_zone_definition(1,1);
	% %         Ycenter = start_zone_definition(1,2);
	% %         radius  = start_zone_definition(1,3);
	% %         INTERNAL_plot_circle(Xcenter, Ycenter, radius, [0 .7 0], 4);
	% %     end
	% %
	% %     % End point in red
	% %     if flag_end_is_a_point_type==1
	% %         Xcenter = end_definition(1,1);
	% %         Ycenter = end_definition(1,2);
	% %         radius  = end_definition(1,3);
	% %         INTERNAL_plot_circle(Xcenter, Ycenter, radius, [0.7 0 0], 2);
	% %     end
	% %     legend_text = [legend_text, 'Start condition'];
	% %     legend_text = [legend_text, 'End condition'];
	% %     h_legend = legend(legend_text);
	% %     set(h_legend,'AutoUpdate','off');
	%
	% % Plot start zone
	% h_start_zone = fcn_Laps_plotZoneDefinition(start_zone_definition,'g-',figNum);
	%
	% % Plot end zone
	% h_end_zone = fcn_Laps_plotZoneDefinition(end_zone_definition,'r-',figNum);
	%
	%
end

if flag_do_debug
	fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function

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


% %% fcn_INTERNAL_processChange
% function fcn_INTERNAL_processChange( changeToProcess, localFolder, archiveFolder, suffixString)
%
% % Break the change into parts, either folders or files
% folderBreaks = find(changeToProcess == '/', 1);
% if ~isempty(folderBreaks)
%     output_cell_array = split(changeToProcess, '/');
% else
%     output_cell_array{1} = changeToProcess;
% end
%
% % Build the path to the source
% sourceString = localFolder;
% for ith_cell = 1:length(output_cell_array)
%     sourceString = fullfile(sourceString,output_cell_array{ith_cell});
% end
% [~,name,ext] = fileparts(sourceString);
%
% newName = cat(2,name,suffixString,ext);
%
% % Build the path to the destination, building the path up to the new name
% % but not including the name
% destinationPathString = archiveFolder;
% for ith_cell = 1:length(output_cell_array)-1
%     destinationPathString = fullfile(destinationPathString,output_cell_array{ith_cell});
% end
%
% % Make the directory, if it does not exist
% if ~exist(destinationPathString,'dir')
%     fcn_DebugTools_makeDirectory(destinationPathString,-1);
% end
%
% % Copy the file or touch the file?
% destinationString = fullfile(destinationPathString,newName);
% if strcmp(suffixString(end-3:end),'_rem') || strcmp(suffixString(end-3:end),'_err')
%     % File was deleted or an error occurred. Touch the file name to log.
%     fcn_DebugTools_fileTouch(destinationString,-1);
% else
%     % Copy the file
%     [Success,Message,MessageID] = copyfile(sourceString, destinationString, 'f');
%     if 1~=Success
%         error('Encountered copy error. Message is: %s with MessageID: %.0d',Message, MessageID)
%     end
% end
%
%
% end % Ends fcn_INTERNAL_processChange