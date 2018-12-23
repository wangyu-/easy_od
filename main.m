addpath('external/');

code_len = 11;
partition_num = 3;

sub_code_len=ceil(code_len/3);
padding_len=sub_code_len*partition_num-code_len;

assert(mod(code_len+padding_len,partition_num)==0);

code_length=code_len;
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
%base_binary_code = compactbit(c);
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

