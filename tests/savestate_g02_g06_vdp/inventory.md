# Exact state sites

Generated from committed production sources. Every token site and seven-line control context is retained in inventory.json; assignments are lexical VHDL signal assignments. Ports and combinational aliases are included to avoid silently treating them as storage. Array element assignments retain their indices. Read this together with the behavioral classification in review.md.

## G02 rtl/vdp.vhd: reset_flags

Declaration: 180: signal reset_flags:		boolean ;

Assignments: 393, 441, 549, 564. All declaration/assignment/consumer sites: 180, 353, 393, 441, 549, 564, 583, 611, 666, 674.

## G03 rtl/vdp.vhd: old_RD_n

Declaration: 119: signal old_RD_n:			STD_LOGIC;

Assignments: 373, 445, 464. All declaration/assignment/consumer sites: 119, 373, 445, 464, 531.

## G03 rtl/vdp.vhd: old_WR_n

Declaration: 120: signal old_WR_n:			STD_LOGIC;

Assignments: 372, 444, 463. All declaration/assignment/consumer sites: 120, 372, 444, 462, 463, 471.

## G03 rtl/vdp.vhd: old_HL

Declaration: 121: signal old_HL:				STD_LOGIC;

Assignments: 375, 447, 453. All declaration/assignment/consumer sites: 121, 375, 447, 453, 454.

## G03 rtl/vdp.vhd: old_WR_direct

Declaration: 122: signal old_WR_direct:	STD_LOGIC;

Assignments: 374, 446, 465. All declaration/assignment/consumer sites: 122, 374, 446, 465, 467.

## G03 rtl/vdp.vhd: cpu_write_data

Declaration: 139: signal cpu_write_data:	std_logic_vector(7 downto 0) := (others => '0');

Assignments: 376, 448, 468, 473. All declaration/assignment/consumer sites: 139, 268, 312, 313, 314, 315, 376, 448, 468, 473.

## G03 rtl/vdp.vhd: data_write

Declaration: 125: signal data_write:		std_logic;

Assignments: 403, 449, 469, 474. All declaration/assignment/consumer sites: 125, 316, 317, 403, 449, 469, 474.

## G03 rtl/vdp.vhd: xram_cpu_A_incr

Declaration: 140: signal xram_cpu_A_incr:	std_logic := '0';

Assignments: 450, 475, 541, 555, 561. All declaration/assignment/consumer sites: 140, 450, 475, 541, 553, 555, 561.

## G04 rtl/vdp.vhd: xspr_collide_shift

Declaration: 184: signal xspr_collide_shift: std_logic_vector(13 downto 0) := (others=>'0'); -- collide delay

Assignments: 626, 653, 655, 657. All declaration/assignment/consumer sites: 184, 626, 653, 655, 657, 659.

## G04 rtl/vdp.vhd: IRQ_n

Declaration: 27: IRQ_n:			out STD_LOGIC;

Assignments: 631, 633, 636, 676, 681. All declaration/assignment/consumer sites: 27, 631, 633, 636, 676, 681.

## G04 rtl/vdp.vhd: last_x0

Declaration: 179: signal last_x0:			std_logic := '0';

Assignments: 594, 599. All declaration/assignment/consumer sites: 179, 581, 594, 599, 600.

## G05 rtl/vdp_background.vhd: tile_index

Declaration: 41: signal tile_index		: std_logic_vector (8 downto 0);

Assignments: 256, 290, 292, 321. All declaration/assignment/consumer sites: 41, 202, 225, 229, 234, 238, 239, 256, 290, 292, 321.

## G05 rtl/vdp_background.vhd: x

Declaration: 42: signal x				: std_logic_vector (7 downto 0);

Assignments: 86, 88, 90, 95, 104, 106, 109. All declaration/assignment/consumer sites: 42, 86, 88, 90, 95, 104, 106, 109, 201, 204, 220, 221, 288, 319, 375.

## G05 rtl/vdp_background.vhd: tile_y

Declaration: 43: signal tile_y			: std_logic_vector (2 downto 0);

Assignments: 258, 294, 295, 296. All declaration/assignment/consumer sites: 43, 202, 258, 294, 295, 296.

## G05 rtl/vdp_background.vhd: palette

Declaration: 44: signal palette			: std_logic;

Assignments: 259, 297, 329. All declaration/assignment/consumer sites: 44, 259, 297, 329, 392.

## G05 rtl/vdp_background.vhd: palette_shift

Declaration: 45: signal palette_shift	: std_logic;

Assignments: 355, 392. All declaration/assignment/consumer sites: 45, 355, 392, 409.

## G05 rtl/vdp_background.vhd: priority_latch

Declaration: 46: signal priority_latch	: std_logic;

Assignments: 260, 298, 330. All declaration/assignment/consumer sites: 46, 260, 298, 330, 393.

## G05 rtl/vdp_background.vhd: flip_x

Declaration: 47: signal flip_x			: std_logic;

Assignments: 257, 293, 328. All declaration/assignment/consumer sites: 47, 257, 293, 328, 377.

## G05 rtl/vdp_background.vhd: datac

Declaration: 54: signal datac			: std_logic_vector(7 downto 0);

Assignments: 265, 324. All declaration/assignment/consumer sites: 54, 265, 324, 332, 333, 334, 335.

## G05 rtl/vdp_background.vhd: data0

Declaration: 55: signal data0			: std_logic_vector(7 downto 0);

Assignments: 261, 300, 332. All declaration/assignment/consumer sites: 55, 261, 300, 332, 378, 387.

## G05 rtl/vdp_background.vhd: data1

Declaration: 56: signal data1			: std_logic_vector(7 downto 0);

Assignments: 262, 302, 333. All declaration/assignment/consumer sites: 56, 262, 302, 333, 379, 388.

## G05 rtl/vdp_background.vhd: data2

Declaration: 57: signal data2			: std_logic_vector(7 downto 0);

Assignments: 263, 304, 334. All declaration/assignment/consumer sites: 57, 263, 304, 334, 380, 389.

## G05 rtl/vdp_background.vhd: data3

Declaration: 58: signal data3			: std_logic_vector(7 downto 0);

Assignments: 264, 335. All declaration/assignment/consumer sites: 58, 264, 335, 384.

## G05 rtl/vdp_background.vhd: shift0

Declaration: 60: signal shift0			: std_logic_vector(7 downto 0);

Assignments: 351, 378, 387, 395. All declaration/assignment/consumer sites: 60, 351, 378, 387, 395, 405.

## G05 rtl/vdp_background.vhd: shift1

Declaration: 61: signal shift1			: std_logic_vector(7 downto 0);

Assignments: 352, 379, 388, 396. All declaration/assignment/consumer sites: 61, 352, 379, 388, 396, 406.

## G05 rtl/vdp_background.vhd: shift2

Declaration: 62: signal shift2			: std_logic_vector(7 downto 0);

Assignments: 353, 380, 389, 397. All declaration/assignment/consumer sites: 62, 353, 380, 389, 397, 407.

## G05 rtl/vdp_background.vhd: shift3

Declaration: 63: signal shift3			: std_logic_vector(7 downto 0);

Assignments: 354, 382, 384, 390, 398. All declaration/assignment/consumer sites: 63, 354, 382, 384, 390, 398, 408.

## G05 rtl/vdp_background.vhd: text_shift

Declaration: 65: signal text_shift		: std_logic_vector(5 downto 0) := (others=>'0');

Assignments: 350, 360, 364, 367, 368, 371. All declaration/assignment/consumer sites: 65, 350, 360, 364, 367, 368, 371, 405, 406, 407, 408.

## G05 rtl/vdp_background.vhd: text_tile_index

Declaration: 66: signal text_tile_index	: std_logic_vector(7 downto 0) := (others=>'0');

Assignments: 254, 269, 276. All declaration/assignment/consumer sites: 66, 166, 179, 254, 269, 276.

## G05 rtl/vdp_background.vhd: text_pattern

Declaration: 67: signal text_pattern		: std_logic_vector(7 downto 0) := (others=>'0');

Assignments: 255, 271, 280. All declaration/assignment/consumer sites: 67, 255, 271, 280, 360, 364.

## G05 rtl/vdp_background.vhd: text_phase

Declaration: 68: signal text_phase		: std_logic_vector(2 downto 0) := (others=>'0');

Assignments: 121, 125, 128, 132, 135, 138. All declaration/assignment/consumer sites: 68, 121, 125, 128, 131, 132, 135, 138, 171, 273, 363.

## G05 rtl/vdp_background.vhd: text_column

Declaration: 69: signal text_column		: std_logic_vector(5 downto 0) := (others=>'0');

Assignments: 122, 126, 129, 133, 139. All declaration/assignment/consumer sites: 69, 122, 126, 129, 133, 139, 173, 174, 178, 275, 279.

## G05 rtl/vdp_background.vhd: priority

Declaration: 35: priority:			out std_logic

Assignments: 356, 361, 365, 372, 393. All declaration/assignment/consumer sites: 35, 356, 361, 365, 372, 393.

## G05 rtl/vdp_background.vhd: vram_A

Declaration: 31: vram_A:				out std_logic_vector(13 downto 0);

Assignments: 164, 166, 175, 179, 205, 206, 207, 208, 209, 210, 221, 225, 228, 234, 237. All declaration/assignment/consumer sites: 31, 164, 166, 175, 179, 205, 206, 207, 208, 209, 210, 221, 225, 228, 234, 237.

## G06 rtl/vdp_sprites.vhd: state

Declaration: 46: signal state:		std_logic_vector(2 downto 0) := WAITING;

Assignments: 130, 147, 152, 166, 180, 182, 188, 199, 203, 207, 211, 215, 220, 228, 239, 241, 247, 257, 264, 272, 282, 289. All declaration/assignment/consumer sites: 46, 99, 130, 147, 152, 163, 166, 180, 182, 188, 199, 203, 207, 211, 215, 220, 228, 239, 241, 247, 257, 264, 272, 282, 289.

## G06 rtl/vdp_sprites.vhd: count

Declaration: 47: signal count:		integer range 0 to 64;

Assignments: 128, 145, 222, 291. All declaration/assignment/consumer sites: 47, 128, 145, 176, 179, 202, 206, 210, 214, 218, 219, 222, 238, 268, 270, 277, 278, 279, 280, 286, 288, 291.

## G06 rtl/vdp_sprites.vhd: index

Declaration: 48: signal index:		std_logic_vector(5 downto 0);

Assignments: 131, 148, 186, 221, 245, 290. All declaration/assignment/consumer sites: 48, 100, 101, 102, 103, 107, 108, 109, 131, 148, 185, 186, 221, 244, 245, 290.

## G06 rtl/vdp_sprites.vhd: data_address

Declaration: 49: signal data_address: std_logic_vector(13 downto 0);

Assignments: 172, 174, 193, 194, 197, 232, 234, 236, 253, 255, 281. All declaration/assignment/consumer sites: 49, 104, 105, 110, 111, 112, 113, 172, 174, 193, 194, 197, 232, 234, 236, 253, 255, 281.

## G06 rtl/vdp_sprites.vhd: ce_spload

Declaration: 50: signal ce_spload:	std_logic;

Assignments: 117. All declaration/assignment/consumer sites: 50, 117, 140.

## G06 rtl/vdp_sprites.vhd: m2_flags

Declaration: 51: signal m2_flags:  std_logic_vector(7 downto 0);

Assignments: 263. All declaration/assignment/consumer sites: 51, 263, 267, 280.

## G06 rtl/vdp_sprites.vhd: enable

Declaration: 56: signal enable:	tenable;

Assignments: 129, 146, 219, 288. All declaration/assignment/consumer sites: 56, 129, 146, 219, 288, 308, 313.

## G06 rtl/vdp_sprites.vhd: spr_x

Declaration: 57: signal spr_x:	tx;

Assignments: 134, 202, 268, 270. All declaration/assignment/consumer sites: 57, 76, 134, 202, 268, 270.

## G06 rtl/vdp_sprites.vhd: spr_d0

Declaration: 58: signal spr_d0:	tdata;

Assignments: 135, 206, 277. All declaration/assignment/consumer sites: 58, 88, 135, 206, 277.

## G06 rtl/vdp_sprites.vhd: spr_d1

Declaration: 59: signal spr_d1:	tdata;

Assignments: 136, 210, 278, 286. All declaration/assignment/consumer sites: 59, 89, 136, 210, 278, 286.

## G06 rtl/vdp_sprites.vhd: spr_d2

Declaration: 60: signal spr_d2:	tdata;

Assignments: 137, 214, 279. All declaration/assignment/consumer sites: 60, 90, 137, 214, 279.

## G06 rtl/vdp_sprites.vhd: spr_d3

Declaration: 61: signal spr_d3:	tdata;

Assignments: 138, 218, 280. All declaration/assignment/consumer sites: 61, 91, 138, 218, 280.

## G06 rtl/vdp_sprites.vhd: spr_color

Declaration: 64: signal spr_color:	tcolor;

Assignments: . All declaration/assignment/consumer sites: 64, 92, 308, 309, 313, 315.

## G06 rtl/vdp_sprites.vhd: spr_active

Declaration: 65: signal spr_active:	std_logic_vector(0 to MAX_SPPL);

Assignments: . All declaration/assignment/consumer sites: 65, 93, 308, 313.

## G06 rtl/vdp_sprites.vhd: color

Declaration: 30: color				: out STD_LOGIC_VECTOR (3 downto 0);

Assignments: 305, 309, 315. All declaration/assignment/consumer sites: 30, 92, 305, 309, 315.

## G06 rtl/vdp_sprites.vhd: collide

Declaration: 28: collide			: out std_logic;

Assignments: 320, 323, 325. All declaration/assignment/consumer sites: 28, 320, 323, 325.

## G06 rtl/vdp_sprites.vhd: overflow

Declaration: 29: overflow			: out std_logic;

Assignments: 132, 149, 177. All declaration/assignment/consumer sites: 29, 132, 149, 177.

## G06 rtl/vdp_sprite_shifter.vhd: wideclock

Declaration: 28: signal wideclock : boolean := false ;

Assignments: 43, 56, 69. All declaration/assignment/consumer sites: 28, 43, 56, 58, 69.

## G06 rtl/vdp_sprite_shifter.vhd: shift0

Declaration: 29: signal shift0	: std_logic_vector (7 downto 0) := (others=>'0');

Assignments: 39, 52, 59, 61, 64. All declaration/assignment/consumer sites: 29, 39, 52, 59, 61, 64, 75, 77, 78, 80, 85.

## G06 rtl/vdp_sprite_shifter.vhd: shift1

Declaration: 30: signal shift1	: std_logic_vector (7 downto 0) := (others=>'0');

Assignments: 40, 53, 66. All declaration/assignment/consumer sites: 30, 40, 53, 64, 66, 75, 77, 78.

## G06 rtl/vdp_sprite_shifter.vhd: shift2

Declaration: 31: signal shift2	: std_logic_vector (7 downto 0) := (others=>'0');

Assignments: 41, 54, 67. All declaration/assignment/consumer sites: 31, 41, 54, 63, 67, 75, 77, 78.

## G06 rtl/vdp_sprite_shifter.vhd: shift3

Declaration: 32: signal shift3	: std_logic_vector (7 downto 0) := (others=>'0');

Assignments: 42, 55, 62. All declaration/assignment/consumer sites: 32, 42, 55, 62, 63, 75, 77, 78, 81.

