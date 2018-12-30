addpath('external/');

close all;

code_len = 4;
partition_num = 3;

map_top_ratio=0.1;
mar_top_ratio=0.5;

num_of_data_used=1000;
num_of_query_used=200;

common;

figure(1);
hold 
plot(mar_HM,'r','LineWidth',2);
plot(mar_ASD,'g','LineWidth',2);
plot(mar_SD,'b','LineWidth',2);
legend('HM','ASD','SD');  

xlabel('num of top points used for cal Mean Average Ratio') 
ylabel('Mean Average Ratio') 