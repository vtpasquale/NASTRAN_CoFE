function [out,LM] = sqpstructout( opts, lambda_g, lambda_lb, lambda_ub )
% SQP.m utility function to return output as a data structure
out.fval       = opts(8);
out.funcCount  = opts(10);
out.gradCount  = opts(11);
out.iterations = opts(14);
out.options    = opts;
LM.ineq  = lambda_g;
LM.lower = lambda_lb;
LM.upper = lambda_ub;
end