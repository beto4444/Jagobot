function test()

fig = uifigure('Position', [100 100 500 250]);
ax = uiaxes(fig);
ax.Position = [0 0 500 250];

leakPrinter = LeakPrinter(ax);

leakPrinter.addVehicle();
leakPrinter.addVehicle(); 
leakPrinter.addVehicle();

end



