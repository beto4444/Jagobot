classdef ObstacleHandlerTest < matlab.unittest.TestCase
     
    properties
        corridor
        obstacle
    end
 
    methods(TestClassSetup)
        function createCorridor(testCase)
            nodesSimple = {[0,0],[1250,0],[0,1250],[1250,1250]};
            adjMatrixSimple = [0,1,1,0;
                                1,0,0,1;
                                1,0,0,1;
                                0,1,1,0];

            greenhouse = CorridorStructure(nodesSimple, adjMatrixSimple);
            greenhouse = greenhouse.init();
            testCase.corridor = greenhouse;
        end
        
        function createObstacle(testCase)
            testCase.obstacle = Obstacle([1, 1, 50, 0, 1, 10], testCase.corridor);
        end
    end
    
    methods (Test)
        function testObstacleImpactOutside(testCase)
            pos = Position(testCase.corridor.getEdge(1), 60);
            actSolution = testCase.obstacle.impacts(pos);
            expSolution = false;
            testCase.verifyEqual(actSolution, expSolution);
        end
        
        function testObstacleImpactInside(testCase)
            pos = Position(testCase.corridor.getEdge(1), 51);
            actSolution = testCase.obstacle.impacts(pos);
            expSolution = true;
            testCase.verifyEqual(actSolution, expSolution);
        end
    end
    
end 