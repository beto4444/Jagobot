function [nodes, adjMatrix, chambers] = getGreenhouseConfiguration(xcustom, ycustom, numbercustom, lengthcustom, widthcustom)
        chambers = [];
        cd('configs');
%         data=readmatrix(filename, "Sheet", "mapconfig", "Range", "B1:B5");
        startpointx=xcustom;
        startpointy=ycustom;
        number=numbercustom;
        length=lengthcustom;
        width=widthcustom;
        cd('..');



        %nodes={[0,0], [9600, 0], [0, 300], [9600, 300], [0, 600], [9600, 600]};

        %adjMatrix=[0 1 1 0 0 0; 1 0 0 1 0 0; 1 0 0 1 1 0; 0 1 1 0 0 1; 0 0 1 0 0 1; 0 0 0 1 1 0];
         nodes=cell(1, number*2);
         for i=1:(number*2)
             if i<=number
                nodes{1,i}=[width*(i-1)+startpointx, startpointy]; 
             
             else
                nodes{1,i}=[width*(i-number-1)+startpointx, startpointy+length];
             end
         end
         
         adjMatrix=zeros(number*2);
 
         for i=1:(number*2)
             for j=1:(number*2)
                 if abs(i-j)==1
                     adjMatrix(i,j)=1;
                 elseif abs(i-j)==number
                     adjMatrix(i,j)=1;
                 end
             end            
         end
         adjMatrix(number,number+1)=0; adjMatrix(number+1, number)=0;
end