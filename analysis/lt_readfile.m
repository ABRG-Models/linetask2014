function [ data, params ] = lt_readfile (file_path)
%% Read in line task data, as written out by the Trento code.
%% This returns the parameters for the run in @params and the time
%% series data in @data. For info on the different elements of
%% @params, see the code below. @data has 4 columns. data(:,1) is the time of
%% each collected data point. data(:,2) is the position of the target
%% line, in horizontal pixels, from 0 to the pixel width of the
%% screen. data(:,3) is the position of the distractor line, in
%% pixels and data(:,4) is the position of the stylus, again in
%% horizontal pixels. 
    
% The raw data file looks like this:
%C:/Users/Line/notremor/build-FP_RehabPlatform-Desktop_Qt_5_3_MSVC2012_OpenGL_32bit-Debug/debug/User/Subject0001/line/20141020141728.txt
%120	16	15.5161	15.5161	15.5161	1	0	0	192	1728	2	0	0.99	0.99	0.99	0	0	0.99	0.99	1	0.99	0	0	1	0	0	0	1	0	0	0	1	8	8	2	2
%
%27	960	1010	959
%58	960	1010	959
%75	960	1010	960
%106	960	1010	961
%122	960	1010	961
%138	960	1010	961
%...etc...

% Zeroth line is the original path to the data (on the device on
% which the data was collected). We'll ignore that.

% First line contains the parameters as follows (see around line
% 435 of line.cpp for the code which writes these out.)
parray = dlmread (file_path, '\t', [1,0,1,35]);
params.durataTest = parray(1);
params.Tc = parray(2);
params.TcSignal = parray(3);
params.TcDisturb = parray(4);
params.TcLimite = parray(5);
params.disturbYN = parray(6);
params.storedSignalChk = parray(7);
params.storedDisturbChk = parray(8);
params.Limiti_pixel0 = parray(9);
params.Limiti_pixel1 = parray(10);
params.tAtteso = parray(11);
params.tAttesoDisturbo = parray(12);
params.backgroundColor0 = parray(13);
params.backgroundColor1 = parray(14);
params.backgroundColor2 = parray(15);
params.backgroundColor3 = parray(16);
params.signalColor0 = parray(17);
params.signalColor1 = parray(18);
params.signalColor2 = parray(19);
params.signalColor3 = parray(20);
params.disturbColor0 = parray(21);
params.disturbColor1 = parray(22);
params.disturbColor2 = parray(23);
params.disturbColor3 = parray(24);
params.touchColor0 = parray(25);
params.touchColor1 = parray(26);
params.touchColor2 = parray(27);
params.touchColor3 = parray(28);
params.limitColor0 = parray(29);
params.limitColor1 = parray(30);
params.limitColor2 = parray(31);
params.limitColor3 = parray(32);
params.signalTargetWidth = parray(33);
params.disturbTargetWidth = parray(34);
params.touchTargetWidth = parray(35);
params.limitTargetWidth = parray(36);

% The data is in 4 cols: time, target line, disturber line, pointer position.
data = dlmread (file_path, '\t', 3, 0);

end