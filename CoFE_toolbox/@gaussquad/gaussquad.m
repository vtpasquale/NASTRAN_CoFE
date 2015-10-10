classdef gaussquad
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x
        dx
        xi
        w
    end
    
    methods
        function obj = gaussquad(order,rangeMin,rangeMax)
            
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
                    case 1
                        XI{i} = 0;
                        W{i} =  2.0;
                    case 2
                        XI{i} = [-0.5773502691896257 0.5773502691896257];
                        W{i} =  [1.0 1.0];
                    case 3
                        XI{i} = [-0.7745966692414834 0.0 0.7745966692414834];
                        W{i} =  [0.5555555555555556 0.8888888888888888 0.5555555555555556];
                    case 4
                        XI{i} = [-0.8611363115940526 -0.3399810435848563 0.3399810435848563 0.8611363115940526];
                        W{i} =  [0.3478548451374538 0.6521451548625461 0.6521451548625461 0.3478548451374538];
                    otherwise
                        error('Gauss points and weights not included.  Add them and the function will work.')
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