# USAGE:
# ruby find_peptides.rb ../data/PennDev_csvs/F001671_with_pipes.csv 100.0 ../results/penndev_highest_scored_peptides_no_cutoff.xlsx ../results/penndev_highest_scored_peptides_sorted.csv 

# find the highest scored peptide of the different replicates, and sorts the peptides list by expectancy
# require 'rubygems'
require 'mascot_hits_csv_parser'

infile = ARGV[0]
cutoff = ARGV[1].to_f
highest_scored_peptides_ofile = ARGV[2]
highest_scored_peptides_sorted_ofile = ARGV[3]

# initialize arguments
mascot_csvp = MascotHitsCSVParser.open(infile, cutoff)
highest_scored_peptides_out = File.open(highest_scored_peptides_ofile, "w")

# get the highest scored hit of each peptide, with rank = 1 and Phospho modified
# 2 Phospho (ST); Phospho (Y)  
# Phospho (ST); 2 Phospho (Y)
# Phospho (ST)
# 3 Phospho (ST)
# 3 Oxidation (M); 2 Phospho (ST)
highest_scored_hits = {}
mascot_csvp.each_peptide do |peptide|
	highest_scored_hit = mascot_csvp.highest_scored_hit_for_pep(peptide)
	pep_expectancy = highest_scored_hit.pep_expect
	highest_scored_hits[peptide] = highest_scored_hit
end

# create the peptides list
highest_scored_peptides_out.puts "PROT_HIT_NUM, PROT_ACC, UNIPROT_LINK, GENENAME, PROT_DESC, PROT_SCORE, PROT_MASS, PROT_MATCH_SIG, PROT_MATCH, QUERY, PEP_SCORE, PEP_EXPECTANCY, PEP_SEQ, PEP_MODIFICATION, TITLE, REPLICATE"
highest_scored_hits.each do |peptide, highest_scored_hit|
	prot_hit_num = highest_scored_hit.prot_hit_num.to_i
	prot_acc = highest_scored_hit.prot_acc.to_s
	uniprot_link = "http://www.uniprot.org/uniprot/#{prot_acc}"
	prot_desc = highest_scored_hit.prot_desc.to_s
	if prot_desc.include? "GN="
		genename = prot_desc.split("GN=")[1].split(" ")[0].to_s
	else
		genename = 'NA'
	end
	prot_score = highest_scored_hit.prot_score.to_f
	prot_mass = highest_scored_hit.prot_mass.to_i
	prot_matches_sig = highest_scored_hit.prot_matches_sig.to_f
	prot_matches = highest_scored_hit.prot_matches.to_i
	query = highest_scored_hit.pep_query.to_s
	pep_score = highest_scored_hit.pep_score.to_f
	pep_expect = highest_scored_hit.pep_expect.to_f
	pep_seq = highest_scored_hit.pep_seq.to_s
	pep_var_mod = highest_scored_hit.pep_var_mod.to_s
	pep_scan_title = highest_scored_hit.pep_scan_title.to_s
	replicate = pep_scan_title.split("Zebrafish_Penn_Dev_B2_")[1].split("_")[0]

	highest_scored_peptides_out.puts "\"#{prot_hit_num}\",\"#{prot_acc}\",\"#{uniprot_link}\n\",\"#{genename}\",\"#{prot_desc}\",\"#{prot_score}\",\"#{prot_mass}\",\"#{prot_matches_sig}\",\"#{prot_matches}\",\"#{query}\",\"#{pep_score}\",\"#{pep_expect}\",\"#{pep_seq}\",\"#{pep_var_mod}\",\"#{pep_scan_title}\",\"#{replicate}\" "
end
highest_scored_peptides_out.close

# # sort the peptides list by expectancy
# highest_scored_peptides_list = FasterCSV.read(highest_scored_peptides_ofile)
# highest_scored_peptides_sorted = FasterCSV.open(highest_scored_peptides_sorted_ofile,"w")
# highest_scored_peptides_sorted do |out|
#   highest_scored_peptides_list.sort_by { |row| row.values_at(11) }.each do |row|
#     out << row
#   end
# end
# highest_scored_peptides_sorted.close

