function bdfEntries = design2entries(x,initialBdfEntries)
% INPUTS
%  x = [n,1 double] vector of design variable values.
%  initialBdfEntries = [BdfEntries] Initial BdfEntries object to be updated based on design variable values.
%
% OUTPUTS
% bdfEntries = [BdfEntries] BdfEntries object that has been updated based on design variable values.
bdfEntries = initialBdfEntries;
entries = bdfEntries.bulkEntry{1};

% ribs
entries(2).t = x(1);
entries(3).t = x(2);
entries(4).t = x(3);
entries(5).t = x(4);
entries(6).t = x(5);
entries(7).t = x(6);
entries(8).t = x(7);
entries(9).t = x(8);

% skins
entries(11).t = x(9);
entries(12).t = x(10);
entries(13).t = x(11);
entries(14).t = x(12);
entries(15).t = x(13);
entries(16).t = x(14);
entries(17).t = x(15);
entries(18).t = x(16);
entries(19).t = x(17);

% spars
entries(20).t = x(18);
entries(21).t = x(19);
entries(22).t = x(20);
entries(23).t = x(21);
entries(24).t = x(22);
entries(25).t = x(23);
entries(26).t = x(24);
entries(27).t = x(25);
entries(28).t = x(26);

bdfEntries.bulkEntry{1} = entries;

