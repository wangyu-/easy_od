addpath('external/');

map_top_ratio=0.2;
mar_top_ratio=0.5;

num_of_data_used=2000;
num_of_query_used=300;

partition_num =3;

map_HM_array=zeros(1,32);
map_ASD_array=zeros(1,32);
map_SD_array=zeros(1,32);

tmp_code_len=[8,16,24,32];
tmp_partition_num=[1,2,3,4];
for idx=1:4
    code_len=tmp_code_len(1,idx);
    partition_num=tmp_partition_num(1,idx);
    common;
    map_HM_array(1,code_len)=map_HM;
    map_ASD_array(1,code_len)=map_ASD;
    map_SD_array(1,code_len)=map_SD;
end

% figure(1);
hold on 
plot(map_HM_array,'.');
plot(map_ASD_array,'.');
plot(map_SD_array,'.');
legend('HM','ASD','SD');  
xlabel('code length') 
ylabel('mean avarage precision') 
