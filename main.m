addpath('external/');

code_len = 16;
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

A=zeros(num_of_data,num_of_data);
for i=1:num_of_data
    for j=1:num_of_data
        A(i,j)=norm(train_set(:,i)-train_set(:,j));
    end
end

R=cell(1,partition_num);
for i=1:partition_num
    tmp_R=zeros(num_of_data,sub_code_space,'logical');
    for j=1:num_of_data
        idx=subcode_array(i,j)+1;
        tmp_R(j,idx)=1;
    end
    R{1,i}=tmp_R;
end

%{
E=cell(partition_num,partition_num);

for i=1:partition_num
    for j=1:partition_num
        E{i,j}=R{1,i}'*R{1,j};
    end
end
%}

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

E2=cell(partition_num,partition_num);
for i=1:partition_num
    for j=1:partition_num
        E2{i,j}=array_E2(:,:,i,j);
    end
end

E=E2;

G=cell(partition_num,partition_num);

for i=1:partition_num
    for j=1:partition_num
        G{i,j}=R{1,i}'*A*R{1,j};
    end
end

fprintf('all done\n');

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


flat_E=cell2mat(E);
inv_flat_E=pinv(flat_E);

%tmp=(1:partition_num)*sub_code_space;
invE=mat2cell(inv_flat_E,ones(1,partition_num)*sub_code_space,ones(1,partition_num)*sub_code_space); 

%tmp=invE(1,:)

D=cell(partition_num,partition_num);

for i=1:partition_num
    for j=1:partition_num
        D{i,j}=invE{i,j}'*G{i,j}*invE{i,j}';
    end
end

G2=cell(partition_num,partition_num); 
for i=1:partition_num
    for j=1:partition_num
        G2{i,j}=zeros(sub_code_space,sub_code_space);
        for k=1:sub_code_space
            for l=1:sub_code_space
                G2{i,j}(k,l)=E{i,i}(k,k)*E{j,j}(l,l)*(norm(cc{i,k}-cc{j,l})^2+ee{i,k}+ee{j,l});
            end
        end
    end
end

%G2=mat2cell(flat_G2,ones(1,partition_num)*sub_code_space,ones(1,partition_num)*sub_code_space);