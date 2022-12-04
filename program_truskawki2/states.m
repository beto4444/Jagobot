
function t = states(fruitarray, i, j)
    temp = fruitarray{i, j};
    total=size(temp, 2);
    unmature = 0;
    mature = 0;
    rotten = 0;

    if(total>0)
    for i=1:total
        if(temp(i).State==0)
            unmature=unmature+1;
        elseif(temp(i).State==1)
            mature=mature+1;
        elseif(temp(i).State==-1)
            rotten=rotten+1;
        end

    end
    end

    t = [unmature, mature, rotten, total];
end

