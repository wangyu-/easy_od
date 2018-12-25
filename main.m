addpath('external/');

code_len = 30;
partition_num = 3;

sub_code_len=ceil(code_len/3);
padding_len=sub_code_len*partition_num-code_len;

assert(mod(code_len+padding_len,partition_num)==0);

code_length=code_len;
sub_code_space=2^sub_code_len;
randn('seed',0);

%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('load data\n');
gen_mnist_dataset;

dim = size(Xtraining, 1);

fprintf('generate binary codes\n');
mean_value = mean(Xtraining, 2);
W1T = randn(code_length, dim);
W2T = -W1T * mean_value;
W = [W1T'; W2T'];

c = bsxfun(@ge, W(1 : end - 1, :)' * Xtraining, -W(end, :)');
%%%%%%%%%%%%%%%%%%%%%%%%%


train_set=Xtraining;
test_set=Xtest;
dim_of_data = dim;
num_of_data = size(train_set,2);
dim_of_query=dim;
num_of_query=size(test_set,2);

tmp_code_array=zeros(padding_len,num_of_data,'logical');
code_array=[c;tmp_code_array];

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

%{
R_not_used=zeros(partition_num,num_of_data,sub_code_space,'logical');
for i=1:partition_num
    for j=1:num_of_data
        R_not_used(i,j,subcode_array(i,j)+1)=1;
    end
end
%}
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




  
%{
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

flat_D=inv_flat_E*flat_G*inv_flat_E;

D=mat2cell(flat_D,ones(1,partition_num)*sub_code_space,ones(1,partition_num)*sub_code_space);
%}

%{
D=cell(partition_num,partition_num);

for i=1:partition_num
    for j=1:partition_num
        D{i,j}=invE{i,j}'*G{i,j}*invE{i,j}';
    end
end
%}

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

%G2=mat2cell(flat_G2,ones(1,partition_num)*sub_code_space,ones(1,partition_num)*sub_code_space);
fprintf('all done\n');