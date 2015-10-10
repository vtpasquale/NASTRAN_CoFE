% Convert node positions to basic coordinate system
% Anthony Ricciardi
%
function obj = rot2c0(obj)
placeholder = obj.GRID;
rind = find([placeholder.CP]~=0);
if size(rind,2) > 0
    placeholderC = obj.CORD2R;
    cind = [placeholderC.CID];
    for j = 1:size(rind,2)
        cindind = find(cind == placeholder(rind(j)).CP);
        if size(cindind,2) ~= 1; 
            error(['GRID ',num2str(placeholder(rind(j)).ID),' references coordinate system ID ',num2str(placeholder(rind(j)).CP),'.  There should be one and only one coordinate system defined with that identification number.' ])
        end
        p = [placeholder(rind(j)).X1;placeholder(rind(j)).X2;placeholder(rind(j)).X3];
        pnew = placeholderC(cindind).rot(p);
        placeholder(rind(j)).X1 = pnew(1);
        placeholder(rind(j)).X2 = pnew(2);
        placeholder(rind(j)).X3 = pnew(3);
    end
    obj.GRID = placeholder;
end
end