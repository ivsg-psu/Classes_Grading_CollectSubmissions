function fcn_CollectSubmissions_updateLog(logFile, syncTime, processDuration, flagWasSuccessful, subFolder, totalsCollected, varargin)

%% fcn_CollectSubmissions_updateLog
%     fcn_CollectSubmissions_updateLog updates a log file so that changes
%     in algorithm behavior can be tracked.
%
% FORMAT:
%
%      fcn_CollectSubmissions_updateLog(logFile, syncTime, processDuration, flagWasSuccessful, totalsCollected,(figNum));
%
%
% INPUTS:
%
%      logFile: a string containing the path to the file used for logging
%
%      syncTime: the time at which the synchronization started
%      obtained via: datetime('now')
%
%      processDuration: the duration, in seconds, that it took to
%      synchronize cloud to local
%
%      flagWasSuccessful: returns 1 if function completed without errors
%
%      subFolder: a string designating which selected folders should ONLY
%      be updated (default is '', which includes all updates).
%
%      totalsCollected: a structure containing totals of results, with following subfields
%      
%           totalSame, 
%           
%           totalAdded, 
% 
%           totalDeleted, 
% 
%           totalModified, 
% 
%           totalErrored
%
%      these are the totals for each of the archive outcomes of equality,
%      addition, deletion, modification, and errors
%
%      (OPTIONAL INPUTS)
%
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      (none - the function writes to file)
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_CollectSubmissions_updateLog
%     for a full test suite.
%
% This function was written on 2026_01_09 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_01_09 by Sean Brennan, sbrennan@psu.edu
% - wrote the code originally, using breakDataIntoLaps as starter

% TO-DO:
%
% 2026_01_09 by Sean Brennan, sbrennan@psu.edu
% - (fill in items here)



%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 7; % The largest Number of argument inputs to the function
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
        narginchk(6,MAX_NARGIN);

        % Check the logFile to be sure it is a string or char
        fcn_DebugTools_checkInputsToFunctions(logFile, '_of_char_strings');

        % Make sure syncTime is a datetime type
        assert(isdatetime(syncTime));

        % Check the processDuration to be sure it is numeric
        fcn_DebugTools_checkInputsToFunctions(processDuration, 'strictlypositive_1column_of_numbers');

        assert(islogical(flagWasSuccessful));

        % Check the subFolder to be sure it is a string or char
        fcn_DebugTools_checkInputsToFunctions(subFolder, '_of_char_strings');        

        assert(isstruct(totalsCollected));

    end
end


% % The following area checks for variable argument inputs (varargin)
% 
% % Does the user want to specify the subFolder input?
% % Set defaults first:
% subFolder = '';
% if 5 <= nargin
%     temp = varargin{1};
%     if ~isempty(temp)
%         subFolder = temp;
%     end
% end
% 
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

timeString = fcn_DebugTools_time2String( syncTime, (-1));
posixTimeString = sprintf('%9.2f',posixtime(syncTime));
processDurationString = sprintf('%.2f',processDuration);
prettyTimeString = sprintf('%s',syncTime);
flagWasSuccessfulString = sprintf('%.0f',flagWasSuccessful);

line_of_data = sprintf('%s,  %s, %s, %s, %s, %s, %.0f, %.0f, %.0f, %.0f, %.0f', ...
    timeString, ...
    posixTimeString, ...
    prettyTimeString, ...
    processDurationString, ...
    flagWasSuccessfulString, ...
    subFolder, ... 
    totalsCollected.totalSame, ...
    totalsCollected.totalAdded, ...
    totalsCollected.totalDeleted, ...
    totalsCollected.totalModified, ...
    totalsCollected.totalErrored ...
    );

writelines(line_of_data, logFile, WriteMode="append")

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
    fprintf(1,'File line result: \n\t%s\n', line_of_data);
 
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


%% fcn_INTERNAL_processChange
function fcn_INTERNAL_processChange( changeToProcess, localFolder, archiveFolder, suffixString)

% Break the change into parts, either folders or files
folderBreaks = find(changeToProcess == '/', 1);
if ~isempty(folderBreaks)
    output_cell_array = split(changeToProcess, '/');
else
    output_cell_array{1} = changeToProcess;
end
    
% Build the path to the source
sourceString = localFolder;
for ith_cell = 1:length(output_cell_array)
    sourceString = fullfile(sourceString,output_cell_array{ith_cell});
end
[~,name,ext] = fileparts(sourceString);

newName = cat(2,name,suffixString,ext);

% Build the path to the destination, building the path up to the new name
% but not including the name
destinationPathString = archiveFolder;
for ith_cell = 1:length(output_cell_array)-1
    destinationPathString = fullfile(destinationPathString,output_cell_array{ith_cell});
end

% Make the directory, if it does not exist
if ~exist(destinationPathString,'dir')
    fcn_DebugTools_makeDirectory(destinationPathString,-1);
end

% Copy the file or touch the file?
destinationString = fullfile(destinationPathString,newName);
if strcmp(suffixString(end-3:end),'_rem') || strcmp(suffixString(end-3:end),'_err')
    % File was deleted or an error occurred. Touch the file name to log.
    fcn_DebugTools_fileTouch(destinationString,-1);
else
    % Copy the file
    [Success,Message,MessageID] = copyfile(sourceString, destinationString, 'f');
    if 1~=Success
        error('Encountered copy error. Message is: %s with MessageID: %.0d',Message, MessageID)
    end
end


end % Ends fcn_INTERNAL_processChange