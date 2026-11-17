# Boundary for the next G11 task

G12 ends at the raw byte `SMS.ram_dout` / `system.rom_do`, paired with the
restored CPU address and M1. It does not end at the CPU's selected decrypted
input. The future G11 oracle should begin at this raw interface, before any
decryption result/history can obscure an upstream fetch error.

The mandatory final full-flush witness records the first restored request as
CPU003F / physical04003F. Acceptance is cycle3578156; registered return is
3578162; consuming T2 is3578167, raw byte23. MCycle=1/TState=2 and M1_n=0
identify the opcode fetch. Its predecessor live word0032/address04003C was
last returned at2543457, before the LOAD freeze2543460. The new read replaces
that word before observation. See `final_protocol/s1_c0_d8_f0/simulation.log`.

Current production bindings in `rtl/system.vhd` are:

| Decrypt input | Production source / future oracle field |
|---|---|
| MC8123 `prog_d` | `rom_do` raw byte;23 for this raw witness |
| MC8123 `a` | CPU `A`,003F at this fetch |
| MC8123 `m1` | `not M1_n`,1 for opcode |
| MC8123 `clk`, `key_d` | `clk_sys`, immutable selected key byte; record clock/input ordering and key address/data in the future task |
| SEGASYS1_DECT2 `rdt` | The same `rom_do` raw byte |
| SEGASYS1_DECT2 `mrom_ad`, `mrom_m1` | `A(14 downto 0)`, `not M1_n` |
| SEGASYS1_DECT2 table interface | `ROMCL`, `ROMAD`, `ROMDT`, `ROMEN`; retain immutable table/session configuration |

The G12 fixtures use the bypass ROM path; they do not instantiate or validate
either decrypt pipeline. Equality of the raw byte and the named decrypt input
is established by direct production wiring, not by a new encrypted simulation.
The future G11 run should log those inputs every host edge through private T1,
optional historical T2, phase commitment and first native fetch, then separately
observe its registered result/madr/phase history. No G11 internal-state
sufficiency, encrypted opcode, key correctness or decryption fix is claimed here.
