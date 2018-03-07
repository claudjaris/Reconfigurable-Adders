----------------------------------------------------------------------------------
-- manual instantiation of the standard adder with 1 output LUTs
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pkg_KSA.all;

library UNISIM;
use UNISIM.VComponents.all;

entity RCA_LUT is
    generic (
      N : positive := 8);

    Port ( a      : in std_logic_vector(N-1 downto 0);
           b      : in std_logic_vector(N-1 downto 0);
           c_in   : in std_logic;
           s      : out std_logic_vector(N-1 downto 0);
           c_out  : out std_logic);
end RCA_LUT;

architecture rtl of RCA_LUT is

  constant Q : positive := quarterceil(N);

  signal p : std_logic_vector(N+2 downto 0) := (others => '0');
  signal carry_sig : std_logic_vector(4*Q downto 0) := (others => '0');
  
  signal ar : std_logic_vector(4*Q-1 downto 0) := (others => '0');
  signal s_reg : std_logic_vector(4*Q-1 downto 0) := (others => '0');

begin

  --------------------------carry signals--------------------------

  --assign the carry in
  carry_sig(0) <= c_in;
  
  --assign the a input
  ar(N-1 downto 0) <= a;
  
  --assign the carry out
  c_out <= carry_sig(N);
  
  --assign the sum output
  s <= s_reg(N-1 downto 0);
  
  -----------------------------RCA part----------------------------
  
  --generate the propagates for each bit for the carry chains
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
    
  --generate N/4 carry chains
  genCC: for i in 0 to Q-1 generate
  begin  
    Chain: CARRY4
      port map(
        CO  => carry_sig(4*i+4 downto 4*i+1),
        O   => s_reg(4*i+3 downto 4*i),
        CI  => carry_sig(4*i),
        CYINIT  => '0',
        DI  => ar(4*i+3 downto 4*i),
        S   => p(4*i+3 downto 4*i)
      );
  end generate genCC;  

end rtl;