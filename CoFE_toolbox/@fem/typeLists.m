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

    % isa plot0D
    eval(['bool=isa(obj.',mObj.PropertyList(i).Name,',''plot0D'');'])
    if bool
        obj.plot0DList{1,size(obj.plot0DList,2)+1}= mObj.PropertyList(i).Name;
    end
    
    % isa plot1D
    eval(['bool=isa(obj.',mObj.PropertyList(i).Name,',''plot1D'');'])
    if bool
        obj.plot1DList{1,size(obj.plot1DList,2)+1}= mObj.PropertyList(i).Name;
    end
    
    % isa plot2D
    eval(['bool=isa(obj.',mObj.PropertyList(i).Name,',''plot2D'');'])
    if bool
        obj.plot2DList{1,size(obj.plot2DList,2)+1}= mObj.PropertyList(i).Name;
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