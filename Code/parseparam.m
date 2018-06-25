function params = parseparam(params, varargin)

prmnames = fieldnames(params);
[pidx loc] = ismember(lower(prmnames), lower(varargin(1:2:end)));
if any(~pidx) 
	error('parseparam:wrongParam', 'Wrong parameter name: %s', sprintf('%s, ',prmnames{~pidx}));
end
for i = 1:length(loc)
	if iscell(params.(prmnames{i}))
		varargin{2*loc(i)} = {params.(prmnames{i})};
	else
		varargin{2*loc(i)} = params.(prmnames{i});
	end
end
params = struct(varargin{:});