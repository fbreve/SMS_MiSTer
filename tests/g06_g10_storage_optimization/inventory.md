# Complete G06/G10 field inventory

Slot stride74, i=0..63; two independent VDPs. Locations are source declarations or packed assignments; JSON records capture/restore timing and consumers for every field. Snapshot storage counts exclude live copies and physical duplication by the Fitter.

|Field|First bit (plus74i for slots)|Width|Instances|Snapshot bits|Live source|Future consumer|
|---|---:|---:|---:|---:|---|---|
|enable|0|1|128|128|enable(i)|Current-line pixel/collision qualification|
|spr_x|1|8|128|1024|spr_x(i)|Shifter reload position|
|cached plane 0|9|8|128|1024|spr_d0(i)|Future reload; mode-specific pattern/color history|
|cached plane 1|17|8|128|1024|spr_d1(i)|Future reload; mode-specific pattern/color history|
|cached plane 2|25|8|128|1024|spr_d2(i)|Future reload; mode-specific pattern/color history|
|cached plane 3|33|8|128|1024|spr_d3(i)|Future reload; mode-specific pattern/color history|
|shift plane 0|41|8|128|1024|shift0|Next pixel and subsequent shift suffix|
|shift plane 1|49|8|128|1024|shift1|Next pixel and subsequent shift suffix|
|shift plane 2|57|8|128|1024|shift2|Next pixel and subsequent shift suffix|
|shift plane 3|65|8|128|1024|shift3|Next pixel and subsequent shift suffix|
|wideclock|73|1|128|128|wideclock|Next half-rate shift decision|
|data_address|4736|14|2|28|data_address|Future partial address generation|
|m2_flags|4750|8|2|16|m2_flags|Legacy early-clock and color/cache updates|
|color_reg|4758|4|2|8|color_reg|First output before next ce_pix|
|collide_reg|4762|1|2|2|collide_reg|Collision delay input|
|overflow_reg|4763|1|2|2|overflow_reg|VDP status-source history|
|collision delay|4764|14|2|28|xspr_collide_shift|Already-launched collision/IRQ suffix|
|transport padding|4778|22|2|44|literal zero at ARM|During ring rotation these positions carry other meaningful words|

Slot subtotal64?74?2=9,472; fixed42?2=84; meaningful9,556; padding22?2=44; rings9,600. G10 adds2-bit phase and1-bit consumed-T history, separately:9,603 declared ring/history bits. This matches the scale of historical mapped-register growth, without claiming every source bit survives mapping one-to-one. See inventory.json for shared controls and reconstruction limits.
