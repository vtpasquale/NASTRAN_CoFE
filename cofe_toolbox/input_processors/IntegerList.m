% Helper superclass for open-ended lists of integers with the THRU option
% Anthony Ricciardi
%
classdef (Abstract) IntegerList
    
    properties (Abstract)
        i1 % [n,1 uint32] list of individual identification numbers and the first identification number for any THRU ranges
        iN % [n,1 uint32] list of the second identification number for any THRU ranges
        thru % [n,1 logical] true where i1(thru,1) and iN(thru,1) contain THRU ranges
    end
    methods (Sealed = true)
        function obj = readIntegerFields(obj,entryFields,entryName)
            % reads integer data from open-ended cell of bulk data fields
            iIndex = 1;
            i1_ = castInputField(entryName,'IDi',entryFields{1},'uint32',NaN,0);
            
            ID2_end = entryFields(2:end);
            findEmpty = strcmp(ID2_end,'');
            % proceed if there are additional integers
            if any(~findEmpty)
                ID2_n = ID2_end(~findEmpty);
                
                thruFlag = strcmpi(ID2_n,'THRU');
                n = size(ID2_n,2);
                i1_ = [i1_;zeros(n-1,1,'uint32')];
                iN_ = zeros(n,1,'uint32');
                thru_ = false(n,1);
                
                % check for possible format issues
                if n == 1
                    if thruFlag
                        error('Format issue with %s entry.',entryName)
                    end
                elseif thruFlag(end)
                    error('Format issue with %s entry.',entryName)
                elseif n > 1
                    consecutiveThruFlag = (thruFlag(1:end-1) & thruFlag(1:end-1)==thruFlag(2:end) );
                    if any(consecutiveThruFlag)
                        error('Consecutive THRU fields not allowed on %s entry.',entryName)
                    end
                end
                % loop over additional integers
                i = 1;
                while i <= n
                    if thruFlag(i)
                        thru_(iIndex,1) = true;
                        i = i + 1;
                        iN_(iIndex,1) = castInputField(entryName,'IDi',ID2_n{i},'uint32',NaN,1);
                        i = i + 1;
                    else
                        iIndex = iIndex + 1;
                        i1_(iIndex,1) = castInputField(entryName,'IDi',ID2_n{i},'uint32',NaN,1);
                        iN_(iIndex,1) = int32(0);
                        thru_(iIndex,1) = false;
                        i = i + 1;
                    end
                end
                % remove trailing unused array entries
                i1_ = i1_(i1_~=0);
                iN_ = iN_(i1_~=0);
                thru_ = thru_(i1_~=0);
            else
                iN_ = zeros(1,1,'uint32');
                thru_ = false;
            end
            
            % For THRU option check ID1 < ID2
            if any(thru_)
                if ~all( i1_(thru_)<iN_(thru_) )
                    error('The THRU option requires ID1 < ID2')
                end
            end
            
            % save to class properties
            obj.i1 = i1_;
            obj.iN = iN_;
            obj.thru = thru_;
        end % readIntegerFields()
        function echoIntegerFields(obj,fid,startFields)
            % echos bulk data entry with open-ended list of integers. User
            % provides startFields; a char of comma-delimited fields at the
            % begining of the entry. startFields should end with a comma.
            if ~any(obj.thru)
                longstr = [startFields,sprintf('%d,',obj.i1)];
                longstr(end)=[];
            else
                n = size(obj.i1,1);
                
                % ensure obj.iN = 0 without THRU
                obj.iN(~obj.thru)=0;
                
                % create dummy variable
                dummy = zeros(2*n,1);
                dummy(1:2:end) = obj.i1;
                dummy(2:2:end) = obj.iN;
                
                % create dummy string
                if size(dummy,1) == 2
                    dummy_str = [startFields,sprintf('%d,THRU,%d',dummy)];
                else
                    dummy_str = [startFields,...
                        sprintf('%d,THRU,%d,',dummy(1:end-2)),...
                        sprintf('%d,THRU,%d',dummy(end-1:end))];
                end
                
                % correct dummy string
                longstr = strrep(dummy_str,',THRU,0','');
            end
            commaLocations=strfind(longstr,',');
            if size(commaLocations,2)>17
                 % enter placeholders for nextline
                longstr(commaLocations(17:8:end))='*';
            end
            if size(commaLocations,2)>9
                % enter placeholder for nextline
                longstr(commaLocations(9))='*';
                % replace placeholder with nextline
                longstr = strrep(longstr,'*','\n,');
            end
            if strcmp(longstr(end-2:end),'\n,')
                longstr(end-2:end) = [];
            end
            fprintf(fid,[longstr,'\n']);
        end % echoIntegerFields()
        function values = getValues(obj)
            % provides [nset,1 uint32] vector of all integers in list
            [nn,mm] = size(obj);
            if nn ~= 1 || mm ~=1
                error('Method getValues does not support arrays of BulkIntegerList objects. Method getValues is used only for scalar BulkIntegerList objects. ');
            end
            if ~any(obj.thru)
                values = obj.i1;
            else
                n = size(obj.i1,1);
                
                % ensure obj.iN = 0 without THRU
                obj.iN(~obj.thru)=0;
                
                % create dummy variable
                dummy = zeros(2*n,1);
                dummy(1:2:end) = obj.i1;
                dummy(2:2:end) = obj.iN;
                
                % create eval string
                if size(dummy,1)==2
                    eval_str = ['values = uint32([',...
                        sprintf('%d:%d',dummy),...
                        ']).'';'];
                else
                    eval_str = ['values = uint32([',...
                        sprintf('%d:%d,',dummy(1:end-2)),...
                        sprintf('%d:%d',dummy(end-1:end)),...
                        ']).'';'];
                end
                
                % correct eval string
                eval_str = strrep(eval_str,':0','');
                
                % evaluate
                eval(eval_str); % defines 'values'
            end
        end % getValues()
    end
    methods (Static = true)
        function [i1,thru,iN]=condenseFromValues(values)
            % Function to condense list of values using THRU option
            if size(values,2)~=1; error('''values'' input argument should be size [nValues,1].'); end
            values = unique(values);
            n = size(values,1);
            
            iPlusTwoIsConsecutive=false(n,1);
            iMinusTwoIsConsecutive=false(n,1);
            iPlusOneAndMinusOneIsConsecutive=false(n,1);
            iPlusTwoIsConsecutive(1:n-2) = ( values(1:n-2)+2 == values(3:n) );
            iMinusTwoIsConsecutive(3:n) = ( values(3:n)-2 == values(1:n-2) );
            iPlusOneAndMinusOneIsConsecutive(2:n-1)=(values(2:n-1)+1 == values(3:n)) ...
                & (values(2:n-1)-1 == values(1:n-2));
            areThreeConsecutive = iPlusTwoIsConsecutive | iMinusTwoIsConsecutive | ...
                iPlusOneAndMinusOneIsConsecutive;
            
            isFirstConsecutive = false(n,1);
            isFirstConsecutive(1) = iPlusTwoIsConsecutive(1);
            isFirstConsecutive(2:n) = ( iPlusTwoIsConsecutive(2:n)==1 & iPlusTwoIsConsecutive(1:n-1)==0 );
            
            isLastConsecutive = false(n,1);
            isLastConsecutive(1) = false;
            isLastConsecutive(n) = iMinusTwoIsConsecutive(end);
            isLastConsecutive(2:n-1) = ( iMinusTwoIsConsecutive(2:n-1)==1 & iMinusTwoIsConsecutive(3:n)==0 );
            
            i1 = values(~areThreeConsecutive | isFirstConsecutive);
            iN = values(~areThreeConsecutive | isLastConsecutive);
            thru = i1~=iN;
            iN(~thru)=0;
        end % constructFromValues()
    end
end