function echo(obj,filename)
fid = fopen(filename,'w');
for j = 1:size(obj.entryList,2)
    placeHolder = obj.(obj.entryList{j});
    for i = 1:size(placeHolder,2)
        try
            echo(placeHolder(i),fid)
        catch exception
            error(['Issue executing echo.  echo method likely undefined for ',obj.entryList{j},' entry.'])
        end
    end
end
fclose('all');