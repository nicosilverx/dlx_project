library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port(Opcode : in std_logic_vector(0 to 5);
         Func   : in std_logic_vector(0 to 10);
         CLK, RST : in std_logic;
         D_EN_WRITE, D_EN_READ1, D_EN_READ2, D_SEL_IMM_MUX, D_SEL_RD_MUX : out std_logic;
         E_SEL_OP1_MUX : out std_logic;
         E_SEL_OP2_MUX : out std_logic_vector(0 to 1);
         E_ALU_FUNC : out std_logic_vector(0 to 3);
         E_EN_WRITE_NOW : out std_logic;
         M_EN_READ, M_EN_WRITE, M_IS_LINK : out std_logic;
         W_SEL_WB_MUX : out std_logic;
         jump_taken_n : out std_logic;
         flush : out std_logic;
         stall_in : in std_logic);
end control_unit;

architecture rtl of control_unit is
--Component
component register_generic is
    Generic (NBIT : integer := 32;
             EDGE : std_logic := '1';
             RESET_VALUE : std_logic := '0');
    Port (D: in std_logic_vector(0 to NBIT-1);
          Q: out std_logic_vector(0 to NBIT-1);
          CLK, RST, EN : in std_logic);
end component;

signal control_word : std_logic_vector(0 to 15) := (OTHERS=>'0');
signal cw_reg1_out : std_logic_vector(0 to 15) := (OTHERS=>'0');
signal cw_reg2_out : std_logic_vector(0 to 11) := (OTHERS=>'0');
signal cw_reg3_out : std_logic_vector(0 to 4) := (OTHERS=>'0');
signal cw_reg4_out : std_logic_vector(0 to 1) := (OTHERS=>'0');

--Branch conditions/Jumps
signal jump, jump_reg1_out, jump_reg2_out, jump_reg3_out, internal_reset : std_logic := '1';

begin

cw_reg1 : register_generic Generic Map (NBIT=> 16) Port Map (D=> control_word, Q=>cw_reg1_out, CLK=> CLK, RST=> internal_reset, EN=> stall_in);
cw_reg2: register_generic Generic Map (NBIT=> 12) Port Map (D(0)=>cw_reg1_out(0), D(1 to 11)=>cw_reg1_out(5 to 15), Q=> cw_reg2_out, CLK=> CLK, RST=> RST, EN=>'1');
cw_reg3: register_generic Generic Map (NBIT=> 5) Port Map (D(0)=>cw_reg2_out(0), D(1 to 4)=>cw_reg2_out(8 to 11), Q=>cw_reg3_out, CLK=> CLK, RST=> RST, EN=> '1');
cw_reg4: register_generic Generic Map (NBIT=> 2) Port Map (D(0)=>cw_reg3_out(0), D(1)=>cw_reg3_out(4), Q=> cw_reg4_out, CLK=> CLK, RST=> RST, EN=>'1'); 

D_EN_WRITE<=cw_reg4_out(0);
D_EN_READ1<=cw_reg1_out(1);
D_EN_READ2<=cw_reg1_out(2);
D_SEL_IMM_MUX<=cw_reg1_out(3);
D_SEL_RD_MUX<=cw_reg1_out(4);

E_SEL_OP1_MUX<=cw_reg2_out(1);
E_SEL_OP2_MUX(0)<=cw_reg2_out(2);
E_SEL_OP2_MUX(1)<=cw_reg2_out(3);
E_ALU_FUNC(0)<=cw_reg2_out(4);
E_ALU_FUNC(1)<=cw_reg2_out(5);
E_ALU_FUNC(2)<=cw_reg2_out(6);
E_ALU_FUNC(3)<=cw_reg2_out(7);
E_EN_WRITE_NOW<=cw_reg2_out(0);

M_EN_READ<=cw_reg3_out(1);
M_EN_WRITE<=cw_reg3_out(2);
M_IS_LINK<=cw_reg3_out(3);

W_SEL_WB_MUX<=cw_reg4_out(1);

--Jump
jump_reg1 : register_generic Generic Map (NBIT=> 1, RESET_VALUE=>'1') Port Map (D(0)=> jump, Q(0)=> jump_reg1_out, CLK=> CLK, RST=> RST, EN=>stall_in);
jump_reg2 : register_generic Generic Map (NBIT=> 1, RESET_VALUE=>'1') Port Map (D(0)=> jump_reg1_out, Q(0)=> jump_reg2_out, CLK=> CLK, RST=> RST, EN=>'1');
jump_reg3 : register_generic Generic Map (NBIT=> 1, RESET_VALUE=>'1') Port Map (D(0)=> jump_reg2_out, Q(0)=> jump_reg3_out, CLK=> CLK, RST=> RST, EN=>'1');


internal_reset <= RST AND NOT(NOT(jump_reg2_out AND jump_reg3_out));


flush<=NOT(jump_reg2_out AND jump_reg3_out);
jump_taken_n<=jump_reg3_out;

decode_instruction:process(Opcode, Func, CLK)
begin
    case Opcode is
        when "000000" => 
            case Func is
                when "00000000000" => control_word<="0000000011110000"; jump<='1'; --all zeros, debug
                when "00000000100" => control_word<="1110101101100000"; jump<='1';--sll --
                when "00000000110" => control_word<="1110101101110000"; jump<='1';--srl
                when "00000100000" => control_word<="1110101100000000"; jump<='1';--add
                when "00000100010" => control_word<="1110101100010000"; jump<='1';--sub
                when "00000100100" => control_word<="1110101100110000"; jump<='1';--and
                when "00000100101" => control_word<="1110101101000000"; jump<='1';--or
                when "00000100110" => control_word<="1110101101010000"; jump<='1';--xor
                when "00000101001" => control_word<="1110101111100000"; jump<='1';--sne
                when "00000101100" => control_word<="1110101111010000"; jump<='1';--sle
                when "00000101101" => control_word<="1110101111000000"; jump<='1';--sge
                when OTHERS => control_word<="0000000011110000"; jump<='1';--nop
            end case;
        when "000010" => control_word<="0001100011110000"; jump<='0';--j
        when "000011" => control_word<="1001100100000010"; jump<='0';--jal
        when "000100" => control_word<="0100010011110000"; jump<='0';--beqz x
        when "000101" => control_word<="0100010011110000"; jump<='0';--bnez x 
        when "001000" => control_word<="1100001000000000"; jump<='1';--addi x
        when "001010" => control_word<="1100001000010000"; jump<='1';--subi x
        when "001100" => control_word<="1100001000110000"; jump<='1';--andi x 
        when "001101" => control_word<="1100001001000000"; jump<='1';--ori  x
        when "001110" => control_word<="1100001001010000"; jump<='1';--xori x 
        when "010100" => control_word<="1100001001100000"; jump<='1';--slli x
        when "010101" => control_word<="0000000011110000"; jump<='1';--nop 
        when "010110" => control_word<="1100001001110000"; jump<='1';--srli x
        when "011001" => control_word<="1100001011100000"; jump<='1';--snei x
        when "011100" => control_word<="1100001011010000"; jump<='1';--slei x
        when "011101" => control_word<="1100001011000000"; jump<='1';--sgei x
        when "100011" => control_word<="1110001000001001"; jump<='1';--lw
        when "101011" => control_word<="0110001000000100"; jump<='1';--sw x
        when OTHERS=> control_word<="0000000011110000"; jump<='1';--nop
    end case;
end process decode_instruction;

end rtl;
