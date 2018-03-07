----------------------------------------------------------------------------------
-- standard adder with 1 LUT cut at original position
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pkg_Functions.all;

library UNISIM;
use UNISIM.VComponents.all;

entity RCA_cut1LUT is
    generic (
      N : positive := 8);

    Port ( a      : in std_logic_vector(N-1 downto 0);
           b      : in std_logic_vector(N-1 downto 0);
           c_in   : in std_logic;
           s      : out std_logic_vector(N-1 downto 0);
           c_out  : out std_logic);
end RCA_cut1LUT;

architecture rtl of RCA_cut1LUT is

  constant Q : positive := quarterceil(N);

  signal p, g : std_logic_vector(N+1 downto 0) := (others => '0');
  signal carry_sig : std_logic_vector(4*Q downto 0) := (others => '0');
  
  signal s_reg : std_logic_vector(4*Q-1 downto 0) := (others => '0');

begin

  g(N-1 downto 2) <= a(N-1 downto 2);

  --------------------------carry signals--------------------------

  --assign the carry in
  carry_sig(0) <= '0';
  
  --assign the carry out
  c_out <= carry_sig(N);
  
  -------------------------approx signals--------------------------
  
  --assign a(0) to s(0)
  s(0) <= a(0);
  s(N-1 downto 1) <= s_reg(N-1 downto 1);
  
  -----------------------------RCA part----------------------------
  
  --PG1 takes additional Inputs from previous bit to calculate correct carry
  PG1: LUT6_2
  generic map(
    INIT => X"001717E8FFE8E800"
  )
  port map(
    O6 => p(1),
    O5 => g(1),
    I5 => '1',
    I4 => a(1),
    I3 => b(1),
    I2 => a(0),
    I1 => b(0),
    I0 => c_in
  );
        
  --generate the propagates and generates for each bit for the carry chains
  genPG: for i in 2 to N-1 generate
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
      I1 => a(i),
      I0 => b(i)
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
        DI  => g(4*i+3 downto 4*i+0),
        S   => p(4*i+3 downto 4*i+0)
      );
  end generate genCC;  

end rtl;
