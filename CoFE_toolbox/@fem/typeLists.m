% Function to define FEM type lists using FEM object metadata
% Anthony Ricciardi 
%
function obj = typeLists(obj)

%% extract object metadata
mObj = metaclass(obj);

%% loop through properties
for i = 1:size(mObj.PropertyList,1)

    % isa entry
    eval(['bool=isa(obj.',mObj.PropertyList(i).Name,',''entry'');'])
    if bool
        obj.entryList{1,size(obj.entryList,2)+1}= mObj.PropertyList(i).Name;
    end
    
    % isa element
    eval(['bool=isa(obj.',mObj.PropertyList(i).Name,',''element'');'])
    if bool
        obj.elementList{1,size(obj.elementList,2)+1}= mObj.PropertyList(i).Name;
    end
    
    % isa structure
    eval(['bool=isa(obj.',mObj.PropertyList(i).Name,',''structure'');'])
    if bool
        obj.structureList{1,size(obj.structureList,2)+1}= mObj.PropertyList(i).Name;
    end
    
    % isa constraint
    eval(['bool=isa(obj.',mObj.PropertyList(i).Name,',''constraint'');'])
    if bool
        obj.constraintList{1,size(obj.constraintList,2)+1}= mObj.PropertyList(i).Name;
    end
    
    % isa applied_load
    eval(['bool=isa(obj.',mObj.PropertyList(i).Name,',''applied_load'');'])
    if bool
        obj.applied_loadList{1,size(obj.applied_loadList,2)+1}= mObj.PropertyList(i).Name;
    end
        
end