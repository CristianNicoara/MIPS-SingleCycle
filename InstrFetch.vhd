----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2022 06:53:02 PM
-- Design Name: 
-- Module Name: InstrFetch - Behavioral
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

entity InstrFetch is
    Port ( btn_reset : in std_logic;
           btn_en : in std_logic;
           clk : in STD_LOGIC;
           jump : in STD_LOGIC;
           PCsrc : in STD_LOGIC;
           jump_addr : in STD_LOGIC_VECTOR (15 downto 0);
           branch_addr : in STD_LOGIC_VECTOR (15 downto 0);
           instr : out STD_LOGIC_VECTOR (15 downto 0);
           pc_next : out STD_LOGIC_VECTOR (15 downto 0));
end InstrFetch;

architecture Behavioral of InstrFetch is

signal pc_out : std_logic_vector(15 downto 0);
signal branch_out : std_logic_vector(15 downto 0);
signal jump_out : std_logic_vector(15 downto 0);

type mem_rom is array(0 to 255) of std_logic_vector(15 downto 0);
signal ad_rom : mem_rom := (
    B"001_000_010_0110010",   --0  ADDI R2,R0,50	001 000 010 0110010		    2132
    B"001_010_010_0000001",   --1  ADDI R2,R2,1		001 010 010 0000001		    2901
    B"001_000_001_0000001",   --2  ADDI R1,R0,1		001 000 001 0000001		    2081
    B"100_001_010_0001000",   --3  BEQ R1,R2,8		100 001 010 0001000		    8508
    B"001_001_111_0000001",   --4  ADDI R7,R1,1		001 001 111 0000001		    2781
    B"101_001_110_0000001",   --5  XORI R6,R1,1		101 001 110 0000001		    A701
    B"100_111_110_0000010",   --6  BEQ R7,R6,2		100 111 110 0000010		    9F02
    B"000_101_001_101_0_000", --7  ADD R5,R5,R1		000 101 001 101 0 000		14D0
    B"111_0000000001010",     --8  J 10			    111 0000000001010		    E00A
    B"000_100_001_100_0_000", --9  ADD R4,R4,R1		000 100 001 100 0 000		10C0
    B"001_001_001_0000001",   --10 ADDI R1,R1,1		001 001 001 0000001		    2481
    B"111_0000000000011",     --11 J 3			    111 0000000000011		    E003
    B"011_000_100_0000010",   --12 SW R4,2(R0) 		011 000 100 0000010		    6202
    B"011_000_101_0000011",   --13 SW R5,3(R0)		011 000 101 0000011		    6283
    others => x"0000");

begin
instr <= ad_rom(conv_integer(pc_out));

process(PCsrc)
begin
    if PCsrc = '1' then
        branch_out <= branch_addr;
    else
        branch_out <= pc_out + 1;
    end if;
end process;

process(Jump)
begin
    if jump = '1' then
        jump_out <= jump_addr;
    else
        jump_out <= branch_out;
    end if;     
end process;

process(clk)
begin
    if btn_reset = '1' then
        pc_out <= x"0000";
    end if;
    if rising_edge(clk) then
        if btn_en = '1' then
            pc_out <= jump_out;
        end if;
    end if;
end process;

pc_next <= pc_out + 1;


end Behavioral;
