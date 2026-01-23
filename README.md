GAMA-peptide

This repository contains all required input files for peptide systems, along with the peptide fragmentation codes, demonstrated using two representative peptide systems.

Overview

The fragmentation procedure is illustrated using the Gly12 peptide system as an example. The same workflow can be applied to other peptide systems with minimal modification. Users only need to identify the appropriate unbreakable groups for the target system. In the current implementation, fragmentation is performed by breaking the C–C bond between the α-carbon and the carbonyl carbon of the peptide backbone.

Running the Fragmentation Code

Install required Perl modules
Before running the scripts, ensure that all necessary Perl modules are installed on your system.

Generate fragment input files
Run the fragmentation script, for example:

script_GAMA_peptide_Gly12.pl


This script generates the fragment input files for the Gly12 peptide.

Add link hydrogen atoms
After generating the fragment input files, use the following script to add hydrogen link atoms at the appropriate positions and generate capped fragments:

script_add_link_H_Gly12.pl

Software Requirements

For quantum chemical calculations: Gaussian 16

For visualization: GaussView 6
