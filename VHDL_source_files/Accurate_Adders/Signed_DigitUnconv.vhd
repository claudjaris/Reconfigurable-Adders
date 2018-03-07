----------------------------------------------------------------------------------
-- Signed Digit adder without back conversion
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity Signed_DigitUnconv is
    generic (
      N : positive := 8);

    Port ( a      : in std_logic_vector(N-1 downto 0);
           b      : in std_logic_vector(N-1 downto 0);
           c_in   : in std_logic;
           s      : out std_logic_vector(N-1 downto 0);
           c_out  : out std_logic);
end Signed_DigitUnconv;

architecture rtl of Signed_DigitUnconv is

  signal a_1  : std_logic_vector(N-1 downto 0) := (others => '0');
  signal b_1  : std_logic_vector(N-1 downto 0) := (others => '0');
  signal c_1  : std_logic_vector(N-1 downto 0) := (others => '0');
  
  signal s1_0 : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s1_1 : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s2_0 : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s2_1 : std_logic_vector(N-1 downto 0) := (others => '0');
  
  signal t1_1 : std_logic_vector(N downto 0) := (others => '0');
  signal t2_0 : std_logic_vector(N downto 0) := (others => '0');
  signal t2_1 : std_logic_vector(N downto 0) := (others => '0');
  
  signal s_reg  : std_logic_vector(N downto 0) := (others => '0');

begin

  ---------------------------first addition--------------------------
  
  a_1 <= a;
  b_1 <= b;

  --calculate first sum bits s1_0 and s1_1
  genS1_0: for i in 0 to 0 generate
  begin
    LUT_S1_0: LUT6_2
    generic map(
      INIT => X"0606060690909090"
    )
    port map(
      O6 => s1_0(i),
      O5 => s1_1(i),
      I5 => '1',
      I4 => '1',
      I3 => '1',
      I2 => c_in,
      I1 => a_1(i),
      I0 => b_1(i)
    );
  end generate genS1_0;
  
  --calculate sum bits s1_0 and s1_1
  genSi_0: for i in 1 to N-1 generate
  begin
    LUT_Si_0: LUT6_2
    generic map(
      INIT => X"0006000699909990"
    )
    port map(
      O6 => s1_0(i),
      O5 => s1_1(i),
      I5 => '1',
      I4 => '1',
      I3 => a_1(i-1),
      I2 => b_1(i-1),
      I1 => a_1(i),
      I0 => b_1(i)
    );
  end generate genSi_0;
  
  --calculate carry bits
  genCarry: for i in N to N generate
  begin
    LUT_Carry: LUT6_2
    generic map(
      INIT => X"EEEEEEEEEEEEEEEE"
    )
    port map(
      O6 => t1_1(i),
      I5 => '1',
      I4 => '1',
      I3 => '1',
      I2 => '1',
      I1 => a_1(i-1),
      I0 => b_1(i-1)
    );
  end generate genCarry;
  
  -------------------------result calculation------------------------
  
  s_reg <= t1_1(N) & s1_1(N-1 downto 0);
  
  s   <= s_reg(N-1 downto 0);
  c_out <= s_reg(N);
  

end rtl;
