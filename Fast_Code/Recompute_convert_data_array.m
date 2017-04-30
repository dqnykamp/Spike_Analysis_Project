%% Find the length of the longest spike train to convert 
% all logical arrays into matrices
disp('find the length of the longest spike train'); tic;
nrows = zeros(32, 1);
for i = 1:32
    nrows(i) = length(sd.S{i}.T);
end
Nrows = max(nrows);
toc;

%% Store all the real spike data into a matrix/2D array
disp('converting real data from cells to a matrix');tic;
RealData = nan(Nrows, length(Spikes));
for i = 1:length(Spikes)
    RealData(1:length(Spikes{i}.T), i) =  Spikes{i}.T; 
end
toc;

%%
disp('initializing tstart , dt = 0.03 [s]');tic;

% Limit spiking to time on and off track
tstart = sd.ExpKeys.TimeOnTrack; %start time in [s] of the real experiment
tend = sd.ExpKeys.TimeOffTrack; %end time in [s] of the real experiment
ncols = size(RealData, 2); %number of neurons or columns in the data

MaxTime = (tend - tstart); %Duration of the experiment.
dt = MaxTime/Nrows; %time step in [s];

%disp(min(unique(time) == time));
%-1*ones(4,5);
%data(1,1:length(x{2}))) = x{2};

time = tstart:dt:tend-dt; %initialize a time vector to index rows of prevtime/nextime
idx = zeros(length(time), ncols); %matrix for prevtime logicals
idx2 = zeros(length(time), ncols); %matrix for next time logicals
prevtime = zeros(length(time), ncols); %initialize the prevtime vector
nextime = nan(length(time), ncols);%initialize the nextime vector
tmp = zeros(length(time), ncols); % store indices of idx in tmp matrix
tmp2 = nan(length(time), ncols); % store indices of idx2 in tmp2 matrix
toc;

%%

disp('computing prevtime/nextime');tic;

for i = 1:Nrows
  for j = 1:ncols
  
      % look for elements </> time respectively
      
        idx(:,j) =  RealData(:,j)  <  time(i);
        idx2(:,j) =  RealData(:,j) >  time(i);
    
    if (sum(idx(:,j))~=0)  % exclude empty arrays

   %save the indices corresponding to non-empty arrays from from idx into tmp
   
    tmp = max(RealData(find(idx(1:nnz(~isnan(RealData(:,j))),j)),j));
    
   % compute prevtime 
   prevtime(i,j) = tmp-time(i);%max(tmp(:,j)) - time(i);
 
        else
          prevtime(i,j) = nan;
    end
    
    %repeat the same exact proceedure above for nextime
    if (sum(idx2(:,j))~=0)  

   tmp2 = min(RealData(find(idx2(1:nnz(~isnan(RealData(:,j))),j)),j));
   nextime(i,j) = tmp2-time(i);
 
        else
          nextime(i,j) = nan;
    end
    
    
    
  end
end
toc;