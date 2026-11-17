# Read-only integration checks

Pinned optimized FM implementation checked: `8cd53ccc954c24970372ea6d8a3fb2336a14c46f`. No source in that checkout or PR227 was changed.

- Its writer clears CPU word5 bits63:38 in both DDR write paths. This supports using an explicitly owned/versioned marker there; an old writer overwriting a slot also clears the marker.
- Its private FM descriptor remains `{16'd100,8'd1,8'd1,32'h464d5331}`, with video tag484311 and zero padding39:22. The SRAM proposal must retain these fields and the optimized100-row architecture. Importing historical SRAM video tag484312 would not be the same format and is not proposed.
- FM FSM states occupy111–121; the prototype's73/74 identifiers do not collide with a73/74 declaration in this pinned source. Both fit the existing7-bit state register. A production diff must still review all identifiers in its actual target revision.
- Main RTL exposes `sc3000_en = status[58] | sc3000_auto`, `sc_cart_ram = status[60:59]`, and `eeprom_active = mapper_eeprom`. Eligibility must use the active machine mode, not dormant SC option bits alone: the intended condition is no active SC cartridge RAM and no EEPROM, with the controller also excluding SystemE. The test fixture's generic `full_sram_allowed` input represents that boundary; it is not production wiring.

The test-only marker family in CPU word5 is owner5953/version1: bit43 complete physical SRAM, bit42 predecessor-present, bits41:39 class, bit38 reserved zero. B uses only SRAM and never enables predecessor restoration. C/D exist for mechanism isolation. This is an experimental namespace; it is not an upstream allocation. The hardware FM save supplied by the user was inspected only, not loaded into the master experiments.

No FM private storage, row count, descriptor, read/write pipeline or audio architecture was modified or built. Compatibility of a future integration remains a review/validation task; these checks do not claim a tested FM production patch.
