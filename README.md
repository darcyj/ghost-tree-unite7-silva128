## ghost-tree-unite7-silva128
# A Ghost Tree for Fungal ITS using the most recent versions of the UNITE and SILVA databases

# Ghost-Tree (https://github.com/JTFouquier/ghost-tree.git) is neat, becuase it allows us to use fungal ITS in 
# phylogenetic analyses (which is normally impossible since it's too variable). It accomplishes
# this by making small ITS trees for clades where ITS actually can be aligned, then grafts them on to
# a backbone tree, which is the SILVA 18S tree. Unfortunately, the latest version of Ghost-Tree available
# used very old versions of the UNITE (ITS) and SILVA (18S) databases. I made a Ghost-Tree with the
# newest versions - UNITE 7 and SILVA 128. Below is the code for how I made the tree.

# install ghosttree from github. Commented lines cover requirements
  # sudo apt-get install python3-tk
  # pip install qiime --user
  git clone https://github.com/JTFouquier/ghost-tree.git
  pip3 install -e ghost-tree/ --user

# download SILVA database, move into folder
  # warning - this db is 30 GB when unzipped. No clue why they didn't make GhostTree able to read gz files.
  wget 'http://www.arb-silva.de/fileadmin/silva_databases/release_128/Exports/SILVA_128_SSURef_Nr99_tax_silva_full_align_trunc.fasta.gz'
  wget 'http://www.arb-silva.de/fileadmin/silva_databases/release_128/Exports/taxonomy/tax_slv_ssu_128.acc_taxid'
  wget 'http://www.arb-silva.de/fileadmin/silva_databases/release_128/Exports/taxonomy/tax_slv_ssu_128.txt'
  gunzip SILVA_128_SSURef_Nr99_tax_silva_full_align_trunc.fasta.gz
  mkdir silva_files
  mv SILVA_128_SSURef_Nr99_tax_silva_full_align_trunc.fasta silva_files/
  mv tax_slv* silva_files/

# download UNITE database, remove excess files
  wget https://unite.ut.ee/sh_files/sh_qiime_release_s_10.10.2017.zip
  rm sh_qiime_release_s_10.10.2017.zip
  rm -r developer
  mkdir unite_files
  mv sh_refs_qiime_ver7_97_s_10.10.2017.fasta unite_files/
  mv sh_taxonomy_qiime_ver7_97_s_10.10.2017.txt unite_files/
  rm sh_refs_qiime_ver7_*
  rm sh_taxonomy_qiime_ver7_*

# assign variables to each file
  silva_aligned="silva_files/SILVA_128_SSURef_Nr99_tax_silva_full_align_trunc.fasta"
  silva_accession="silva_files/tax_slv_ssu_128.acc_taxid" 
  silva_taxonomy="silva_files/tax_slv_ssu_128.txt" 
  silva_fungi_only="silva_fungi_only.txt"
  silva_fungi_filtered="silva_fungi_only_filtered.txt"
  ITS_seqs="unite_files/sh_refs_qiime_ver7_97_s_10.10.2017.fasta" 
  ITS_tax="unite_files/sh_taxonomy_qiime_ver7_97_s_10.10.2017.txt" 
  ITS_otu_map_80="ITS_otu_map_80.txt"

# remove all non-fungal samples from Silva alignment
  time ghost-tree silva extract-fungi $silva_aligned $silva_accession $silva_taxonomy $silva_fungi_only
  
# filter entropy and gaps from silva fungal only alignment
  time ghost-tree filter-alignment-positions $silva_fungi_only 0.9 0.8 $silva_fungi_filtered
  
# get rid of huge silva file since it won't be used again
  rm silva_files/SILVA_128_SSURef_Nr99_tax_silva_full_align_trunc.fasta 

# Group the extension sequences (UNITE @ 97%) down to 80%
  time ghost-tree extensions group-extensions $ITS_seqs 0.8 $ITS_otu_map_80

# Ghosttree calls "fasttree" instead of "FastTree". A link fixes this.
  ln -s ~/.local/bin/FastTree fasttree
  chmod +x fasttree
  export PATH=$PATH:~/Desktop/ghost-tree

# Build hybrid tree
  ghost-tree scaffold hybrid-tree $ITS_otu_map_80 $ITS_tax $ITS_seqs $silva_fungi_filtered ghost-tree-output

# make unite database containing only names that are in the ghost tree
  mkdir unite_gt_filtered
  ITS_seqs_gt="unite_gt_filtered/sh_refs_ghosttree_ver7_97_s_10.10.2017.txt"
  ITS_tax_gt="unite_gt_filtered/sh_taxonomy_ghosttree_ver7_97_s_10.10.2017.txt"
  ./filter_unite_tax_using_ghosttree.r --tree ghost-tree-output/ghost_tree.nwk --tax $ITS_tax -o $ITS_tax_gt
  filter_fasta.py -f $ITS_seqs -s $ITS_tax_gt -o $ITS_seqs_gt
