# 加载所需的 R 包
install.packages(c("microbiome", "zCompositions", "readxl", "writexl"))
library(microbiome)
library(zCompositions)
library(readxl)
library(writexl)

# 读取 Excel 文件中的示例数据
file_path <- "all-relative abundance.xlsx"  # 替换为实际文件路径
relative_abundance <- read_excel(file_path)

# 去掉第一列 ID，仅保留丰度数据
abundance_data <- relative_abundance[, -1]

# 删除零值超过 80% 的行，保留所有列
threshold <- 0.8
abundance_data <- abundance_data[rowSums(abundance_data == 0) / ncol(abundance_data) <= threshold, ]

# 用 zCompositions 包处理零值（CLR 变换需要非零值）
abundance_data_no_zeros <- cmultRepl(abundance_data, method="CZM", output="p-counts")

# 保留没有被删除的行的 ID
valid_ids <- relative_abundance[rownames(abundance_data), 1]

# 使用 microbiome 包进行中心对数比转换
clr_transformed_data <- microbiome::transform(abundance_data_no_zeros, "clr")

# 将结果添加回数据框中
clr_result <- data.frame(ID = valid_ids, clr_transformed_data)

# 打印结果
print(clr_result)

# 将结果写入另一个 Excel 文件
output_file_path <- "Unigenes.relative.s-clr.xlsx"  # 替换为实际输出文件路径
write_xlsx(clr_result, output_file_path)

# 示例数据：
# ID	BK1	BK2	BK3	BK4	BK5	BK6
# g__Unclassified;s__Caudoviricetes sp.	0.035578685	0.032543483	0.034723387	0.047792067	0.031233963	0.037772865
# g__Sodaliphilus;s__Sodaliphilus pleomorphus	0.019198454	0.019805751	0.016307917	0.013768275	0.019957322	0.014649782
# g__Unclassified;s__Clostridiales bacterium	0.021256891	0.016908592	0.018615586	0.010368927	0.017572651	0.016759142
# g__Prevotella;s__Prevotella sp. tc2-28	0.005311409	0.009326327	0.010005405	0.017097546	0.009498044	0.013914648
# g__Succiniclasticum;s__Succiniclasticum ruminis	0.008620012	0.010675615	0.009971591	0.013995985	0.007811466	0.007992319
# g__Prevotella;s__Prevotella ruminicola	0.005642197	0.00858417	0.008847612	0.013984717	0.008651407	0.011108239
