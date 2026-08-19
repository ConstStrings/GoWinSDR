% =========================================================
% 生成数字根升余弦 (RRC) 滤波器并自动计算硬件截位范围
% =========================================================
clear; clc; close all;

%% 1. 定义核心设计参数
alpha = 0.25;       % 滚降系数
span = 6;           % 符号跨度
sps = 4;            % 过采样率
bit_width = 16;     % 目标 FPGA 硬件的系数位宽 (16-bit)

%% 2. 生成并定点化系数
h_rrc = rcosdesign(alpha, span, sps, 'sqrt');
scale_factor = 2^(bit_width - 1) - 1;
h_rrc_fixed = round(h_rrc * scale_factor);

%% 3. 计算最佳截位 (Bit Slicing) 和右移位数
% 定义硬件接口参数
input_bit_width = 12;  % 基带输入数据位宽
dac_bit_width = 12;    % 目标 DAC (如 AD9363) 的数据位宽

% 1. 计算输入信号的最大绝对值 (16-bit 有符号数: 32767)
max_in_val = 2^(input_bit_width - 1) - 1; 

% 2. 计算 FIR 滤波器理论上的最大输出绝对值
% FIR 最大可能输出 = 输入最大幅度 * sum(abs(所有系数))
max_fir_out_val = max_in_val * sum(abs(h_rrc_fixed));

% 3. 计算 DAC 能够接收的最大绝对值 (12-bit 有符号数: 2047)
max_dac_val = 2^(dac_bit_width - 1) - 1;

% 4. 计算需要的右移位数 (Shift)
% 公式: max_fir_out_val / (2^shift) <= max_dac_val
shift_bits = ceil(log2(max_fir_out_val / max_dac_val));

% 5. 计算要截取的最高位和最低位索引
msb_index = shift_bits + dac_bit_width - 1;
lsb_index = shift_bits;

%% 4. 打印结果
fprintf('=====================================================\n');
fprintf('硬件截位分析结果\n');
fprintf('=====================================================\n');
fprintf('FIR 系数绝对值总和: %d\n', sum(abs(h_rrc_fixed)));
fprintf('FIR 理论最大输出值: %d (约需要 %d bits 才能不溢出)\n', round(max_fir_out_val), ceil(log2(max_fir_out_val))+1);
fprintf('-----------------------------------------------------\n');
fprintf('为了适配 %d-bit DAC，建议丢弃低位 (右移): %d 位\n', dac_bit_width, shift_bits);
fprintf('【Verilog 截位建议】: fir_data_o[%d : %d]\n', msb_index, lsb_index);
fprintf('=====================================================\n\n');

%% 5. 生成 FPGA 支持的 .coe 文件 (与之前相同)
% 设置输出文件名 (可以根据需要修改后缀，例如 .txt 或 .dat)
filename = 'filter_coef_plain.txt';

% 打开文件以写入
fid = fopen(filename, 'w');
if fid == -1
    error('无法创建文件，请检查当前文件夹权限。');
end

% 遍历定点化系数数组，逐行写入
for i = 1:length(h_rrc_fixed)
    % %d 表示以十进制整数写入，\n 表示换行
    % 注意这里去掉了之前代码里的逗号和分号
    fprintf(fid, '%d\n', h_rrc_fixed(i));
end

% 关闭文件
fclose(fid);
fprintf('成功！系数已按纯文本垂直列表格式保存为: %s\n', filename);