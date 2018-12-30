addpath('external/');

close all;

map_top_ratio=0.1;
mar_top_ratio=0.5;

num_of_data_used=2000;
num_of_query_used=300;

code_len = 16;

partition_num_list=[2,3,4,5,6];
list_len=length(partition_num_list);

map_HM_array=zeros(1,list_len);
map_ASD_array=zeros(1,list_len);
map_SD_array=zeros(1,list_len);

qt_ASD_array=zeros(1,list_len);
qt_SD_array=zeros(1,list_len);
qt_HM_array=zeros(1,list_len);

tt_ASD_array=zeros(1,list_len);
tt_SD_array=zeros(1,list_len);


for ii=1:5
    partition_num=partition_num_list(ii);
    common;
    map_HM_array(1,ii)=map_HM;
    map_ASD_array(1,ii)=map_ASD;
    map_SD_array(1,ii)=map_SD;
    tt_ASD_array(1,ii)=tt_ASD;
    tt_SD_array(1,ii)=tt_SD;
    
    qt_ASD_array(1,ii)=qt_ASD_total;
    qt_SD_array(1,ii)=qt_SD;
    qt_HM_array(1,ii)=qt_HM;
end

figure(1);
hold on 
plot(partition_num_list,map_HM_array,'r-o','LineWidth',2);
plot(partition_num_list,map_ASD_array,'g-o','LineWidth',2);
plot(partition_num_list,map_SD_array,'b-o','LineWidth',2);
legend('HM','ASD','SD');  
xlabel('Num of Partitions') 
ylabel('Mean Avarage Precision') 


figure(2);
hold on 
plot(partition_num_list,tt_ASD_array,'r-o','LineWidth',2);
plot(partition_num_list,tt_SD_array,'g-o','LineWidth',2);
legend('ASD','SD');  
xlabel('Num of Partitions') 
ylabel('Training Time') 


figure(3);
hold on 
plot(partition_num_list,qt_HM_array,'r-o','LineWidth',2);
plot(partition_num_list,qt_ASD_array,'g-o','LineWidth',2);
plot(partition_num_list, qt_SD_array,'b-o','LineWidth',2);
legend('HM','ASD','SD'); 
xlabel('Num of Partitions'); 
ylabel('Query Time');
