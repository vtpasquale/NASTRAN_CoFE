function obj = loads(obj)

p =zeros(obj.ndof,1);

%% forces
if isempty(obj.FORCE) == 0
    nforce = size(obj.FORCE,2);
    for i = 1:nforce
        if obj.FORCE(i).SID == obj.CASE.LOAD
            
            nnum = obj.FORCE(i).G;
            mag = obj.FORCE(i).F;
            
            p( obj.gnum2gdof(1,find(nnum==obj.gnum)) ,  1) = p( obj.gnum2gdof(1,find(nnum==obj.gnum)) ,  1)...
                + mag * obj.FORCE(i).N1;
            p( obj.gnum2gdof(2,find(nnum==obj.gnum)) ,  1) = p( obj.gnum2gdof(2,find(nnum==obj.gnum)) ,  1)...
                + mag * obj.FORCE(i).N2;
            p( obj.gnum2gdof(3,find(nnum==obj.gnum)) ,  1) = p( obj.gnum2gdof(3,find(nnum==obj.gnum)) ,  1)...
                + mag * obj.FORCE(i).N3;
        end
    end
end

%% moments
if isempty(obj.MOMENT) == 0
    nmoment = size(obj.MOMENT,2);
    for i = 1:nmoment
        if obj.MOMENT(i).SID == obj.CASE.LOAD
            
            nnum = obj.MOMENT(i).G;
            mag = obj.MOMENT(i).F;
            
            p( obj.gnum2gdof(4,find(nnum==obj.gnum)) ,  1) = p( obj.gnum2gdof(4,find(nnum==obj.gnum)) ,  1)...
                + mag * obj.MOMENT(i).N1;
            p( obj.gnum2gdof(5,find(nnum==obj.gnum)) ,  1) = p( obj.gnum2gdof(5,find(nnum==obj.gnum)) ,  1)...
                + mag * obj.MOMENT(i).N2;
            p( obj.gnum2gdof(6,find(nnum==obj.gnum)) ,  1) = p( obj.gnum2gdof(6,find(nnum==obj.gnum)) ,  1)...
                + mag * obj.MOMENT(i).N3;
        end
    end
end

%% gravity loads
if isempty(obj.GRAV) == 0
    
    gent = find(obj.CASE.LOAD == [obj.GRAV.SID]);
    if size(gent,2)~=1
        if size(gent,2)>1
            error(['There cannot be more than one GRAV entry with SID = ',num2str(obj.FORCE(i).SID)])
%         else
%             % not GRAV with matching SID
        end
    else
        objGRAV = obj.GRAV(gent);
        gAccel = zeros(obj.ndof,1);
        gAccel(1:6:obj.ndof) = objGRAV.A * objGRAV.N1;
        gAccel(2:6:obj.ndof) = objGRAV.A * objGRAV.N2;
        gAccel(3:6:obj.ndof) = objGRAV.A * objGRAV.N3;

        p = p + obj.M_G*gAccel;
    end
end            

%%
obj.p = p;
