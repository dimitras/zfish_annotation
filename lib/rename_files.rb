# USAGE: 
# ruby rename_files.rb ../raw/Clarkson/raw/N3
# ruby rename_files.rb ../raw/Clarkson/raw/WT
# rename raw files and zip by groups

# # N3
# raw_path = ARGV[0]
# Dir[raw_path + "*.raw"].each do |raw_file|
# 	filename = File.basename(raw_file, File.extname(raw_file))
# 	new_filename = "ExpKW01_N3" + filename.split("Zebrafish_Choke_B1")[1]
# 	File.rename(raw_file, raw_path + "/" + new_filename + File.extname(raw_file))
# end

# WT
raw_path = ARGV[0]
Dir[raw_path + "*.raw"].each do |raw_file|
	filename = File.basename(raw_file, File.extname(raw_file))
	new_filename = "ExpKW01_WT" + filename.split("Zebrafish_Choke_WT_B1")[1]
	File.rename(raw_file, raw_path + "/" + new_filename + File.extname(raw_file))
end
