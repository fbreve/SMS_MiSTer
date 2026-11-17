package require ::quartus::project
package require ::quartus::atoms
project_open Z:/candidate/SMS
read_atom_netlist -type cmp
puts "EXPORT"
write_atom_netlist -file Z:/fitted_atoms.v -verilog
project_close -dont_export_assignments
