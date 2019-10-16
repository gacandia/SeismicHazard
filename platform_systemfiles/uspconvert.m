function usp = uspconvert(usp)

fld = fields(usp);
for i=1:length(fld)
    val = str2double(usp.(fld{i}));
    if ~isnan(val)
        usp.(fld{i})=val;
    end
end