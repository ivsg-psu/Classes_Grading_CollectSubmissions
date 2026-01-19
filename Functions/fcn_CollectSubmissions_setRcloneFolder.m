function rcloneFolder = fcn_CollectSubmissions_setRcloneFolder(varargin)

%% fcn_CollectSubmissions_setRcloneFolder
%     fcn_CollectSubmissions_setRcloneFolder sets the path to the rclone
%     software folder using the computer ID info
%
% FORMAT:
%
%      rcloneFolder = fcn_CollectSubmissions_setRcloneFolder
%
% INPUTS:
%
%      (OPTIONAL INPUTS)
%
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      rcloneFolder: the path to the local rclone folder for this computer
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_CollectSubmissions_setRcloneFolder
%     for a full test suite.
%
% This function was written on 2026_01_16 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_01_16 by Sean Brennan, sbrennan@psu.edu
% - Wrote fcn_CollectSubmissions_setRcloneFolder
%   % * Sets the path to the local install of the rclone software based on 
%   %   % the current computer
%
% 2026_01_19 by Sean Brennan, sbrennan@psu.edu
% - In fcn_CollectSubmissions_setRcloneFolder
%   % * Updated folder for E5-ME-L-SEBR17

% TO-DO:
%
% 2026_01_16 by Sean Brennan, sbrennan@psu.edu
% - (fill in items here)



%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 1; % The largest Number of argument inputs to the function
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
		narginchk(0,MAX_NARGIN);
		
		% % Check the fileContent to be sure it is a string
		% fcn_DebugTools_checkInputsToFunctions(fileContent, '_of_strings');

		% Check the rosterTable to be sure it is a text style and a folder
		% fcn_DebugTools_checkInputsToFunctions(localFolder, '_of_char_strings');
		% fcn_DebugTools_checkInputsToFunctions(localFolder, 'DoesDirectoryExist');

		% % Check the archiveFolder to be sure it is a text style and a folder
		% fcn_DebugTools_checkInputsToFunctions(archiveFolder, '_of_char_strings');
		% fcn_DebugTools_checkInputsToFunctions(archiveFolder, 'DoesDirectoryExist');
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
% 
% % % Does the user want to specify flagArchiveEqualFiles input?
% % flagArchiveEqualFiles = 0; % Default case
% % if 6 <= nargin
% %     temp = varargin{2};
% %     if ~isempty(temp)
% %         % Set the flagArchiveEqualFiles values
% %         flagArchiveEqualFiles = temp;
% %     end
% % end
% 

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
thisComputer = getenv('COMPUTERNAME');

% 'E5-ME-L-SEBR17'
% 'E5-ME-SEBR02'

switch(thisComputer)
	case 'PROTOWERPLUS'
		rcloneFolder = 'C:\rclone';
	case 'E5-ME-L-SEBR17'
		rcloneFolder = 'C:\rclone-v1.68.2-windows-amd64';
	otherwise
		warning('backtrace','on');
		warning('Unrecognized computer being used: %s, using defaults.',thisComputer);
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
	fprintf(1,'rcloneFolder:     %s\n', rcloneFolder);

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
