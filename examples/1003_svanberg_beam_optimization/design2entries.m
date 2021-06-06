function bdfEntries = design2entries(x,initialBdfEntries)
% INPUTS
%  x = [n,1 double] vector of design variable values.
%  initialBdfEntries = [BdfEntries] Initial BdfEntries object to be updated based on design variable values.
%
% OUTPUTS
% bdfEntries = [BdfEntries] BdfEntries object that has been updated based on design variable values.
bdfEntries = initialBdfEntries;
entries = bdfEntries.bulkEntry{1};

t = 0.062/21.483152759999999;  
entries(1).i2 = 2.*t.*x(1,1).^3./3;
entries(2).i2 = 2.*t.*x(2,1).^3./3;
entries(3).i2 = 2.*t.*x(3,1).^3./3;
entries(4).i2 = 2.*t.*x(4,1).^3./3;
entries(5).i2 = 2.*t.*x(5,1).^3./3;

bdfEntries.bulkEntry{1} = entries;
