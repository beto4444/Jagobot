function [] = simAllGroups(cfg, repetitions) 

    for groups = 1:5
       switch groups
            case 1
                cfg.group = [4,4];
            case 2
                cfg.group = [3,5];
            case 3
                cfg.group = [5,3];
            case 4
                cfg.group = [8,0];
            case 5
                cfg.group = [0,8];
       end 
       
       fileName = ['result_', num2str(cfg.comRange), 'com_', ...
           num2str(cfg.group(1)), num2str(cfg.group(2)), 'gr'];
       simMany(cfg, repetitions, fileName);
    end
    
    
end