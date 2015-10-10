% Shape functions
function val = dNdxi(~,i,xi,eta)
switch i
    case 1
        val =-.25*(1-eta);
    case 2
        val = .25*(1-eta);
    case 3
        val = .25*(1+eta);
    case 4
        val =-.25*(1+eta);
    otherwise
        error('i should be 1-4.')
end