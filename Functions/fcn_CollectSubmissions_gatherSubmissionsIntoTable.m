function ungradedSubmissionTable = ...
    fcn_CollectSubmissions_gatherSubmissionsIntoTable(fileContent, assignmentString, localFolder, varargin)

%% fcn_CollectSubmissions_gatherSubmissionsIntoTable
%     fcn_CollectSubmissions_gatherSubmissionsIntoTable processes changes
%     between cloud and local mirror, collecting all submissions that match
%     a user-defined assignment string. Each submission is loaded and its
%     variables are copied into a table containing all the entries. NOTE:
%     this does not grade the entries, it merely collects all the data from
%     all students into the same structure.
%
% FORMAT:
%
%      ungradedSubmissionTable = ...
%      fcn_CollectSubmissions_gatherSubmissionsIntoTable(...
%      fileContent, assignmentString, localFolder, (figNum));
%
% INPUTS:
%
%      fileContent: an array of strings, one for each file transfer, that
%      lists the type of change for each file. This result is automatically
%      populated from rclone, and the designators have the following
%      meaning (see: https://rclone.org/commands/rclone_sync/)
%
%           = path means path was found in source and destination and was
%           identical (no change)
%
%           - path means path was missing on the source, so only in the
%           destination (deletion in destination)
%
%           + path means path was missing on the destination, so only in
%           the source (addition in destination)
%
%           * path means path was present in source and destination but
%           different. (modification in destination)
%
%           ! path means there was an error reading or hashing the source
%           or dest. (error in transfer)
%
%      assignmentString: a string denoting which assignment to check. Any
%      assignment containing this will trigger a table entry. Typical
%      strings are of the form: 'SUBMISSION_Week01_HW01_'
%
%      localFolder: a string containing the path to the folder on the
%      local computer where the data files are stored
%
%      (OPTIONAL INPUTS)
%
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      ungradedSubmissionTable: a table containing all the entries that
%      were gathered
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_CollectSubmissions_gatherSubmissionsIntoTable
%     for a full test suite.
%
% This function was written on 2026_01_20 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_01_20 by Sean Brennan, sbrennan@psu.edu
% - Wrote fcn_CollectSubmissions_gatherSubmissionsIntoTable
%   % * Used fcn_CollectSubmissions_confirmSubmissions as starter
%   % * processes changes between cloud and local mirror, collecting all submissions that match
%   %   % a user-defined assignment string. 


%   Each submission is loaded and its
%     variables are copied into a table containing all the entries. NOTE:
%     this does not grade the entries, it merely collects all the data from
%     all students into the same structure.


%   % * This is a function that emails students to confirm submissions
%   % * Lets users know that the file(s) were received 
%   % * How it works:
%   %   % * Loops through change list between cloud and local mirror, 
%   %   % * Finds if any match an assignment string, 
%   %   % * Checks if the user preferences indicate that confirmations are
%   %   %   % desired.
%   %   % * Sends confirmation emails to the associated emails 

% TO-DO:
%
% 2026_01_16 by Sean Brennan, sbrennan@psu.edu
% - (fill in items here)



%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 4; % The largest Number of argument inputs to the function
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
		narginchk(MAX_NARGIN-1,MAX_NARGIN);

		% Check the fileContent to be sure it is a string
		fcn_DebugTools_checkInputsToFunctions(fileContent, '_of_strings');

		% Check the assignmentString to be sure it is a string or char
		fcn_DebugTools_checkInputsToFunctions(assignmentString, '_of_char_strings');

		% Check the localFolder to be sure it is a string or char and a
        % folder
		fcn_DebugTools_checkInputsToFunctions(localFolder, '_of_char_strings');
        fcn_DebugTools_checkInputsToFunctions(localFolder, 'DoesDirectoryExist');
        
		% Check the assignmentString to be sure it is a text style and a folder
		% fcn_DebugTools_checkInputsToFunctions(localFolder, '_of_char_strings');
		% fcn_DebugTools_checkInputsToFunctions(localFolder, 'DoesDirectoryExist');

		% % Check the archiveFolder to be sure it is a text style and a folder
		% fcn_DebugTools_checkInputsToFunctions(archiveFolder, '_of_char_strings');
		% fcn_DebugTools_checkInputsToFunctions(localFolder, 'DoesDirectoryExist');
		%
		% % Check the timeString to be sure it is a text style
		% fcn_DebugTools_checkInputsToFunctions(timeString, '_of_char_strings');

	end
end


% % The following area checks for variable argument inputs (varargin)
% 
% % Does the user want to specify the assignmentString input?
% % Set defaults first:
% assignmentString = 'SUBMISSION';
% if 3 <= nargin
% 	temp = varargin{1};
% 	if ~isempty(temp)
% 		assignmentString = temp;
% 		if flag_check_inputs
% 			% Check the assignmentString to be sure it is a text style
% 			fcn_DebugTools_checkInputsToFunctions(assignmentString, '_of_char_strings');
% 		end
% 	end
% end

% % Does the user want to specify flagArchiveEqualFiles input?
% flagArchiveEqualFiles = 0; % Default case
% if 6 <= nargin
%     temp = varargin{2};
%     if ~isempty(temp)
%         % Set the flagArchiveEqualFiles values
%         flagArchiveEqualFiles = temp;
%     end
% end

% Does user want to show the plots?
flag_do_plots = 0; % Default is to NOT show plots
if (0==flag_max_speed) && (MAX_NARGIN == nargin)
	temp = varargin{end};
	if ~isempty(temp) % Did the user NOT give an empty figure number?
		figNum = temp; %#ok<NASGU>
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

% Check and prep folder
tempFolder = fullfile(pwd,'Temp');
if ~exist(tempFolder,'dir')
    fcn_DebugTools_makeDirectory(tempFolder);
end

sz = [1 4]; % 1 row, 4 columns
varTypes = {'int64', 'cell', 'cell', 'cell'};
varNames = {'StudentNumber','answers','identifiers','timelog'};
ungradedSubmissionTable = table('Size', sz, 'VariableTypes', varTypes, 'VariableNames', varNames);

changesToLog = {'+'; '='; '*'};

% Initialize counts
totalFound = 0;

% Loop through all the changes, checking to see which ones contain an
% addition (+) that has the assignmentString within the addition. Extract
% the student info from the change, and then email the student to confirm.
for ith_change = 1:length(fileContent)
	thisChange = fileContent(ith_change);
    thisChangeCharArray = char(thisChange);
    if ~isempty(thisChangeCharArray) && contains(thisChangeCharArray,assignmentString)
        changeToProcess = thisChangeCharArray(3:end);
        if any(strcmp(thisChangeCharArray(1),changesToLog))  

            % Extract the student number at start
            studentNumberStringAtStart = extractBefore(changeToProcess,'/');            
            studentNumberAtStart = str2double(studentNumberStringAtStart);

            % Extract zip file name
            zipFileName = extractAfter(changeToProcess,'/');

            % Extract the student number at end
            studentNumberStringAtEnd = extractBetween(zipFileName,assignmentString,'.zip');
            studentNumberAtEnd = str2double(studentNumberStringAtEnd);



            if studentNumberAtEnd~=studentNumberAtStart
                error('Student folder number does not match submission number?!\n\tFolder number: %.0f\n\tStudent number on submission: %.0f\n', studentNumberAtStart, studentNumberAtEnd)
            end

            studentNumber = studentNumberAtStart;

            %%%%%%%%%%%%
            % Extract contents
            fileToUnzip = fullfile(localFolder,sprintf('%07.0f',studentNumber), zipFileName);

            % Make sure file esists
            if ~exist(fileToUnzip,'file')
                error('Unable to find changed file in local directory. Seeking file: \n\t%s\n',fileToUnzip);
            end
            
            % Make sure temp folder is empty
            contentsInFolder = dir(fullfile(tempFolder,'*.*')); % Query temp folder        
            filesInFolder = contentsInFolder(~[contentsInFolder.isdir]); % Filter out directories from the list


            if ~isempty(filesInFolder)
                currentFolder = pwd;
                cd('Temp');
                delete('*.*');
                cd(currentFolder);
            end
            
            % Unzip contents
            unzip(fileToUnzip,tempFolder);

            % Make sure 'localVariables.mat' is created
            solutionsMatFile = fullfile(tempFolder,'localVariables.mat');
            if ~exist(solutionsMatFile,'file')
                error('Unable to find a localVAriables file in a zip extraction. Offending zip file: \n\t%s\n', fileToUnzip);
            end

            % Grab the variables
            variableInfo = who('-file', solutionsMatFile);
            load(solutionsMatFile, variableInfo{:});

            % Save results
            totalFound = totalFound+1;
            ungradedSubmissionTable.('StudentNumber')(totalFound) = studentNumber;
            for ith_variable = 1:length(variableInfo)
                thisVariableName = variableInfo{ith_variable};
                ungradedSubmissionTable.(thisVariableName)(totalFound) = {eval(thisVariableName)};

                % matchingIndex = strcmp(varNames,thisVariableName);
                % if strcmp(varTypes{matchingIndex},'cell')
                %     ungradedSubmissionTable.(thisVariableName)(totalFound) = {eval(thisVariableName)};
                % else
                %     ungradedSubmissionTable.(thisVariableName)(totalFound) = eval(thisVariableName);
                % end
            end

            % 
            % % Get student details
            % studentEmail = ungradedSubmissionTable.('PSUEmail'){studentRowNumber};
            % studentName = ungradedSubmissionTable.('FullName'){studentRowNumber};
            % 
            % % For debugging
            % if 1==1
            %     studentEmail = 'snb10@psu.edu';
            % end
            % 
            % entryAfterNumberString = extractAfter(changeToProcess, '/');
            % 
            % % Send email?
            % thisStudentReceivedConfirmation = ungradedSubmissionTable.(emailVerificationColumnName)(studentRowNumber);
            % 
            % if ~thisStudentReceivedConfirmation && notificationPreferences(studentRowNumber)
            % 
            %     recipient = studentEmail;
            %     subject = sprintf('ME452: automated confirmation of assignment submission %s',assignmentString);
            %     body = [...
            %         sprintf('This email is being sent automatically by the ME452 assignment manager to confirm that the following submission was received:') 10 10 ...
            %         sprintf('Assignment name: %s.',entryAfterNumberString) 10 ...
            %         sprintf('Student number: %.0f.',studentNumberAtStart) 10 ...
            %         sprintf('Student name: %s.',studentName) 10 ...
            %         sprintf('Student email: %s.',studentEmail) 10 ...
            %         ];
            % 
            %     % Attachments:
            %     % if 1==0
            %     % 	st = dbstack; %#ok<*UNRCH>
            %     % 	scriptPath = which(st.file);
            %     % 	scriptName = st.file;
            %     % 	functionName = extractAfter(scriptName,'script_test_');
            %     % 	functionPath = which(functionName);
            %     % else
            %     % 	scriptPath = which('script_test_fcn_LoadRoster_sendEmail');
            %     % 	functionPath = which('fcn_LoadRoster_sendEmail');
            %     % end
            %     % attachments = {scriptPath, functionPath};
            %     % fcn_LoadRoster_sendEmail( recipient, subject, body, attachments, (figNum))
            % 
            %     % Send the email
            %     fcn_LoadRoster_sendEmail( recipient, subject, body,{})
            %     ungradedSubmissionTable.(emailVerificationColumnName)(studentRowNumber) = true;
            % 
            %     totalFound = totalFound+1;
            % 
            % 
            % end

        end % if statement for addition only
    end % Ends if statement check for empty change and changes that contain assignment string
end


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
	disp(ungradedSubmissionTable);

	%  disp(assignmentString);
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