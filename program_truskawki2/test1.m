s = Strawberry(1, 0, 1, 1);





hugearray=cell(88, 16);

for i=1:16
    for j=1:88
        
        n = randi(21)-1;
        temp = [];
        if(n>0)
            for k=1:n
                l = Strawberry(1, 0, 1, 1);
                temp = [temp l];
            end
        end
        hugearray{i, j}=temp;
    end
end






