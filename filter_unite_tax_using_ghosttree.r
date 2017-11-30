#!/usr/bin/env Rscript

## Script Info: This program filters a taxonomy table (tab-delimited, irst column is an 
	# accession, second column is a tax string) to only contain entries that are present
	# in a tree (newick format, has accessions for tip names).

## set up environment
	suppressPackageStartupMessages(require(optparse))
	suppressPackageStartupMessages(require(ape))

## parse arguments
	option_list <- list(
		make_option("--tax", action="store", default=NA, type='character',
			help="Input taxonomy table, tab delimited, accessions in 1st column, no header."), 
		make_option("--tree", action="store", default=NA, type='character',
			help="Input tree, newick format, tip labels are accessions."),
		make_option(c("-o", "--output"), action="store", default=NA, type='character',
			help="Output filepath for filtered taxonomy table.")
	) 
	opt = parse_args(OptionParser(option_list=option_list))


## read in tree
	ghosttree <- read.tree(opt$tree)

## read in taxonomy table
	tax <- read.table(opt$tax, sep='\t', header=F, stringsAsFactors=F, quote="")

# subset taxonomy to only keep entries in tree
	tax_less <- tax[ tax[[1]] %in% ghosttree$tip.label, ]

# writeout
	write.table(file=opt$output, tax_less, sep='\t', row.names=F, col.names=F, quote=F)
