function D_B = default_D_B()
%default_D_B return a vector of default delays for the delayed reward

D_B = [[1, 2, 3, 4, 5, 6, 7, 8, 9, 12]./24,...
	1, 2, 3, 4, 5, 6, 7,...
	[2, 3, 4].*7,...
	[3, 4, 5, 6, 8, 9].*30,...
	[1, 2, 3, 4, 5, 6, 7, 8, 10, 15, 20, 25].*365];
return
