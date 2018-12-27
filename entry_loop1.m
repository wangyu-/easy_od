addpath('external/');

map_top_ratio=0.1;
mar_top_ratio=0.5;

num_of_data_used=1000;
num_of_query_used=300;

code_len = 16;

map_HM_array=zeros(1,6);
map_ASD_array=zeros(1,6);
map_SD_array=zeros(1,6);

qt_ASD_array=zeros(1,6);
qt_SD_array=zeros(1,6);
qt_HM_array=zeros(1,6);

tt_ASD_array=zeros(1,6);
tt_SD_array=zeros(1,6);

for partition_num=2:6
    common;
    map_HM_array(1,partition_num)=map_HM;
    map_ASD_array(1,partition_num)=map_ASD;
    map_SD_array(1,partition_num)=map_SD;
    tt_ASD_array(1,partition_num)=tt_ASD;
    tt_SD_array(1,partition_num)=tt_SD;
    
    qt_ASD_array(1,partition_num)=qt_ASD_total;
    qt_SD_array(1,partition_num)=qt_SD;
    qt_HM_array(1,partition_num)=qt_HM;
end

map_HM_array(1,1)=map_HM_array(1,2);
map_ASD_array(1,1)=map_ASD_array(1,2);
map_SD_array(1,1)=map_SD_array(1,2);

tt_ASD_array(1,1)=tt_ASD_array(1,2);
tt_SD_array(1,1)=tt_SD_array(1,2);

qt_ASD_array(1,1)=qt_ASD_array(1,2);
qt_SD_array(1,1)=qt_SD_array(1,2);
qt_HM_array(1,1)=qt_HM_array(1,2);

figure(1);
hold on 
plot(map_HM_array,'r','LineWidth',2);
plot(map_ASD_array,'g','LineWidth',2);
plot(map_SD_array,'b','LineWidth',2);
legend('HM','ASD','SD');  
xlabel('num of partitions') 
ylabel('mean avarage precision') 


figure(2);
hold on 
plot(tt_ASD_array,'r','LineWidth',2);
plot(tt_SD_array,'g','LineWidth',2);
legend('ASD','SD');  
xlabel('num of partitions') 
ylabel('training time') 


figure(3);
hold on 
plot(qt_HM_array,'r','LineWidth',2);
plot(qt_ASD_array,'g','LineWidth',2);
plot(qt_SD_array,'b','LineWidth',2);
legend('HM','ASD','SD'); 

