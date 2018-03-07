----------------------------------------------------------------------------------
-- Fast Carry Chain adder with 4-Input LUTs
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pkg_KSA.all;

library UNISIM;
use UNISIM.VComponents.all;

entity Fast_CCA is
    generic (
      N : positive := 16;
      L : positive := 16);  --FCCA factor, smaller factor results in bigger FCCA
                            --recommended values are 16 and 10, but not bigger than N

    Port ( a      : in std_logic_vector(N-1 downto 0);
           b      : in std_logic_vector(N-1 downto 0);
           c_in   : in std_logic;
           s      : out std_logic_vector(N-1 downto 0);
           c_out  : out std_logic);
end Fast_CCA;

architecture rtl of Fast_CCA is

  constant Q : positive := N/4; --Number of regular carry chains
  constant F : natural := divisionfloor(N,L);  --Number of fast CCs

  signal carry_sig  : std_logic_vector(N downto 0) := (others => '0');  --internal fast carry signal

  signal pp, gg : std_logic_vector(4*F-1 downto 0) := (others => '0');  --group p,g signals for carry generator
  signal p, g   : std_logic_vector(N-1 downto 0) := (others => '0');  --p,g signals for carry chains
  
  signal sg   : std_logic_vector(N-1 downto 0) := (others => '0');  --sum signal
  signal cr   : std_logic_vector(N downto 0) := (others => '0');  --carry out signal

begin

  -------------------------signal assignment-------------------------

  carry_sig(0)  <= c_in;
  cr(0)         <= c_in;
  s             <= sg(N-1 downto 0);
  c_out         <= carry_sig(N);
  
  --------------------------Carry Generation-------------------------
  
  --calculate group propagate and generate signals
  genGroupPG: for i in 0 to 4*F-1 generate
  begin
    GroupPG: LUT6_2
    generic map(
      INIT => X"06600660F880F880"
    )
    port map(
      O6 => pp(i),
      O5 => gg(i),
      I5 => '1',
      I4 => '1',
      I3 => a(2*i+1),
      I2 => b(2*i+1),
      I1 => a(2*i),
      I0 => b(2*i)
    );
  end generate genGroupPG;
  
  --generate fast carries
  genFastCarry: for i in 0 to F-1 generate
  begin
    ChainF: CARRY4
    port map(
      CO   => carry_sig(8*i+8 downto 8*i+5),
      CI  => carry_sig(8*i),
      CYINIT  => '0',
      DI  => gg(4*i+3 downto 4*i),
      S   => pp(4*i+3 downto 4*i)
    );
  end generate genFastCarry;
  
  -------------------------Ripple Carry Adder------------------------
  
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
      I1 => a(i),
      I0 => b(i)
    );
  end generate genPG;

  --generate carry chains without C_out
  genCCr: for i in 0 to 2*F-1 generate
  begin  
    Chain: CARRY4
    port map(
      CO  => cr(4*i+4 downto 4*i+1),
      O   => sg(4*i+3 downto 4*i),
      CI  => cr(4*i),
      CYINIT  => '0',
      DI  => a(4*i+3 downto 4*i),
      S   => p(4*i+3 downto 4*i)
    );
  end generate genCCr;

  --generate carry chains with C_out
  genCCi: for i in 2*F to Q-1 generate
  begin  
    Chain: CARRY4
    port map(
      CO  => carry_sig(4*i+4 downto 4*i+1),
      O   => sg(4*i+3 downto 4*i),
      CI  => carry_sig(4*i),
      CYINIT  => '0',
      DI  => a(4*i+3 downto 4*i),
      S   => p(4*i+3 downto 4*i)
    );
  end generate genCCi;

end rtl;
