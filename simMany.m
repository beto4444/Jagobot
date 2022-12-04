function [] = simMany(cfg, repetitions, resultFileName)     
    nodesTwo = {[0,0],[700,0],[1400,0],[1400,700],[700,700],[0,700]};
    adjMatrixTwo = [0,1,0,0,0,1;
                     1,0,1,0,1,0;
                     0,1,0,1,0,0;
                     0,0,1,0,1,0;
                     0,1,0,1,0,1;
                     1,0,0,0,1,0];
    nodesSimple = {[0,0],[1250,0],[0,1250],[1250,1250]};
    adjMatrixSimple = [0,1,1,0;
                        1,0,0,1;
                        1,0,0,1;
                        0,1,1,0];
    fileNameTwo = 'dataTwoLoops.xlsx';
    fileNameSimple = 'dataSimpleLoop.xlsx';

    if (strcmp(cfg.structureName, 'simpleLoop'))
        nodes = nodesSimple;
        adjMatrix = adjMatrixSimple;
        fileName = fileNameSimple;
    else
        nodes = nodesTwo;
        adjMatrix = adjMatrixTwo;
        fileName = fileNameTwo;
    end

    tic
    for i = 1:repetitions
        greenhouse = CorridorStructure(nodes, adjMatrix);
        greenhouse = greenhouse.init();

        sim = Simulator();
        sim.initSimulation(greenhouse, cfg.group, cfg.comRange, fileName, cfg.cycleTime, true, 1);

        while ~sim.isFinished()
            sim.simulate(1);
        end
        sim.updateStats();
        toc

        xml = xml2struct('new.xml');
        nResultNum = length(xml.results.result) + 1;
        nResult = xml.results.result{nResultNum - 1};
        nResult.id.Text = nResultNum;
        nResult.settings.routeTopology.Text = fileName;
        nResult.settings.configuration.Text = fileName;
        nResult.settings.communication.Text = cfg.comRange;
        nResult.settings.cycleTime.Text = cfg.cycleTime;
        nResult.settings.vehicles.Text = cfg.group;
        nResult.settings.algorithm.Text = 'Anticipatory';
        nResult.indicators.G1.Text = num2str(sim.g(1), '%.2f');
        nResult.indicators.G3.Text = num2str(sim.g(3), '%.2f');
        nResult.indicators.numOfRepairs.Text = sim.statNumOfRepairs;
        nResult.indicators.numOfKm.Text = sim.statNumOfKm;
        nResult.indicators.meanTimeToDiscoverFruitBush.Text = sim.statMeanTimeToDiscoverFruitBush;
        nResult.indicators.sumTimeToDiscoverFruitBush.Text = sim.stats.timeToDiscoverSum;
        nResult.indicators.mitigationTimePerSeverity.Text = sim.stats.mitigationTimePerSeverity;
        nResult.indicators.optContributionInMitFruitBushs.Text = sim.statOptimalTeamStepsSumForFruitBushs/sim.statMitigationStepsSumForFruitBushs;
        nResult.indicators.discoveredFruitBushsPercent.Text = sim.stats.discoveredPercent;
        nResult.indicators.ReloaddFruitBushsPercent.Text = sim.stats.ReloaddPercent;

        postfix = datestr(clock, 'yyyy_mm_dd_HH_MM_SS');
        save(['results/' resultFileName '_' num2str(i) '__' postfix], 'sim')
        

        xml.results.result{nResultNum} = nResult;

        struct2xml(xml, 'new.xml');
    end
end