----------------------------------------------------------------------------------
-- 6 Bit standard adder with first 2 LUTs cut and position switch
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pkg_Functions.all;

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

  constant N : positive := 6;                 --operand bit width
  constant Q : positive := 1;                 --Number of carry chains
  
  signal p, g : std_logic_vector(N+1 downto 0) := (others => '0');
  signal carry_sig : std_logic_vector(4*Q downto 0) := (others => '0');
  signal s_reg : std_logic_vector(4*Q-1 downto 0) := (others => '0');

begin

  --set input 'a' as generate input for the CC
  g(N-1 downto 4) <= a(N-1 downto 4);

  --------------------------carry signals--------------------------

  --assign the carry in
  carry_sig(0) <= c_in;
 
  --assign the carry out
  c_out <= carry_sig(N-2);
  
  -------------------------approx signals--------------------------
  
  --assign a(2 downto 0) to s(2 downto 0)
  s(0) <= a(0);
  s(1) <= s_reg(0);
  s(2) <= a(2);
  
  --assign the rest of the higher bits from the CCs to s
  s(N-1 downto 3) <= s_reg(N-3 downto 1);
  
  -----------------------------RCA part----------------------------
  
  --optimize LUTs PG2 and PG3 to catch bigger carry errors
  PG2: LUT6_2
  generic map(
    INIT => X"02BDBD40FFC0C000"
  )
  port map(
    O6 => p(2),
    O5 => g(2),
    I5 => '1',
    I4 => a(1),
    I3 => b(1),
    I2 => a(0),
    I1 => b(0),
    I0 => c_in
  );
  
  PG3: LUT6_2
  generic map(
    INIT => X"06600660F880F880"
  )
  port map(
    O6 => p(3),
    O5 => g(3),
    I5 => '1',
    I4 => '1',
    I3 => a(3),
    I2 => b(3),
    I1 => a(2),
    I0 => b(2)
  );
        
  --generate the propagates and generates for each bit for the carry chains
  genPG: for i in 4 to N-1 generate
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
    
  --generate N/4 carry chains
  genCC: for i in 0 to Q-1 generate
  begin  
    Chain: CARRY4
      port map(
        CO  => carry_sig(4*i+4 downto 4*i+1),
        O   => s_reg(4*i+3 downto 4*i),
        CI  => carry_sig(4*i),
        CYINIT  => '0',
        DI  => g(4*i+5 downto 4*i+2),
        S   => p(4*i+5 downto 4*i+2)
      );
  end generate genCC;  

end rtl;
