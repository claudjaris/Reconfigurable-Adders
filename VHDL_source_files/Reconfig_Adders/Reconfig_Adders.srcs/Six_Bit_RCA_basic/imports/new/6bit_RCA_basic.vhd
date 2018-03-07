----------------------------------------------------------------------------------
-- 6 Bit standard Vivado adder
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity RCA_Adder is

    Port ( a      : in std_logic_vector(7 downto 0);
           b      : in std_logic_vector(7 downto 0);
           c_in   : in std_logic;
           s      : out std_logic_vector(7 downto 0);
           c_out  : out std_logic);
end RCA_Adder;

architecture rtl of RCA_Adder is

  constant N : positive := 6;     --operand bit width

  signal s_reg    : unsigned(N downto 0) := (others => '0');

begin

  --instantiate unused upper bits into LUTs
  s1: LUT6_2
  generic map(
    INIT => X"0000000000000000"
  )
  port map(
    O6 => s(7),
    O5 => s(6),
    I5 => '1',
    I4 => '1',
    I3 => a(7),
    I2 => a(6),
    I1 => b(7),
    I0 => b(6)
  );

  s_reg <= ('0' & unsigned(a(N-1 downto 0))) + ('0' & unsigned(b(N-1 downto 0))) + ("" & c_in);
  
  s(N-1 downto 0) <= std_logic_vector(s_reg(N-1 downto 0));
  c_out         <= s_reg(N);

end rtl;
