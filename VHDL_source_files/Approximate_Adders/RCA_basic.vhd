----------------------------------------------------------------------------------
-- standard Vivado adder
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RCA_basic is
    generic (
      N : positive := 8);
      
    Port ( a      : in std_logic_vector(N-1 downto 0);
           b      : in std_logic_vector(N-1 downto 0);
           c_in   : in std_logic;
           s      : out std_logic_vector(N-1 downto 0);
           c_out  : out std_logic);
end RCA_basic;

architecture rtl of RCA_basic is

  signal s_reg    : unsigned(N downto 0) := (others => '0');

begin

  s_reg <= ('0' & unsigned(a)) + ('0' & unsigned(b)) + ("" & c_in);
  
  s     <= std_logic_vector(s_reg(N-1 downto 0));
  c_out <= s_reg(N);

end rtl;
