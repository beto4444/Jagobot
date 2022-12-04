function [nodes, adjMatrix, chambers] = getGreenhouseConfigurationtest(xcustom, ycustom, numbercustom, lengthcustom, widthcustom)
        chambers = [];

            startpointx=xcustom;
            startpointy=ycustom;
            number=numbercustom;
            length=lengthcustom;
            width=widthcustom;
        
%         cd('configs');
%         data=readmatrix(filename, "Sheet", "mapconfig", "Range", "B1:B5");
%         startpointx=data(1,1);
%         startpointy=data(2,1);
%         number=data(3,1);
%         length=data(4,1);
%         width=data(5,1);
%         cd('..');
   
% adjMatrix=zeros(36, 36);        
% nodes=cell(1, 36);
% for i=1:8
%     if i<=4
%         ycoord=80+110*(i-1);
%     else
%         ycoord=550+110*(i-5);
%     end
% 
%         nodes{1,4*i-3}=[100, ycoord-11.25];
%         nodes{1,4*i-2}=[8900, ycoord-11.25];
%         nodes{1,4*i-1}=[100, ycoord+11.25];
%         nodes{1, 4*i}=[8900, ycoord+11.25];
% end
% 
% nodes{1, 33}=[0,0];
% nodes{1,34}=[9000 , 0];
% nodes{1,35}=[0, 9000];
% nodes{1,36}=[9000, 9000];



for i=1:9
adjMatrix(1+4*(i-1), 2+4*(i-1))=1;
adjMatrix(1+4*(i-1), 3+4*(i-1))=1;
adjMatrix(4+4*(i-1), 2+4*(i-1))=1;
adjMatrix(4+4*(i-1), 3+4*(i-1))=1;

adjMatrix(2+4*(i-1), 1+4*(i-1))=1;
adjMatrix(2+4*(i-1), 4+4*(i-1))=1;
adjMatrix(3+4*(i-1), 1+4*(i-1))=1;
adjMatrix(3+4*(i-1), 4+4*(i-1))=1;

    


end
 
%             chambers = [3, 7];
end