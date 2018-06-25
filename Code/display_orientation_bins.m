function display_orientation_bins(prms)
%
% Display the orientation bins on the unit sphere
%   display_orientation_bins(prms)
%
% Input:
%   prms - Parameters [struct]
%          .nxybin  - Number of orientation bins in x-y plane 
%          .ntbin   - Number of orientation bin-layers along t-axis
%          .reflect - true  for calculating direction in half-region (0~180)
%                     false for whole-region (0~360)
%
% Output:
%   plot figure
%

%- Base axes -%
sphere(30); hold on;
h = get(gca,'Children');
set(h,'FaceColor','w','FaceAlpha',0.9,'EdgeColor',[0.5,0.5,0.5],'EdgeAlpha',0.2);
quiver3(0,0,0, 1.4, 0,0,'LineWidth',3,'color','k','AutoScale','off','MaxHeadSize',0.5); text(1.3, 0.1,0.1,'x','FontSize',20)
quiver3(0,0,0, 0,-1.4,0,'LineWidth',3,'color','k','AutoScale','off','MaxHeadSize',0.5); text(0.1,-1.3,0.1,'y','FontSize',20);
quiver3(0,0,0, 0, 0,1.4,'LineWidth',3,'color','k','AutoScale','off','MaxHeadSize',0.5); text(0.1, 0.1,1.3,'t','FontSize',20);

%- Bin points -%
theta = -2*pi*linspace(0,1,prms.nxybin+1);
theta(end) = [];
phi = 0.5*pi*linspace(0,1,prms.ntbin+2);
phi = [-fliplr(phi(2:end-1)),phi(1:end-1)];

if prms.reflect > 0
	%- Hemisphere -%
	theta = theta*0.5;
end

%- Distinct colors -%
COL = hsv(prms.nxybin);
cCOL= circshift(COL,floor(prms.nxybin/2))*0.9;

%%-- Plotting --%%
count = 1;
for j = 1:2*prms.ntbin+1
	z = sin(phi(j));
	r = cos(phi(j));
	for i = 1:prms.nxybin
		x = r*cos(theta(i));
		y = r*sin(theta(i));
		%- In each layer -%
		sphereplot(x, y, z, COL(i,:), num2str(count), cCOL(i,:));
		count = count + 1;
	end
	COL = COL*0.8;
end
%- North pole -%
sphereplot( 0, 0, 1, 'k', num2str(count), 'k');
count = count + 1;

if prms.reflect == 0
	%- South pole -%
	sphereplot(0, 0, -1, [0.5,0.5,0.5], num2str(count), [0.5,0.5,0.5]);
end
axis equal;
axis off;

%---- Utility function ----%
function sphereplot(x,y,z,col,txt,tcol)
	%- Sphere for point -%
	[sx,sy,sz] = sphere(10);
	sx = 0.05*sx; sy = 0.05*sy; sz = 0.05*sz;

	%- Draw sphere points -%
	surf(x+sx, y+sy, z+sz, 'FaceColor',col,'FaceAlpha',0.9,'EdgeColor','none');
	text(1.1*x,1.1*y,1.1*z, txt,'color',tcol,'fontsize',15,'HorizontalAlignment','left','FontWeight','bold');
