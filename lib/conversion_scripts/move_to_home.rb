# move csv files to home

Dir["/mnt/mascot/data/2013010*"].each do |dir|
		dirname = dir.split('/')[4].to_s
		Dir["/mnt/mascot/data/#{dirname}/*.csv"].each do |file|
			filename = file.split('/')[5].split('.')[0].to_s
			system("cp /mnt/mascot/data/#{dirname}/#{filename}.csv ~/#{dirname}/#{filename}.csv")
		end
end
