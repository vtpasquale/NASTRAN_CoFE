% Jacobian Matrix
function val = Jacobian(obj,xi,eta)

j1=[obj.x1,obj.x2,obj.x3,obj.x4]*...
    [obj.dNdxi(1,xi,eta);
     obj.dNdxi(2,xi,eta);
     obj.dNdxi(3,xi,eta);
     obj.dNdxi(4,xi,eta)];
 
j2=[obj.x1,obj.x2,obj.x3,obj.x4]*...
    [obj.dNdeta(1,xi,eta);
     obj.dNdeta(2,xi,eta);
     obj.dNdeta(3,xi,eta);
     obj.dNdeta(4,xi,eta)];

j3= obj.N(1,xi,eta)*obj.n1 + obj.N(2,xi,eta)*obj.n2 + obj.N(3,xi,eta)*obj.n3 + obj.N(4,xi,eta)*obj.n4;
 
val = [j1.';j2.';j3.'];