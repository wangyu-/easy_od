addpath('external/');

close all;

map_top_ratio=0.2;
mar_top_ratio=0.5;

num_of_data_used=2000;
num_of_query_used=200;

partition_num =3;

code_len_list=[8,16,24,32];
partition_num_list=[1,2,3,4];
list_len=length(partition_num_list);

map_HM_array=zeros(1,list_len);
map_ASD_array=zeros(1,list_len);
map_SD_array=zeros(1,list_len);

for ii=1:4
    code_len=code_len_list(1,ii);
    partition_num=partition_num_list(1,ii);
    common;
    map_HM_array(1,ii)=map_HM;
    map_ASD_array(1,ii)=map_ASD;
    map_SD_array(1,ii)=map_SD;
end

figure(1);

hold on 
plot(code_len_list,map_HM_array,'r-o','LineWidth',1.7);
plot(code_len_list,map_ASD_array,'g-o','LineWidth',1.7);
plot(code_len_list,map_SD_array,'b-o','LineWidth',1.7);
legend('HM','ASD','SD');  
xlabel('Code Length') 
ylabel('Mean Avarage Precision') 
