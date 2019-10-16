function[combstr]=horzcat2(varargin)

combstr=varargin{1};
for i=2:nargin
    combstr=[combstr,' ',varargin{i}]; %#ok<*AGROW>
end