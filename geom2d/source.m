% % base point
% center = [10 0];
% % create vertical line
% l1 = [center 0 1];
% % circle
% c1 = [center 5];
% pts = intersectLineCircle(l1, c1);
% % draw the result
figure; clf; hold on;
axis([0 10 0 10]);
% drawLine([4.0866 50.8456 14.0866 50.8456]);
% drawLine([0 0 2 3])
% % drawCircle(c1);
% drawPoint([20 30], 'rx');
 

% drawEdge([0 0 60 35])
% line = edgeToLine(edge);
% % 
% % line = [30 40 10 0];
% % box = [0 100 0 100];
% % res = clipLine(line, box);
% drawLine(line)
% % drawLine(res)
% % 
% % circle = circleToPolygon([10 0 5], 16);
% % 
% % drawPolygon(circle);

RECT = [6 4 4 4];
% drawRect2(RECT)
POLY = orientedBoxToPolygon(RECT);
drawPolygon(POLY);



EDGE = [2 3 6 8];
% line = edgeToLine(edge);
% drawLine(line, 'color', 'g')
drawEdge(EDGE, 'linewidth', 2)

inter = intersectEdgePolygon(EDGE, POLY)




axis equal;
