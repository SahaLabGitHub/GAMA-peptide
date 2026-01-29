GAMA-peptide

This repository contains all required input files for peptide systems, along with Perl-based peptide fragmentation codes, demonstrated using two representative peptide systems. The Gly₁₂ peptide is used here solely as an illustrative example.

Overview

The fragmentation procedure is illustrated using the Gly₁₂ peptide system. The same workflow can be applied to other peptide systems with minimal modification. Users only need to identify the appropriate unbreakable groups for the target peptide, which can be done using GaussView 6 to parse atom indices. The code is integrated with GaussView, allowing seamless recognition of atom numbering.

In the current implementation, fragmentation is performed by breaking the C–C bond between the α-carbon and the carbonyl carbon along the peptide backbone.

Running the Fragmentation Code
1. Install Required Perl Modules

Before running the scripts, ensure that all required Perl modules are installed on your system, as the entire workflow is implemented in Perl.

2. Generate Fragment Input Files

Run the fragmentation script, for example:

perl script_GAMA_peptide_Gly12.pl Gly_12_gama.com


Here, Gly_12_gama.com is the GAMA fragmentation input file containing the fragmentation parameters (box size and cutoff radius) for the Gly₁₂ peptide. In this example, box size B = 2 Å and cutoff radius R = 5 Å are used.

After execution, an output file named Gly_12_gama_B2_R5.log is generated, which contains detailed fragmentation information. For the Gly₁₂ system, the code produces 94 fragment input files, named gama_high_1.gjf through gama_high_94.gjf.

Adding Link Hydrogen Atoms

Before adding link hydrogen atoms, the coordinates of the link-H atom pairs must be determined for each broken C–C bond. This is achieved using the script:

perl script_cal_Hlink_poss.pl <peptide_name>_only_coordinates.com


Here, <peptide_name>_only_coordinates.com should be replaced with a file containing the Cartesian coordinates of all atoms of the target peptide system, where <peptide_name> corresponds to the original name of the peptide (for example, Gly_12_only_coordinates.com).

This script uses a distance threshold of approximately 1.55 Å, as peptide C–C bond lengths typically lie in the range 1.52–1.55 Å. The detailed geometric formulation is provided within the script.

The output of this script includes:

The total number of broken C–C bonds in the peptide

The coordinates of the link-H atom pairs for each broken bond

These data are then used to prepare the link-hydrogen addition script (e.g., script_add_link_H_Gly12.pl).

After fragment generation, add link hydrogen atoms and generate capped fragments by running:

perl script_add_link_H_Gly12.pl

Obtaining Total Fragment Energies

After generating the capped fragment input files, perform quantum chemical calculations using the provided HPC submission script (g16_array.sbatch). This produces fragment output files (gama_high_1.log to gama_high_94.log).

The total energy is obtained by multiplying each fragment energy by its corresponding coefficient and summing over all fragments.Generalization to Other Peptides , information of coefficients can be obtained from Gly12_gama_B2_R5.log 

While Gly₁₂ is used as a representative example, the entire workflow remains identical for other peptide systems. Only system-specific quantities—such as the number of fragments, number of broken C–C bonds, and link-H atom pair coordinates—will change. The core algorithm, fragmentation strategy, and energy accumulation procedure remain unchanged.

Software Requirements

Quantum chemical calculations: Gaussian 16

Visualization and atom indexing: GaussView 6
