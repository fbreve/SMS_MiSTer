with open('tests/savestate_op_cooldown_removal/sim/cooldown_verification_tb.sv', 'r') as f:
    text = f.read()

# Separate DDRAM signals for a and b so they NEVER collide:
# Let's check how DUT a and b are instantiated and how the memory model works!
# Instead of a single memory model with shared ports, give each DUT its own dedicated memory array:
# memory_a and memory_b!
old_mem = '''    // Simulated DDRAM memory
    reg [63:0] memory [0:98303];
    reg [28:0] ra;
    integer pending = 0;
    integer cycles = 0;
    integer mismatches = 0;
    reg check_cycle_equivalence = 1;'''

new_mem = '''    // Simulated DDRAM memories (fully isolated for each DUT)
    reg [63:0] memory_a [0:98303];
    reg [63:0] memory_b [0:98303];
    reg [28:0] ra_a, ra_b;
    integer pending_a = 0;
    integer pending_b = 0;
    reg [63:0] DDRAM_DOUT_a = 0;
    reg [63:0] DDRAM_DOUT_b = 0;
    reg DDRAM_DOUT_READY_a = 0;
    reg DDRAM_DOUT_READY_b = 0;
    integer cycles = 0;
    integer mismatches = 0;
    reg check_cycle_equivalence = 1;'''

text = text.replace(old_mem, new_mem)

# Update DUT a DDRAM_DOUT connections:
text = text.replace('.DDRAM_DOUT(DDRAM_DOUT), .DDRAM_DOUT_READY(DDRAM_DOUT_READY)', '.DDRAM_DOUT(DDRAM_DOUT_a), .DDRAM_DOUT_READY(DDRAM_DOUT_READY_a)')
text = text.replace('.DDRAM_DOUT(DDRAM_DOUT), .DDRAM_DOUT_READY(DDRAM_DOUT_READY)', '.DDRAM_DOUT(DDRAM_DOUT_b), .DDRAM_DOUT_READY(DDRAM_DOUT_READY_b)')

# Replace memory process:
old_proc = '''    always @(posedge clk) begin
        DDRAM_DOUT_READY <= 0;
        if (pending > 0) begin
            pending <= pending - 1;
            if (pending == 1) begin
                DDRAM_DOUT <= memory[ra - 29'h07C00000];
                DDRAM_DOUT_READY <= 1;
            end
        end
        // Service writes from whichever module is active (during paired tests they are identical)
        if ((DDRAM_WE_a || DDRAM_WE_b) && !DDRAM_BUSY) begin
            for (integer b_idx = 0; b_idx < 8; b_idx = b_idx + 1) begin
                if (DDRAM_WE_b ? DDRAM_BE_b[b_idx] : DDRAM_BE_a[b_idx])
                    memory[(DDRAM_WE_b ? DDRAM_ADDR_b : DDRAM_ADDR_a) - 29'h07C00000][b_idx*8 +: 8] <= 
                        (DDRAM_WE_b ? DDRAM_DIN_b[b_idx*8 +: 8] : DDRAM_DIN_a[b_idx*8 +: 8]);
            end
        end
        if ((DDRAM_RD_a || DDRAM_RD_b) && !DDRAM_BUSY) begin
            ra <= DDRAM_RD_b ? DDRAM_ADDR_b : DDRAM_ADDR_a;
            pending <= 3;
        end
    end'''

new_proc = '''    always @(posedge clk) begin
        // Port A (Baseline)
        DDRAM_DOUT_READY_a <= 0;
        if (pending_a > 0) begin
            pending_a <= pending_a - 1;
            if (pending_a == 1) begin
                DDRAM_DOUT_a <= memory_a[ra_a - 29'h07C00000];
                DDRAM_DOUT_READY_a <= 1;
            end
        end
        if (DDRAM_WE_a && !DDRAM_BUSY) begin
            for (integer b_idx = 0; b_idx < 8; b_idx = b_idx + 1) begin
                if (DDRAM_BE_a[b_idx]) memory_a[DDRAM_ADDR_a - 29'h07C00000][b_idx*8 +: 8] <= DDRAM_DIN_a[b_idx*8 +: 8];
            end
        end
        if (DDRAM_RD_a && !DDRAM_BUSY) begin
            ra_a <= DDRAM_ADDR_a;
            pending_a <= 3;
        end

        // Port B (Candidate)
        DDRAM_DOUT_READY_b <= 0;
        if (pending_b > 0) begin
            pending_b <= pending_b - 1;
            if (pending_b == 1) begin
                DDRAM_DOUT_b <= memory_b[ra_b - 29'h07C00000];
                DDRAM_DOUT_READY_b <= 1;
            end
        end
        if (DDRAM_WE_b && !DDRAM_BUSY) begin
            for (integer b_idx = 0; b_idx < 8; b_idx = b_idx + 1) begin
                if (DDRAM_BE_b[b_idx]) memory_b[DDRAM_ADDR_b - 29'h07C00000][b_idx*8 +: 8] <= DDRAM_DIN_b[b_idx*8 +: 8];
            end
        end
        if (DDRAM_RD_b && !DDRAM_BUSY) begin
            ra_b <= DDRAM_ADDR_b;
            pending_b <= 3;
        end
    end'''

text = text.replace(old_proc, new_proc)

# In Test 4:
# force DDRAM_DOUT_READY_b = 0 instead of force DDRAM_DOUT_READY = 0
text = text.replace('force DDRAM_DOUT_READY = 0;', 'force DDRAM_DOUT_READY_b = 0;')
text = text.replace('release DDRAM_DOUT_READY;', 'release DDRAM_DOUT_READY_b;')

with open('tests/savestate_op_cooldown_removal/sim/cooldown_verification_tb.sv', 'w') as f:
    f.write(text)
print('Updated cooldown_verification_tb with completely isolated dual memory models.')
