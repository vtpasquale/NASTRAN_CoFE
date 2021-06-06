function bdfEntries = design2entries(x,initialBdfEntries)
% INPUTS
%  x = [n,1 double] vector of design variable values.
%  initialBdfEntries = [BdfEntries] Initial BdfEntries object to be updated based on design variable values.
%
% OUTPUTS
% bdfEntries = [BdfEntries] BdfEntries object that has been updated based on design variable values.
bdfEntries = initialBdfEntries;
entries = bdfEntries.bulkEntry{1};

entries(1).a = x(1);
entries(2).a = x(2);
entries(3).a = x(3);
entries(4).a = x(4);
entries(5).a = x(5);
entries(6).a = x(6);
entries(7).a = x(7);
entries(8).a = x(8);
entries(9).a = x(9);
entries(10).a = x(10);

entries(11).x1 = 720 + x(11);
entries(11).x3 = x(12);
entries(12).x1 = 360 + x(13);
entries(12).x3 = x(14);

bdfEntries.bulkEntry{1} = entries;

