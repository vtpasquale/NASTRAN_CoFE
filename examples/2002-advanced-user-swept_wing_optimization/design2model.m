function model = design2model(x,initialModel)
% INPUTS
%  x = [n,1 double] vector of design variable values.
%  initialModel = [Model] Initial Model object to be updated based on design variable values.
%
% OUTPUTS
% model = [Model] Model object that has been updated based on design variable values.
model = initialModel;

% ribs
model.property(2).t = x(1);
model.property(3).t = x(2);
model.property(4).t = x(3);
model.property(5).t = x(4);
model.property(6).t = x(5);
model.property(7).t = x(6);
model.property(8).t = x(7);
model.property(9).t = x(8);

% skins
model.property(11).t = x(9);
model.property(12).t = x(10);
model.property(13).t = x(11);
model.property(14).t = x(12);
model.property(15).t = x(13);
model.property(16).t = x(14);
model.property(17).t = x(15);
model.property(18).t = x(16);
model.property(19).t = x(17);

% spars
model.property(20).t = x(18);
model.property(21).t = x(19);
model.property(22).t = x(20);
model.property(23).t = x(21);
model.property(24).t = x(22);
model.property(25).t = x(23);
model.property(26).t = x(24);
model.property(27).t = x(25);
model.property(28).t = x(26);