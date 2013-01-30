# USAGE:
# ruby matched_peptides_ratio.rb ../data/Clarkson_csvs/N3/F001662_with_pipes.csv ../data/Clarkson_csvs/N3WT/F001667_with_pipes.csv 100.0 0.0 ../results/ExpKW01_N3_unique_proteins.xlsx ../results/ExpKW01_WT_unique_proteins.xlsx ../results/ExpKW01_unique_proteins_and_differential_expression.xlsx

# mascot csv to Tilo's format & calculate the ratio for the total and significant matched peptides between the N3 vs WT (and sort by logratio?)
require 'rubygems'
require 'axlsx'
require 'mascot_hits_csv_parser'

n3_infile = ARGV[0]
wt_infile = ARGV[1]
pep_expectancy_cutoff = ARGV[2].to_f
pep_score_cutoff = ARGV[3].to_f
n3_unique_proteins_ofile = ARGV[4]
wt_unique_proteins_ofile = ARGV[5]
tilos_list_ofile = ARGV[6]

#######################################
# initialize arguments
#######################################

n3_mascot_csvp = MascotHitsCSVParser.open(n3_infile, pep_expectancy_cutoff, pep_score_cutoff)
wt_mascot_csvp = MascotHitsCSVParser.open(wt_infile, pep_expectancy_cutoff, pep_score_cutoff)

################################################
# make the lists for uniques and common proteins
################################################

# get the unique proteins of N3 (get the highest scored protein that has pep_score >= pep_score_cutoff)
n3_unique_proteins = {}
n3_mascot_csvp.each_protein do |protein|
	highest_scored_hit_per_protein = n3_mascot_csvp.highest_from_cutoff_scored_hit_for_prot(protein)
	if !highest_scored_hit_per_protein.nil?
		n3_unique_proteins[protein] = highest_scored_hit_per_protein
	end
end

puts "N3 proteins identified"

# get the unique proteins of WT (get the highest scored protein that has pep_score >= pep_score_cutoff)
wt_unique_proteins = {}
wt_mascot_csvp.each_protein do |protein|
	highest_scored_hit_per_protein = wt_mascot_csvp.highest_from_cutoff_scored_hit_for_prot(protein)
	if !highest_scored_hit_per_protein.nil?
		wt_unique_proteins[protein] = highest_scored_hit_per_protein
	end
end

puts "WT proteins identified"

# get the common proteins between the experiments N3 and WT
common_proteins = Hash.new { |h,k| h[k] = [] }
wt_unique_proteins.each do |protein, hit|
	if n3_unique_proteins.include?(protein)
		common_proteins[protein] = [n3_unique_proteins[protein], wt_unique_proteins[protein]]
	end
end

puts "Common proteins identified"

#######################################
# TABLE1: all proteins identified in N3
#######################################

# output
n3_unique_proteins_xlsx = Axlsx::Package.new
n3_unique_proteins_wb = n3_unique_proteins_xlsx.workbook
# add some styles to the worksheet		
n3_header = n3_unique_proteins_wb.styles.add_style :b => true, :alignment => { :horizontal => :left }
n3_alignment = n3_unique_proteins_wb.styles.add_style :alignment => { :horizontal => :left }

# create sheet1 - proteins list
n3_unique_proteins_wb.add_worksheet(:name => "N3 Unique Proteins") do |sheet|
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>n3_header
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

		row = sheet.add_row [prot_hit_num, prot_acc, uniprot_link, genename, prot_desc, prot_score, prot_mass, prot_matches_sig, prot_matches], :style=>n3_alignment
		sheet.add_hyperlink :location => uniprot_link, :ref => "C#{row.index + 1}"
		sheet["C#{row.index + 1}"].color = "0000FF"
	end
end

# write xlsx file
n3_unique_proteins_xlsx.serialize(n3_unique_proteins_ofile)

puts "TABLE1 ready"

#######################################
# TABLE2: all proteins identified in WT
#######################################

# output
wt_unique_proteins_xlsx = Axlsx::Package.new
wt_unique_proteins_wb = wt_unique_proteins_xlsx.workbook
# add some styles to the worksheet		
wt_header = wt_unique_proteins_wb.styles.add_style :b => true, :alignment => { :horizontal => :left }
wt_alignment = wt_unique_proteins_wb.styles.add_style :alignment => { :horizontal => :left }

# create sheet2 - proteins list
wt_unique_proteins_wb.add_worksheet(:name => "WT Unique Proteins") do |sheet|
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>wt_header
	wt_unique_proteins.each do |protein, hit|
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

		row = sheet.add_row [prot_hit_num, prot_acc, uniprot_link, genename, prot_desc, prot_score, prot_mass, prot_matches_sig, prot_matches], :style=>wt_alignment
		sheet.add_hyperlink :location => uniprot_link, :ref => "C#{row.index + 1}"
		sheet["C#{row.index + 1}"].color = "0000FF"
	end
end

# write xlsx file
wt_unique_proteins_xlsx.serialize(wt_unique_proteins_ofile)

puts "TABLE2 ready"

#####################################################
# TABLE3: all proteins identified in N3 but not in WT 
# && all proteins identified in WT but not in N3 
# && differential expression log ratios
#####################################################

# output
tilos_list_xlsx = Axlsx::Package.new
tilos_list_wb = tilos_list_xlsx.workbook
# add some styles to the worksheet		
header = tilos_list_wb.styles.add_style :b => true, :alignment => { :horizontal => :left }
alignment = tilos_list_wb.styles.add_style :alignment => { :horizontal => :left }

# create sheet1 - all proteins identified in N3 but not in WT
tilos_list_wb.add_worksheet(:name => "N3-only Unique Proteins") do |sheet|
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>header
	n3_unique_proteins.each do |protein, hit|
		if !common_proteins.include?(protein)
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
end

# create sheet2 - all proteins identified in WT but not in N3
tilos_list_wb.add_worksheet(:name => "WT-only Unique Proteins") do |sheet|
	sheet.add_row ["PROT_HIT_NUM", "PROT_ACC", "UNIPROT_LINK", "GENENAME", "PROT_DESC", "PROT_SCORE", "PROT_MASS", "PROT_MATCH_SIG", "PROT_MATCH"], :style=>header
	wt_unique_proteins.each do |protein, hit|
		if !common_proteins.include?(protein)
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
end

# create sheet3 - ratios
tilos_list_wb.add_worksheet(:name => "N3-WT differential expression") do |sheet|
	sheet.add_row ["PROT_ACC", "UNIPROT_LINK", "PROT_DESC", "N3 PROT_HIT_NUM", "WT PROT_HIT_NUM", "N3 PROT_SCORE", "WT PROT_SCORE", "N3 PROT_MATCH_SIG", "WT PROT_MATCH_SIG", "PROT_MATCH_SIG WT:N3", "LOG(PROT_MATCH_SIG WT:N3)", "N3 PROT_MATCH", "WT PROT_MATCH", "PROT_MATCH WT:N3", "LOG(PROT_MATCH WT:N3)"], :style=>header
	common_proteins.each do |protein, hits|
		uniprot_link = "http://www.uniprot.org/uniprot/#{protein}"
		prot_desc = hits[0].prot_desc.to_s
		n3_prot_hit_num = hits[0].prot_hit_num.to_i
		wt_prot_hit_num = hits[1].prot_hit_num.to_i
		n3_prot_score = hits[0].prot_score.to_f
		wt_prot_score = hits[1].prot_score.to_f
		n3_prot_matches_sig = hits[0].prot_matches_sig.to_f
		wt_prot_matches_sig = hits[1].prot_matches_sig.to_f
		if wt_prot_matches_sig != 0.0 && n3_prot_matches_sig != 0.0
			ratio_sig = (wt_prot_matches_sig/n3_prot_matches_sig).to_f
			logratio_sig = Math::log(ratio_sig)
		else
			logratio_sig = ""
		end
		n3_prot_matches = hits[0].prot_matches.to_f
		wt_prot_matches = hits[1].prot_matches.to_f
		if wt_prot_matches != 0.0 && n3_prot_matches != 0.0 # there is no need for this check
			ratio_total = (wt_prot_matches/n3_prot_matches).to_f
			logratio_total = Math::log(ratio_total)
		else
			logratio_total = ""
		end

		row = sheet.add_row [protein, uniprot_link, prot_desc, n3_prot_hit_num, wt_prot_hit_num, n3_prot_score, wt_prot_score, n3_prot_matches_sig, wt_prot_matches_sig, wt_prot_matches_sig.to_s+":"+n3_prot_matches_sig.to_s, logratio_sig, n3_prot_matches, wt_prot_matches, wt_prot_matches.to_s+":"+n3_prot_matches.to_s, logratio_total], :style=>alignment
		sheet.add_hyperlink :location => uniprot_link, :ref => "B#{row.index + 1}"
		sheet["B#{row.index + 1}"].color = "0000FF"
	end
end

# write xlsx file
tilos_list_xlsx.serialize(tilos_list_ofile)

puts "TABLE3 ready"

