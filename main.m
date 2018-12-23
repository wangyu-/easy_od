addpath('external/');

code_len = 11;
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

tmp_code_array=zeros(padding_len,num_of_data,'logical');
code_array=[c;tmp_code_array];

subcode_array=ones(partition_num,num_of_data,'uint32');
for i=1:num_of_data
    for j=1:partition_num
        tmp_code=0;
        for k=1:sub_code_len
            tmp_code=tmp_code*2+uint32(code_array((j-1)*sub_code_len+k,i));
        end 
        subcode_array(j,i)=tmp_code;
    end
end


R_not_used=zeros(partition_num,num_of_data,sub_code_space,'logical');
for i=1:partition_num
    for j=1:num_of_data
        R_not_used(i,j,subcode_array(i,j)+1)=1;
    end
end


R=cell(1,partition_num);
for i=1:partition_num
    tmp_R=zeros(num_of_data,sub_code_space,'logical');
    for j=1:num_of_data
        tmp_R(j,subcode_array(i,j)+1)=1;
    end
    R{1,i}=tmp_R;
end

E=cell(partition_num,partition_num);

for i=1:partition_num
    for j=1:partition_num
        E{i,j}=R{1,i}'*R{1,j};
    end
end

fprintf('all done\n');