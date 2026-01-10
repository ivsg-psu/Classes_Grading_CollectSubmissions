% Example Timetable creation (same as above)
MeasurementTime = datetime(2015,1,1) + seconds(0:5:60)';
Temp = 20 + 10*sin(linspace(0, 10*pi, numel(MeasurementTime)))';
Pressure = randn(numel(MeasurementTime), 1)*5 + 30;
TT = timetable(MeasurementTime, Temp, Pressure);

% Create a stacked plot of all variables
stackedplot(TT);

% Plot only specific variables
stackedplot(TT, {'Temp'});

% You can also customize the plot by capturing the object handle
s = stackedplot(TT);
s.LineWidth = 2; % Change line width for all plots
s.AxesProperties(1).YScale = 'log'; % Change y-axis scale for the first plot
