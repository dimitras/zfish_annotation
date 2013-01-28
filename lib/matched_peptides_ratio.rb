# USAGE:
# ruby matched_peptides_ratio.rb ../data/Clarkson_csvs/N3/F001662_with_pipes.csv ../data/Clarkson_csvs/N3WT/F001667_with_pipes.csv 100.0 30.0 ../results/clarkson_unique_proteins_and_matched_peptides_ratios.xlsx

# mascot csv to Tilo's format & calculate the ratio for the total and significant matched peptides between the N3 vs WT (and sort by logratio?)
require 'rubygems'
require 'axlsx'
require 'mascot_hits_csv_parser'

n3_infile = ARGV[0]
n3wt_infile = ARGV[1]
pep_expectancy_cutoff = ARGV[2].to_f
pep_score_cutoff = ARGV[3].to_f
tilos_list_ofile = ARGV[4]

# initialize arguments
n3_mascot_csvp = MascotHitsCSVParser.open(n3_infile, pep_expectancy_cutoff, pep_score_cutoff)
n3wt_mascot_csvp = MascotHitsCSVParser.open(n3wt_infile, pep_expectancy_cutoff, pep_score_cutoff)
tilos_list = Axlsx::Package.new
wb = tilos_list.workbook
# add some styles to the worksheet		
header = wb.styles.add_style :b => true, :alignment => { :horizontal => :left }
alignment = wb.styles.add_style :alignment => { :horizontal => :left }

# get the unique proteins of N3 (get the highest scored protein that has pep_score >= 30)
n3_unique_proteins = {}
n3_mascot_csvp.each_protein do |protein|
	highest_scored_hit_per_protein = n3_mascot_csvp.highest_from_cutoff_scored_hit_for_prot(protein)
	if !highest_scored_hit_per_protein.nil?
		n3_unique_proteins[protein] = highest_scored_hit_per_protein
	end
end

# create sheet1 - proteins list
wb.add_worksheet(:name => "Unique Proteins for N3") do |sheet|
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>header
	n3_unique_proteins.each do |protein, hit|
		prot_hit_num = hit.prot_hit_num.to_i
		prot_acc = hit.prot_acc.to_s
		uniprot_link = "http://www.uniprot.org/uniprot/#{prot_acc}"
		prot_desc = hit.prot_desc.to_s
		if prot_desc.include? "GN="
			genename = prot_desc.split("GN=")[1].split(" ")[0].to_s
		else
			genename = 'NA'
		end
		prot_score = hit.prot_score.to_f
		prot_mass = hit.prot_mass.to_i
		prot_matches_sig = hit.prot_matches_sig.to_f
		prot_matches = hit.prot_matches.to_i

		row = sheet.add_row [prot_hit_num, prot_acc, uniprot_link, genename, prot_desc, prot_score, prot_mass, prot_matches_sig, prot_matches], :style=>alignment
		sheet.add_hyperlink :location => uniprot_link, :ref => "C#{row.index + 1}"
		sheet["C#{row.index + 1}"].color = "0000FF"
	end
end

# get the unique proteins of N3WT (get the highest scored protein that has pep_score >= 30)
n3wt_unique_proteins = {}
n3wt_mascot_csvp.each_protein do |protein|
	highest_scored_hit_per_protein = n3wt_mascot_csvp.highest_from_cutoff_scored_hit_for_prot(protein)
	if !highest_scored_hit_per_protein.nil?
		n3wt_unique_proteins[protein] = highest_scored_hit_per_protein
	end
end

# create sheet2 - proteins list
wb.add_worksheet(:name => "Unique Proteins for N3WT") do |sheet|
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>header
	n3wt_unique_proteins.each do |protein, hit|
		prot_hit_num = hit.prot_hit_num.to_i
		prot_acc = hit.prot_acc.to_s
		uniprot_link = "http://www.uniprot.org/uniprot/#{prot_acc}"
		prot_desc = hit.prot_desc.to_s
		if prot_desc.include? "GN="
			genename = prot_desc.split("GN=")[1].split(" ")[0].to_s
		else
			genename = 'NA'
		end
		prot_score = hit.prot_score.to_f
		prot_mass = hit.prot_mass.to_i
		prot_matches_sig = hit.prot_matches_sig.to_f
		prot_matches = hit.prot_matches.to_i

		row = sheet.add_row [prot_hit_num, prot_acc, uniprot_link, genename, prot_desc, prot_score, prot_mass, prot_matches_sig, prot_matches], :style=>alignment
		sheet.add_hyperlink :location => uniprot_link, :ref => "C#{row.index + 1}"
		sheet["C#{row.index + 1}"].color = "0000FF"
	end
end


# get the common proteins between the samples
common_proteins = Hash.new { |h,k| h[k] = [] }
n3wt_unique_proteins.each do |protein, hit|
	if n3_unique_proteins[protein]
		common_proteins[protein] = [n3_unique_proteins[protein], n3wt_unique_proteins[protein]]
	end
end

# create sheet3 - ratios
wb.add_worksheet(:name => "N3-N3WT differential expression") do |sheet|
	sheet.add_row ["PROT_ACC", "UNIPROT_LINK", "PROT_MATCH_SIG N3WT:N3", "PROT_MATCH N3WT:N3", "LOG(PROT_MATCH_SIG N3WT:N3)", "LOG(PROT_MATCH N3WT:N3)"], :style=>header
	common_proteins.each do |protein, hits|
		uniprot_link = "http://www.uniprot.org/uniprot/#{protein}"
		n3_prot_matches_sig = hits[0].prot_matches_sig.to_f
		n3wt_prot_matches_sig = hits[1].prot_matches_sig.to_f
		n3_prot_matches = hits[0].prot_matches.to_f
		n3wt_prot_matches = hits[1].prot_matches.to_f
		ratio_sig = (n3wt_prot_matches_sig/n3_prot_matches_sig).to_f
		logratio_sig = Math::log(ratio_sig)
		ratio_total = (n3wt_prot_matches/n3_prot_matches).to_f
		logratio_total = Math::log(ratio_total)
		puts "#{n3wt_prot_matches_sig} : #{n3_prot_matches_sig} = #{ratio_sig} => #{logratio_sig}"

		row = sheet.add_row [protein, uniprot_link, n3wt_prot_matches_sig.to_s+":"+n3_prot_matches_sig.to_s, n3wt_prot_matches.to_s+":"+n3_prot_matches.to_s, logratio_sig, logratio_total], :style=>alignment
		sheet.add_hyperlink :location => uniprot_link, :ref => "B#{row.index + 1}"
		sheet["B#{row.index + 1}"].color = "0000FF"
	end
end


# write an xlsx file
tilos_list.serialize(tilos_list_ofile)


