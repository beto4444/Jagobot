function GrowthModel(Strawberry)
    x=Strawberry.Age;
    %Variety=Strawberry.Variety;
    CurrentState=Strawberry.State;
    testnum=rand;
    rottenlimit=(2*x/(75^2));
    growthlimit=(exp(-(x-30)/0.7))/(0.7*(1+exp(-(x-30)/0.7))^2);
    Strawberry.AddAge;
        

    if(CurrentState==0)
        

        if (testnum<rottenlimit)
           Strawberry.changeState(-1);

        elseif(testnum<growthlimit)
           Strawberry.changeState(1);

        end

    elseif(CurrentState==1)
        if (testnum<rottenlimit)
           Strawberry.changeState(-1);
        end
    end
    
end