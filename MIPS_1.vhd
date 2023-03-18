----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2022 06:48:27 PM
-- Design Name: 
-- Module Name: MIPS_1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MIPS_1 is
    Port ( clk : in STD_LOGIC;
           btn_reset : in std_logic;
           btn_en : in std_logic;
           sw : in std_logic_vector(2 downto 0);
           led : out std_logic_vector(15 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0));
end MIPS_1;

architecture Behavioral of MIPS_1 is

component MC is
    Port ( instr : in STD_LOGIC_VECTOR (2 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR (1 downto 0);
           MemWrite : out STD_LOGIC;
           MemToReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end component;

component InstrFetch is
    Port ( --pc_in : in STD_LOGIC_VECTOR(15 downto 0);
           btn_reset : in std_logic;
           btn_en : in std_logic;
           clk : in STD_LOGIC;
           jump : in STD_LOGIC;
           PCsrc : in STD_LOGIC;
           jump_addr : in STD_LOGIC_VECTOR (15 downto 0);
           branch_addr : in STD_LOGIC_VECTOR (15 downto 0);
           instr : out STD_LOGIC_VECTOR (15 downto 0);
           --cat : out STD_LOGIC_VECTOR (6 downto 0);
           --an : out STD_LOGIC_VECTOR (3 downto 0);
           pc_next : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component IntrDecode is
    Port ( clk : in STD_LOGIC;
           btn_en : in std_logic;
           RegWr : in STD_LOGIC;
           instr : in STD_LOGIC_VECTOR (15 downto 0);
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           wd : in STD_LOGIC_VECTOR (15 downto 0);
           rd1 : out STD_LOGIC_VECTOR (15 downto 0);
           rd2 : out STD_LOGIC_VECTOR (15 downto 0);
           ext_imm : out STD_LOGIC_VECTOR (15 downto 0);
           func : out STD_LOGIC_VECTOR (2 downto 0);
           sa : out STD_LOGIC);
end component;

component ALU_MIPS is
    Port ( rd1 : in STD_LOGIC_VECTOR (15 downto 0);
           rd2 : in STD_LOGIC_VECTOR (15 downto 0);
           ext_imm : in STD_LOGIC_VECTOR (15 downto 0);
           sa : in STD_LOGIC;
           func : in STD_LOGIC_VECTOR (2 downto 0);
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR (1 downto 0);
           zero : out STD_LOGIC;
           ALURes : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component MEM is
    Port ( MemWrite : in STD_LOGIC;
           btn_en : in std_logic;
           ALURes : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           MemData : out STD_LOGIC_VECTOR (15 downto 0);
           ALURes_out : out STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC);
end component;

component Afisare_7SD is
    Port ( cat : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           digit0 : in STD_LOGIC_VECTOR (3 downto 0);
           digit1 : in STD_LOGIC_VECTOR (3 downto 0);
           digit2 : in STD_LOGIC_VECTOR (3 downto 0);
           digit3 : in STD_LOGIC_VECTOR (3 downto 0);
           clk : in std_logic);
end component;

component MPG is
    Port ( input : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : out STD_LOGIC);
end component;

signal pc : std_logic_vector(15 downto 0) := x"0000";
signal instr : std_logic_vector(15 downto 0);
signal RegDst : STD_LOGIC;
signal ExtOp : STD_LOGIC;
signal ALUSrc : STD_LOGIC;
signal Branch : STD_LOGIC;
signal Jump : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR (1 downto 0);
signal MemWrite : STD_LOGIC;
signal MemToReg : STD_LOGIC;
signal RegWrite : STD_LOGIC;
signal jumpAdress: std_logic_vector(15 downto 0);
signal branchAdress: std_logic_vector(15 downto 0);
signal ext_imm : std_logic_vector(15 downto 0);
signal PCSrc : std_logic;
signal zero: std_logic;
signal wd : STD_LOGIC_VECTOR (15 downto 0);--trebuie so implementez
signal rd1 : STD_LOGIC_VECTOR (15 downto 0);
signal rd2 : STD_LOGIC_VECTOR (15 downto 0);
signal func : STD_LOGIC_VECTOR (2 downto 0);
signal sa : STD_LOGIC;
signal ALURes : std_logic_vector(15 downto 0);
signal MemData : std_logic_vector(15 downto 0);
signal ALURes_out : std_logic_vector(15 downto 0);
signal afisare : std_logic_vector(15 downto 0);
signal btn_reset_mpg : std_logic;
signal btn_en_mpg : std_logic;

begin

MPG1: MPG port map(btn_reset, clk, btn_reset_mpg);
MPG2: MPG port map(btn_en, clk, btn_en_mpg);

jumpAdress <= "000" & instr(12 downto 0);
branchAdress <= pc + ext_imm;
PCSrc <= Branch and zero;

IntrF: InstrFetch port map(btn_reset_mpg, btn_en_mpg, clk, Jump, PCSrc,jumpAdress,branchAdress,instr,pc);

InstrDec: IntrDecode port map(clk, btn_en_mpg, RegWrite, instr, RegDst, ExtOp, wd, rd1, rd2, ext_imm, func, sa);

MainCtrl: MC port map(instr(15 downto 13), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemToReg, RegWrite);

ALU: ALU_MIPS port map(rd1, rd2, ext_imm, sa, func, ALUSrc, ALUOp, zero, ALURes);

Memory: MEM port map(MemWrite, btn_en_mpg, ALURes, rd2, MemData, ALURes_out, clk);

process(MemToReg)
begin
    if (MemToReg = '1') then
        wd <= MemData;
    else
        wd <= ALURes_out;
    end if;
end process;

process(sw)
begin
    case sw is
        when "000" => afisare <= instr;
        when "001" => afisare <= pc;
        when "010" => afisare <= rd1;
        when "011" => afisare <= rd2;
        when "100" => afisare <= ext_imm;
        when "101" => afisare <= ALURes;
        when "110" => afisare <= MemData;
        when "111" => afisare <= wd;
    end case; 
end process;

led(0) <= RegDst;
led(1) <= ExtOp;
led(2) <= ALUSrc;
led(3) <= Branch;
led(4) <= Jump;
led(6 downto 5) <= ALUOp;
led(7) <= MemWrite;
led(8) <= MemToReg;
led(9) <= RegWrite;
led(15 downto 10) <= "000000";

SSD: Afisare_7SD port map (cat, an, afisare(3 downto 0), afisare(7 downto 4), afisare(11 downto 8), afisare(15 downto 12), clk); 

end Behavioral;
