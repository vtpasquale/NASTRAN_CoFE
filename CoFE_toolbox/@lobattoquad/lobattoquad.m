classdef lobattoquad
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x
        dx
        xi
        w
    end
    
    methods
        function obj = lobattoquad(order,rangeMin,rangeMax)
            
            % check inputs
            [n,m] = size(order);
            if m ~= 1
                error(' ''order'' should be a nx1 vector of dimensional orders.')
            end
            if nargin > 1
                [n1,m1] = size(rangeMin);
                [n2,m2] = size(rangeMax);
                if n ~= n1 || n ~= n2 || m1 ~= 1 || m2 ~= 1
                    error('rangeMin and rangeMax should be nx1 vectors.')
                end
            end
            
            XI = cell(n,1);
            W  = cell(n,1);
            % make cells with correct weights and locations
            for i = 1:n
                switch order(i)
                    case {1,2}
                        error('Mimimum order is 3 for Lobatto Quadrature')
                    case 3
                        XI{i} = [-1. 0. 1.];
                        W{i} =  [1/3 4/3 1/3];
                    case 4
                        XI{i} = [-1/5*sqrt(5) -1 1 1/5*sqrt(5)];
                        W{i} =  [5/6 1/6 1/6 5/6];
                    otherwise
                        error('Lobatto points and weights not included.  Add them and the function will work.')
                end
            end
            
            
            % make n-d array
            if n == 1
                obj.xi = ndgrid(XI{1});
                obj.w  = ndgrid(W{1});
            else
                eval(['[obj.xi{1}',sprintf(',obj.xi{%d}',2:n),']= ndgrid(XI{1}',sprintf(',XI{%d}',2:n),');']);
                eval(['[obj.w{1}' ,sprintf(',obj.w{%d}',2:n),']= ndgrid(W{1}',sprintf(',W{%d}',2:n),');']);
            end
            
            % map xi to x
            if nargin > 1
                obj.x = cell(n,1);
                obj.dx = (rangeMax-rangeMin)./2;
                if n == 1
                    obj.x = ((rangeMax+rangeMin)+(rangeMax-rangeMin)*obj.xi)./2;
                else
                    for i = 1:n
                        obj.x{i} = ((rangeMax(i)+rangeMin(i))+(rangeMax(i)-rangeMin(i))*obj.xi{i})./2;
                    end
                end
            end
        end
        
        % carry out integration
        function val = int(obj,fun)
            n = size(obj.x,1);
            if iscell(obj.x) == 0
                II = fun(obj.x).*obj.w*obj.dx;
            else
                eval(['II = fun(obj.x{1}',sprintf(',obj.x{%d}',2:n),')',sprintf('.*obj.w{%d}',1:n),sprintf('.*obj.dx(%d)',1:n),';']);
            end
            val = sum(II(:));
        end % end function
  
    end % end methods
    
end % end class