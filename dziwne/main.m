close all;
clear all;

% cfg.structureName = 'simpleLoop';
cfg.structureName = 'twoloops';
cfg.group = [4,4];
cfg.comRange = 300;
cfg.cycleTime = 28800;

repetitions = 1;


simMany(cfg, repetitions, 'updated');
%simAllGroups(cfg, repetitions);


% nodesTwo = {[0,0],[700,0],[1400,0],[1400,700],[700,700],[0,700]};
% adjMatrixTwo = [0,1,0,0,0,1;
%                  1,0,1,0,1,0;
%                  0,1,0,1,0,0;
%                  0,0,1,0,1,0;
%                  0,1,0,1,0,1;
%                  1,0,0,0,1,0];
% 
% mine = CorridorStructure(nodesTwo, adjMatrixTwo);
% mine = mine.init();
% 
% ps = PathSeeker(mine);
% 
% e = mine.getEdge(4);
% position.edge = e;
% position.distance = 537.78;
% ps.vehPosition = position;
% ps.vehDirection = true;
% 
% et = mine.getEdge(2);
% targetPos.edge = et;
% targetPos.distance = 0;
% ps.setTarget(targetPos);