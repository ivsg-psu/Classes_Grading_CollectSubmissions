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
%      be updated (default is '', which includes all updates). This is not
%      used in this function. It is simply logged.
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
%
% 2026_01_23 by Sean Brennan, sbrennan@psu.edu
% - In fcn_CollectSubmissions_updateLog
%   % * Added plotting of results
%   % * Added automatic header if new log is being made
%
% 2026_01_24 by Sean Brennan, sbrennan@psu.edu
% - In fcn_CollectSubmissions_updateLog
%   % * Changed plot style to see locations of data collection
%
% 2026_01_25 by Sean Brennan, sbrennan@psu.edu
% - In fcn_CollectSubmissions_updateLog
%   % * Removed unused function
%   % * Removed debug supression comment that is now unneeded

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

% Print header?
if ~exist(logFile,'file')
	header = sprintf('timeString,  posixTimeString, prettyTimeString, processDuration, flagWasSuccessful, subfolder, totalSame, totalAdded, totalDeleted, totalModified, totalErrored');
	writelines(header, logFile, WriteMode="append")
end
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

	% Plot the logfile
	% Detect options and set types (example: make "Date" datetime, "ID" categorical)
	opts = detectImportOptions(logFile);
	T = readtable(logFile, opts);
	T.Timestamp = datetime(T.posixTimeString, ...
		'ConvertFrom','posixtime', ...
		'TimeZone','UTC');   % specify timezone if known
	T.Timestamp.Format = 'yyyy-MM-dd HH:mm:ss';   % display format

	timeOfData = T.Timestamp;
	same = T.totalSame;
	added = T.totalAdded;
	deleted = T.totalDeleted;
	modified = T.totalModified;
	errored = T.totalErrored;

	figure(figNum);
	hold on;
	ax = gca;
	hasPlot = ~isempty(ax.Children);   % true if any graphics objects exist

	if ~hasPlot
		h_same     = plot(timeOfData,same,'.-','Linewidth',3, 'MarkerSize',20,'Color',[0 0 0],'DisplayName','Same');
		h_added    = plot(timeOfData,added,'.-','Linewidth',3, 'MarkerSize',20,'Color',[0 1 0], 'DisplayName','Added');
		h_deleted  = plot(timeOfData,deleted,'.-','Linewidth',3, 'MarkerSize',20,'Color',[1 0 0], 'DisplayName','Deleted');
		h_modified = plot(timeOfData,modified,'.-','Linewidth',3, 'MarkerSize',20,'Color',[0 0 1], 'DisplayName','Modified');
		h_errored  = plot(timeOfData,errored,'.-','Linewidth',6, 'MarkerSize',20,'Color',[1 0 0], 'DisplayName','Errored');
		legend('Interpreter','none','Location','best');
		xlabel('Timestamp');
		ylabel('Totals');
		grid on;
				
		allHandles.h_same = h_same;
		allHandles.h_added = h_added;
		allHandles.h_deleted = h_deleted;
		allHandles.h_modified = h_modified;
		allHandles.h_errored = h_errored;

		set(figNum, 'UserData', allHandles)
	else
		allHandles = get(figNum, 'UserData');
		set(allHandles.h_same,'XData',timeOfData,'YData',same);
		set(allHandles.h_added,'XData',timeOfData,'YData',added);
		set(allHandles.h_deleted,'XData',timeOfData,'YData',deleted);
		set(allHandles.h_modified,'XData',timeOfData,'YData',modified);
		set(allHandles.h_errored,'XData',timeOfData,'YData',errored);

	end

 
   
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


