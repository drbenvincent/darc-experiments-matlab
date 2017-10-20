function addSubFoldersToPath()

pathOfThisFunction = mfilename('fullpath');
[currentpath, ~, ~]= fileparts(pathOfThisFunction);
allSubpaths = strsplit( genpath(currentpath) ,':');
blacklist={'.git','.ignore','.graffle','.'}; % '.' is any hidden folder

pathsToAdd={};
for n=1:numel(allSubpaths)
	if shouldAddThisPath(allSubpaths{1,n},blacklist)
		pathsToAdd{end+1} = allSubpaths{n};
	end
end

disp('Temporarily adding toolbox subdirecties to the path: ')
fprintf('\t%s\n',pathsToAdd{:})
addpath( strjoin(pathsToAdd, ':') )
end

function addThisPath = shouldAddThisPath(path,blacklist)
addThisPath = true;
for ignoreStr = blacklist
	if isStringMatch(path,ignoreStr{1})
		addThisPath=false;
	end
end
end

function matchFound = isStringMatch(str,pattern)
matchFound = ~strfind(str,pattern);
end
