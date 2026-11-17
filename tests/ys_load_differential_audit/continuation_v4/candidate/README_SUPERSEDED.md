This first experimental generator output is superseded by `../candidate_v2/`.

An insertion matched the combinational `ST_SAVE_DONE` case instead of the sequential case. That produced unintended state assignments in the combinational block. Its preliminary transfer result and cycle counts are not valid evidence. The failed logs and sources remain here for provenance. The generator was corrected to target the sequential framework-commit block explicitly; the corrected output compiles without that warning and passes the43-case transport matrix in candidate_v2.

The initial old-format probe also changed only the file-size header while retaining a new PSG presence marker, creating an invalid hybrid. The final old-format cases clear that marker and verify the intended legacy SRAM bypass.
