# Ranked non-controller exclusive hierarchy allocations

All 455 fitted rows are retained in hierarchy.json. This table lists the top 40 outside the entire controller subtree. Own memory is derived by subtracting direct child inclusive counts; memory columns here are exclusive. Routing ALUT allocation is unavailable per entity.

|Rank|Path|Placed|Needed|Logic ALUT|FF|M10K|Memory bits|Fit line|
|---|---|---:|---:|---:|---:|---:|---:|---:|
|1|\|sys_top\|ascal:ascal|2391.8|2021.9|3059|4059|0|0|9189|
|2|\|sys_top\|emu:emu\|system:system\|vdp:vdp_inst\|vdp_main:vdp_main_inst\|vdp_sprites:vdp_spr_inst|2081.5|2077.6|2305|2910|0|0|9483|
|3|\|sys_top\|emu:emu\|system:system\|vdp:vdp2_inst\|vdp_main:vdp_main_inst\|vdp_sprites:vdp_spr_inst|2063|2075.1|2311|2909|0|0|9400|
|4|\|sys_top|995|874.9|1400|1432|0|0|9179|
|5|\|sys_top\|emu:emu\|hps_io:hps_io|683|635|770|746|0|0|9252|
|6|\|sys_top\|emu:emu|590.7|547.4|1002|659|0|0|9240|
|7|\|sys_top\|emu:emu\|system:system\|T80s:z80_inst\|T80:u0|560.5|554.8|889|262|0|0|9306|
|8|\|sys_top\|osd:hdmi_osd|558.6|543.4|906|618|0|0|9576|
|9|\|sys_top\|pll_hdmi_adj:pll_hdmi_adj|551.3|536.1|778|503|0|0|9604|
|10|\|sys_top\|emu:emu\|system:system\|CODES:GAMEGENIE|539.9|349.3|530|1104|0|0|9296|
|11|\|sys_top\|osd:vga_osd|507.4|502.9|886|608|0|0|9579|
|12|\|sys_top\|emu:emu\|pll_cfg:pll_cfg\|altera_pll_reconfig_top:pll_cfg_inst\|altera_pll_reconfig_core:NM28_reconfig.reconfig_core.altera_pll_reconfig_core_inst0|495.7|492.2|766|255|0|0|9264|
|13|\|sys_top\|emu:emu\|system:system\|vdp:vdp2_inst\|vdp_cram:vdp_cram_inst|366.8|365.5|607|404|0|0|9389|
|14|\|sys_top\|emu:emu\|system:system\|vdp:vdp_inst\|vdp_cram:vdp_cram_inst|364.3|363.9|607|399|0|0|9472|
|15|\|sys_top\|emu:emu\|system:system|360.3|367.2|582|31|0|0|9294|
|16|\|sys_top\|emu:emu\|system:system\|opll:fm\|envelopegenerator:eg|323.9|325.2|524|236|0|0|9363|
|17|\|sys_top\|emu:emu\|hps_io:hps_io\|video_calc:video_calc|319|287.8|474|649|0|0|9253|
|18|\|sys_top\|emu:emu\|system:system\|io:io_inst|307.4|313.3|544|187|0|0|9314|
|19|\|sys_top\|alsa:alsa|302.3|256.7|400|550|0|0|9180|
|20|\|sys_top\|emu:emu\|system:system\|T80s:z80_inst\|T80:u0\|T80_MCode:mcode|297.3|297.3|474|0|0|0|9308|
|21|\|sys_top\|emu:emu\|video_mixer:video_mixer\|scandoubler:sd\|Hq2x:Hq2x|282.5|207.8|177|631|0|0|9559|
|22|\|sys_top\|yc_out:yc_out|256.4|239.3|464|287|0|0|9629|
|23|\|sys_top\|emu:emu\|video_mixer:video_mixer\|scandoubler:sd\|Hq2x:Hq2x\|Blend:blender|254|237.2|360|348|0|0|9560|
|24|\|sys_top\|emu:emu\|system:system\|mapper_detect:mapper_detect_inst|237.4|235.4|443|221|0|0|9336|
|25|\|sys_top\|emu:emu\|system:system\|mapper_ctrl:mapper_banking|229.4|221.2|362|111|0|0|9335|
|26|\|sys_top\|emu:emu\|system:system\|opll:fm\|controller:ct|225.6|223.1|337|203|0|0|9355|
|27|\|sys_top\|emu:emu\|system:system\|vdp:vdp_inst\|vdp_main:vdp_main_inst\|vdp_background:vdp_bg_inst|224.7|221.2|318|187|0|0|9474|
|28|\|sys_top\|emu:emu\|system:system\|vdp:vdp2_inst\|vdp_main:vdp_main_inst\|vdp_background:vdp_bg_inst|222.5|226.9|334|200|0|0|9391|
|29|\|sys_top\|emu:emu\|system:system\|opll:fm\|PhaseGenerator:pg\|PhaseMemory:MEM|203.6|162.8|181|350|0|0|9349|
|30|\|sys_top\|emu:emu\|system:system\|vdp:vdp_inst|187.7|190.2|292|188|0|0|9465|
|31|\|sys_top\|emu:emu\|system:system\|opll:fm\|OutputGenerator:og\|OutputMemory:Mmem|182.1|164.7|202|218|0|0|9347|
|32|\|sys_top\|emu:emu\|system:system\|vdp:vdp2_inst|178.4|177.6|273|185|0|0|9382|
|33|\|sys_top\|emu:emu\|system:system\|T80s:z80_inst\|T80:u0\|T80_Reg:Regs|177.8|159.1|260|137|0|0|9309|
|34|\|sys_top\|pll_cfg_hdmi:pll_cfg_hdmi|166.8|165.8|208|163|0|0|9585|
|35|\|sys_top\|emu:emu\|system:system\|cart_eeprom:cart_eeprom_inst\|eeprom_93c46:eeprom_inst|165.8|162.1|248|134|0|0|9311|
|36|\|sys_top\|emu:emu\|video_mixer:video_mixer\|scandoubler:sd|152.3|120.6|220|292|0|0|9558|
|37|\|sys_top\|emu:emu\|system:system\|evolution_rom_address:evolution_rom_address_inst|151.4|151.4|246|0|0|0|9313|
|38|\|sys_top\|shadowmask:HDMI_shadowmask|150.4|131.8|249|251|0|0|9606|
|39|\|sys_top\|vga_out:vga_scaler_out|142.3|135.2|285|207|0|0|9624|
|40|\|sys_top\|emu:emu\|system:system\|opll:fm\|controller:ct\|RegisterMemory:u_register_memory|137.3|112.4|131|227|0|0|9356|
