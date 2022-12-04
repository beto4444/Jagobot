%optional procedures

function ConstantTime(Axes, time)


    %define objects
    hold(uiaxes, "on");
    GH = Greenhouse(96, 900);
    plot(Axes, GH.Graphics);
    v1 = Vehicle(5, 5, GH);
        v1.SetSpeed(1);
    v1.SetTurn(45);
    plot(Axes, v1.Graphics);

    

    %main loop
    for i = 1:time
        v1.step;
        plot(Axes, v1.Graphics);
        pause(1);
    end

end