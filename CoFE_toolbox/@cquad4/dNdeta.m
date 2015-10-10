% Shape functions
function val = dNdeta(~,i,xi,eta)
switch i
    case 1
        val =-.25*(1-xi);
    case 2
        val =-.25*(1+xi);
    case 3
        val = .25*(1+xi);
    case 4
        val = .25*(1-xi);
    otherwise
        error('i should be 1-4.')
end