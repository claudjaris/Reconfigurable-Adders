----------------------------------------------------------------------------------
-- 4 Bit standard Adder with LUT instantiation
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

  constant N : positive := 4;     --operand bit width
  constant Q : positive := N/4;   --Number of carry chains

  signal p : std_logic_vector(N-1 downto 0) := (others => '0');
  signal carry_sig : std_logic_vector(N downto 0) := (others => '0');
  signal s_reg    : std_logic_vector(N-1 downto 0) := (others => '0');

begin

  --------------------------carry signals--------------------------

  --assign the carry in
  carry_sig(0) <= c_in;
  
  --asign the carry out
  c_out <= carry_sig(N);
  
  ---------------------------sum signals---------------------------
  
  s(N-1 downto 0) <= s_reg(N-1 downto 0);
  
  -----------------------------RCA part----------------------------
  
  --generate the propagates and generates for each bit for the carry chains
  genPG: for i in 0 to N-1 generate
  begin
    PG: LUT6_2
    generic map(
      INIT => X"6666666666666666"
    )
    port map(
      O6 => p(i),
      I5 => '1',
      I4 => '1',
      I3 => '1',
      I2 => '1',
      I1 => b(i),
      I0 => a(i)
    );
  end generate genPG;
  
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
    I1 => a(5),
    I0 => a(4)
  );
  
  s2: LUT6_2
  generic map(
    INIT => X"0000000000000000"
  )
  port map(
    O6 => s(5),
    O5 => s(4),
    I5 => '1',
    I4 => '1',
    I3 => b(7),
    I2 => b(6),
    I1 => b(5),
    I0 => b(4)
  );

  --generate N/4 carry chains
  genCC: for i in 0 to Q-1 generate
  begin  
    Chain: CARRY4
      port map(
        CO  => carry_sig(4*i+4 downto 4*i+1),
        O   => s_reg(4*i+3 downto 4*i),
        CI  => carry_sig(4*i),
        CYINIT  => '0',
        DI  => a(4*i+3 downto 4*i),
        S   => p(4*i+3 downto 4*i)
      );
  end generate genCC;  

end rtl;
