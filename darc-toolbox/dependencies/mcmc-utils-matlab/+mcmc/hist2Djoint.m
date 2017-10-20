function [F,X,Y] = hist2Djoint(x,y,x_vec,y_vec)
%eg. [F,I,J] = hist2Djoint( randn(1000,1) , randn(1000,1) , linspace(-1,1,40) , linspace(-1,1,20) );
%
% 
% Benjamin Vincent, 2016


xmin	=min(x_vec);
xmax	=max(x_vec);
xNbins	=length(x_vec);

ymin	=min(y_vec);
ymax	=max(y_vec);
yNbins	=length(y_vec);

% discard data outside of bounds =========
set = x>=xmin & x<=xmax & y>=ymin & y<=ymax;
x=x( set );
y=y( set );
% ========================================

% scale between 0,1
x=(x-xmin) / (xmax-xmin);
y=(y-ymin) / (ymax-ymin);

% mulitply by number of bins
x=x*(xNbins-1) +1;
y=y*(yNbins-1) +1;

% round
I=round(x);
J=round(y);

% LOOP AROUND EACH DATA POINT
F=zeros(xNbins,yNbins);
for n=1:length(I)
	F( I(n) , J(n) ) = F( I(n) , J(n) ) +1;
end

X(set)=I;
Y(set)=J;


F=F';
