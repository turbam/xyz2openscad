#xyz2openscad

##Description
A GNU Guile script for generating 3D open-scad molecule
models from .xyz files.
The script will print the open-scad source file to std-out.

##Usage
`guile xyz2openscad <input-file> > <output-file>`

or

`./xyz2openscad <input-file> > <output-file>`

This scripts supports piping the xyz file into it, which
makes it easy to use with open-babel.

The following example assumes you have a file called
"molecule.smi" which contains a smiles string for a molecule.

`obabel molecule.smi -o xyz --gen3d | guile xyz2openscad.scm > molecule.scad`

or

`obabel molecule.smi -o xyz --gen3d | ./xyz2openscad.scm > molecule.scad`

converts the smiles string to an xyz-file via open-babel, pipes the
result into the GNU Guile script, which generates an open-scad script
and saves it as "molecule.scad".

For the .xyz file specifications visit
http://en.wikipedia.org/wiki/XYZ_file_format
(the script essentially ignores the first two lines of input).