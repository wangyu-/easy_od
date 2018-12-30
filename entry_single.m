addpath('external/');

close all;

code_len = 15;
partition_num = 3;

map_top_ratio=0.1;
mar_top_ratio=0.5;

num_of_data_used=2000;
num_of_query_used=300;

common;

figure(1);
hold 
plot(mar_HM,'r','LineWidth',2);
plot(mar_ASD,'g','LineWidth',2);
plot(mar_SD,'b','LineWidth',2);
legend('HM','ASD','SD');  

xlabel('Num of Retrived Points') 
ylabel('Mean Average Ratio') 