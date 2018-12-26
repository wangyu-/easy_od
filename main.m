addpath('external/');


code_len = 15;
partition_num = 3;

sub_code_len=ceil(code_len/partition_num);
padding_len=sub_code_len*partition_num-code_len;

assert(mod(code_len+padding_len,partition_num)==0);

code_length=code_len;
sub_code_space=2^sub_code_len;

randn('seed',0);

%%%%%%code adapted from author of this paper %%%%%%

fprintf('load data\n');
gen_mnist_dataset;

Xtraining=Xtraining(:,1:1000); %% wy add
Xtest=Xtest(:,1:100);%% wy add

dim = size(Xtraining, 1);

fprintf('generate binary codes\n');
mean_value = mean(Xtraining, 2);
W1T = randn(code_length, dim);
W2T = -W1T * mean_value;
W = [W1T'; W2T'];

c= bsxfun(@ge, W(1 : end - 1, :)' * Xtraining, -W(end, :)');
c_data=c; %%wy add
c = bsxfun(@ge, W(1 : end - 1, :)' * Xtest, -W(end, :)');
c_query=c; %%wy add
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


train_set=Xtraining;
test_set=Xtest;
dim_of_data = dim;
num_of_data = size(train_set,2);
dim_of_query=dim;
num_of_query=size(test_set,2);

top_rank=0.1*num_of_data;
top_mar_rank=0.5*num_of_data;

tmp_code_array=zeros(padding_len,num_of_data,'logical');
code_array=[c_data;tmp_code_array];

tmp_query_code_array=zeros(padding_len,num_of_query,'logical');
query_code_array=[c_query;tmp_query_code_array];

subcode_array=ones(partition_num,num_of_data,'uint32');

fprintf('before compute subcode_array\n');
for i=1:num_of_data
    for j=1:partition_num
        tmp_code=0;
        for k=1:sub_code_len
            tmp_code=tmp_code*2+uint32(code_array((j-1)*sub_code_len+k,i));
        end 
        subcode_array(j,i)=tmp_code;
    end
end
fprintf('after compute subcode_array\n');

query_subcode_array=ones(partition_num,num_of_data,'uint32');

fprintf('before compute query_subcode_array\n');
for i=1:num_of_query
    for j=1:partition_num
        tmp_code=0;
        for k=1:sub_code_len
            tmp_code=tmp_code*2+uint32(query_code_array((j-1)*sub_code_len+k,i));
        end 
        query_subcode_array(j,i)=tmp_code;
    end
end
fprintf('after compute query_subcode_array\n');

fprintf('before compute A\n');
A=zeros(num_of_data,num_of_data);
for i=1:num_of_data
    for j=1:num_of_data
        A(i,j)=norm(train_set(:,i)-train_set(:,j))^2;
    end
end
fprintf('after compute A\n');

fprintf('before compute R\n');
R=cell(1,partition_num);
for i=1:partition_num
    tmp_R=zeros(num_of_data,sub_code_space,'logical');
    for j=1:num_of_data
        idx=subcode_array(i,j)+1;
        tmp_R(j,idx)=1;
    end
    R{1,i}=tmp_R;
end
fprintf('after compute R\n');
%{
E=cell(partition_num,partition_num);

for i=1:partition_num
    for j=1:partition_num
        E{i,j}=R{1,i}'*R{1,j};
    end
end
%}
fprintf('before compute array_E2\n');
array_E2=zeros(sub_code_space,sub_code_space,partition_num,partition_num,'double');
for i=1:num_of_data
    for j=1:partition_num
        for k=1:partition_num
            m=subcode_array(j,i)+1;
            n=subcode_array(k,i)+1;
            array_E2(m,n,j,k)= ... 
              array_E2(m,n,j,k) + uint32(R{1,j}(i,m)&&R{1,k}(i,n));
        end
    end
end

fprintf('after compute array_E2\n');


E2=cell(partition_num,partition_num);
for i=1:partition_num
    for j=1:partition_num
        E2{i,j}=array_E2(:,:,i,j);
    end
end

E=E2;

%{
cc=cell(partition_num,sub_code_space);

for i=1:partition_num
    for j=1:sub_code_space
        sum=zeros(dim_of_data,1);
        if E{i,i}(j,j)==0
            cc{i,j}=sum;
        else
            for k=1:num_of_data
                sum=sum+R{1,i}(k,j)*train_set(:,k);
            end
            cc{i,j}=sum/E{i,i}(j,j);
        end
    end
end
%}

fprintf('before compute array_cc2\n');

array_cc2=zeros(dim_of_data,sub_code_space,partition_num);

for i=1:partition_num
    for j=1:num_of_data
        tmp_code=subcode_array(i,j)+1;
        array_cc2(:,tmp_code,i)=array_cc2(:,tmp_code,i)+train_set(:,j)/E{i,i}(tmp_code,tmp_code);
    end
end

cc2=cell(partition_num,sub_code_space);
for i=1:partition_num
    for j=1:sub_code_space
       cc2{i,j}=array_cc2(:,j,i);
    end
end

cc=cc2;

fprintf('after compute array_cc2\n');

%{
ee=cell(partition_num,sub_code_space);

for i=1:partition_num
    for j=1:sub_code_space
        sum=0;
        if E{i,i}(j,j)==0
            ee{i,j}=sum;
        else
            for k=1:num_of_data
                sum=sum+R{1,i}(k,j)* (norm(train_set(:,k)-cc{i,j})^2);
            end
            ee{i,j}=sum/E{i,i}(j,j);
        end
    end
end
%}

fprintf('before compute array_ee2\n');

array_ee2=zeros(partition_num,sub_code_space);

for i=1:partition_num
    for j=1:num_of_data
        tmp_code=subcode_array(i,j)+1;
        array_ee2(i,tmp_code)=array_ee2(i,tmp_code)+(norm( train_set(:,j) -cc{i,tmp_code})^2)/E{i,i}(tmp_code,tmp_code);
    end
end

ee2=cell(partition_num,sub_code_space);
for i=1:partition_num
    for j=1:sub_code_space
       ee2{i,j}=array_ee2(i,j);
    end
end

ee=ee2;
fprintf('after compute array_ee2\n');

flat_E=cell2mat(E);

fprintf('before pinv(flat_E)\n');
inv_flat_E=pinv(flat_E);
fprintf('after pinv(flat_E)\n');

%tmp=(1:partition_num)*sub_code_space;
inv_E=mat2cell(inv_flat_E,ones(1,partition_num)*sub_code_space,ones(1,partition_num)*sub_code_space); 

%tmp=invE(1,:)

%{
G=cell(partition_num,partition_num);

for i=1:partition_num
    for j=1:partition_num
        G{i,j}=R{1,i}'*A*R{1,j};
    end
end
%}


  
%THIS IS ONLY FOR SYMMETRIC
G2=cell(partition_num,partition_num); 
for i=1:partition_num
    for j=1:partition_num
        G2{i,j}=zeros(sub_code_space,sub_code_space);
        for k=1:sub_code_space
            for l=1:sub_code_space
                G2{i,j}(k,l)=E{i,i}(k,k)*E{j,j}(l,l)*((norm(cc{i,k}-cc{j,l})^2)+ee{i,k}+ee{j,l});
            end
        end
    end
end

G=G2;

flat_G=cell2mat(G);


%{
D=cell(partition_num,partition_num);

for i=1:partition_num
    for j=1:partition_num
        D{i,j}=invE{i,j}'*G{i,j}*invE{i,j}';
    end
end
%}


flat_D2=inv_flat_E*flat_G*inv_flat_E;

D2=mat2cell(flat_D2,ones(1,partition_num)*sub_code_space,ones(1,partition_num)*sub_code_space);

D=D2;


fprintf('before compute AQ\n');
AQ=zeros(num_of_data,num_of_query);

for i=1:num_of_data
    for j=1:num_of_query
        AQ(i,j)=norm(train_set(:,i)-test_set(:,j))^2;
    end
end
fprintf('after compute AQ\n');


%{
GQ=cell(partition_num,num_of_query);
for i=1:num_of_query
    for j=1:partition_num
        GQ{j,i}=(AQ(:,i)'*R{1,j})';
    end
end

%}

%flat_GQ=cell2mat(GQ);

fprintf('before compute GQ2\n');
GQ2=cell(partition_num,num_of_query);
for i=1:num_of_query
    for j=1:partition_num
        GQ2{j,i}=zeros(sub_code_space,1);
        for k=1:sub_code_space
            GQ2{j,i}(k,1)=E{j,j}(k,k)*(norm(test_set(:,i)-cc{j,k})^2+ee{j,k});
        end
    end
end
fprintf('after compute GQ2\n');

GQ=GQ2;

flat_GQ=cell2mat(GQ);

fprintf('before compute DQ\n');
flat_DQ=inv_flat_E*flat_GQ;
DQ=mat2cell(flat_DQ,ones(1,partition_num)*sub_code_space,ones(1,num_of_query));
fprintf('after compute DQ\n')

tic
ASD=zeros(num_of_data,num_of_query);
for i=1:num_of_query
    for j=1:num_of_data
        ASD(j,i)=cal_asd(i,j,partition_num,DQ,subcode_array);
    end
end
qt_ASD=toc;

tic
SD=zeros(num_of_data,num_of_query);
for i=1:num_of_query
    for j=1:num_of_data
        SD(j,i)=cal_sd(i,j,partition_num,D,subcode_array,query_subcode_array);
    end
end
qt_SD=toc;

tic
HM=zeros(num_of_data,num_of_query);
for i=1:num_of_query
    for j=1:num_of_data
        HM(j,i)=cal_hm(i,j,partition_num,subcode_array,query_subcode_array);
    end
end
qt_HM=toc;

fprintf('all done\n');

ASD_rank=sort_by_colomn(ASD,num_of_data,num_of_query);
SD_rank=sort_by_colomn(SD,num_of_data,num_of_query);
HM_rank=sort_by_colomn(HM,num_of_data,num_of_query);
AQ_rank=sort_by_colomn(AQ,num_of_data,num_of_query);

map_AQ=cal_map(AQ_rank,AQ_rank,top_rank,num_of_query);
map_HM=cal_map(AQ_rank,HM_rank,top_rank,num_of_query);
map_ASD=cal_map(AQ_rank,ASD_rank,top_rank,num_of_query);
map_SD=cal_map(AQ_rank,SD_rank,top_rank,num_of_query);

mar_AQ=cal_mar(AQ_rank,AQ_rank,top_mar_rank,num_of_query,AQ);
mar_HM=cal_mar(AQ_rank,HM_rank,top_mar_rank,num_of_query,AQ);
mar_ASD=cal_mar(AQ_rank,ASD_rank,top_mar_rank,num_of_query,AQ);
mar_SD=cal_mar(AQ_rank,SD_rank,top_mar_rank,num_of_query,AQ);

hold 
plot(mar_HM,'r','LineWidth',2);
plot(mar_ASD,'g','LineWidth',2);
plot(mar_SD,'b','LineWidth',2);
legend('HM','ASD','SD');  

xlabel('num of top points used for cal Mean Average Ratio') 
ylabel('Mean Average Ratio') 

function map=cal_map(base,input,top_rank,num_of_query)
    map=0;
    for i=1:num_of_query
        map=map+ length(intersect(base(1:top_rank,i),input(1:top_rank,i)))*1.0/top_rank/num_of_query;
    end
end

function mar=cal_mar(base,input,top_mar_rank,num_of_query,AQ)
    mar=zeros(1,top_mar_rank);
    for i=1:num_of_query
        for j=1:top_mar_rank
            base_idx=base(j,i);
            input_idx=input(j,i);
            mar(1,j)=mar(1,j)+(AQ(input_idx,i)/AQ(base_idx,i))^0.5;
        end
    end
    for i=2:top_mar_rank
        mar(1,i)=mar(1,i)+mar(1,i-1);
    end
    for i=1:top_mar_rank
        mar(1,i)=mar(1,i)/i/num_of_query;
    end
end
function asd = cal_asd(q_idx,d_idx,partition_num,DQ,subcode_array)
    asd=0;
    for i=1:partition_num
        tmp_code=subcode_array(i,d_idx)+1;
        asd=asd+DQ{i,q_idx}(tmp_code,1);
    end
end

function sd = cal_sd(q_idx,d_idx,partition_num,D,subcode_array,query_subcode_array)
    sd=0;
    for i=1:partition_num
        tmp_code_q=query_subcode_array(i,q_idx)+1;
        for j=1:partition_num
            tmp_code_d=subcode_array(j,d_idx)+1;
            sd=sd+D{i,j}(tmp_code_q,tmp_code_d);
        end
    end
end

function hm=cal_hm(q_idx,d_idx,partition_num,subcode_array,query_subcode_array)
    hm=0;
    for i=1:partition_num
        tmp=bitxor(query_subcode_array(i,q_idx),subcode_array(i,d_idx));
        hm=hm+sum(bitget(tmp,1:32));
    end
end

function ret=sort_by_colomn(mat,r_num,c_num)
    ret=zeros(r_num,c_num);
    for i=1:c_num
        tmp=mat(:,i);
        [~,idx]=sort(tmp);
        ret(:,i)=idx;
    end
end
%G2=mat2cell(flat_G2,ones(1,partition_num)*sub_code_space,ones(1,partition_num)*sub_code_space);
