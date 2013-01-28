dir = "/mnt/mascot/data/20130108"
dirname = dir.split('/')[4].to_s

Dir["#{dir}/F001668.csv","#{dir}/F001669.csv","#{dir}/F001670.csv","#{dir}/F001671.csv"].each do |file|
	filename = file.split('/')[5].split('.')[0].to_s
	system("cp /mnt/mascot/data/#{dirname}/#{filename}.csv ~/#{dirname}/#{filename}.csv")
	puts "FILE: #{dirname} > #{filename} copied"
end