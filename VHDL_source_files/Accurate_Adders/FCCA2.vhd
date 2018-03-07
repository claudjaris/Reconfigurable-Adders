----------------------------------------------------------------------------------
-- Fast Carry Chain Adder version 2 with 6-Input LUTs
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pkg_KSA.all;

library UNISIM;
use UNISIM.VComponents.all;

entity FCCA2 is
    generic (
      N : positive := 16);

    Port ( a      : in std_logic_vector(N-1 downto 0);
           b      : in std_logic_vector(N-1 downto 0);
           c_in   : in std_logic;
           s      : out std_logic_vector(N-1 downto 0);
           c_out  : out std_logic);
end FCCA2;

architecture rtl of FCCA2 is

  constant cThird : natural := thirdfloor(N);       --number of carry generators
  constant cTwelf : natural := twelffloor(cThird);  --number of fast carry chains

  signal carry_sig  : std_logic_vector(cThird+3 downto 0) := (others => '0'); --internal carry signal

  signal pp, gg : std_logic_vector(cThird+3 downto 0) := (others => '0'); --group p,g signals for carry generator
  signal ar, br : std_logic_vector(N+1 downto 0) := (others => '0');      --a,b widend input signals
  signal p, g   : std_logic_vector(N+2 downto 0) := (others => '0');      --p,g signals for carry chains
  
  subtype tStage is std_logic_vector(N+2 downto 0);
  type tStages is array(natural range<>) of tStage;
  
  signal sr   : tStages(0 to cThird) := (others => (others => '0'));  --array of partial sums
  signal sg   : std_logic_vector(N+2 downto 0) := (others => '0');    --sum signal
  signal cr   : std_logic_vector(N+3 downto cThird) := (others => '0'); --carry out signal

begin

  -------------------------signal assignment-------------------------

  ar            <= a(N-1) & a(N-1) & a;
  br            <= b(N-1) & b(N-1) & b;
  carry_sig(0)  <= c_in;
  s             <= sg(N-1 downto 0);
  c_out         <= carry_sig(cThird+1);
  
  --------------------------Carry Generation-------------------------
  
  --calculate N/3 group propagate signals
  genGroupP: for i in 0 to cThird-1 generate
  begin
    GroupP: LUT6_2
    generic map(
      INIT => X"0000066006600000"
    )
    port map(
      O6 => pp(i),
      I5 => ar(3*i+2),
      I4 => br(3*i+2),
      I3 => ar(3*i+1),
      I2 => br(3*i+1),
      I1 => ar(3*i),
      I0 => br(3*i)
    );
  end generate genGroupP;
  
  --calculate N/3 group generate signals
  genGroupG: for i in 0 to cThird-1 generate
  begin
    GroupG: LUT6_2
    generic map(
      INIT => X"FFFFF880F8800000"
    )
    port map(
      O6 => gg(i),
      I5 => ar(3*i+2),
      I4 => br(3*i+2),
      I3 => ar(3*i+1),
      I2 => br(3*i+1),
      I1 => ar(3*i),
      I0 => br(3*i)
    );
  end generate genGroupG;
  
  --calculate the last group propagate and generate signals in one LUT
  genGroupPG: for i in cThird to cThird generate
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
      I3 => ar(3*i+1),
      I2 => br(3*i+1),
      I1 => ar(3*i),
      I0 => br(3*i)
    );
  end generate genGroupPG;
  
  --generate fast carries
  genFastCarry: for i in 0 to cTwelf generate
  begin
    ChainF: CARRY4
    port map(
      CO   => carry_sig(4*i+4 downto 4*i+1),
      CI  => carry_sig(4*i),
      CYINIT  => '0',
      DI  => gg(4*i+3 downto 4*i),
      S   => pp(4*i+3 downto 4*i)
    );
  end generate genFastCarry;
  
--  -------------------------Ripple Carry Adder------------------------
  
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
      I1 => ar(i),
      I0 => br(i)
    );
  end generate genPG;

  --use all carry chains for 8 and 32 bit width
  EightB: if N = 8 or N = 32 generate
    --generate carry chains without C_out
    genCC: for i in 0 to cThird generate
    begin  
      Chain: CARRY4
      port map(
        O   => sr(i)(3*i+3 downto 3*i),
        CI  => carry_sig(i),
        CYINIT  => '0',
        DI  => ar(3*i+3 downto 3*i),
        S   => p(3*i+3 downto 3*i)
      );
      sg(3*i+2 downto 3*i)  <= sr(i)(3*i+2 downto 3*i);
    end generate genCC;
  end generate EightB;
  
  --save the last carry chain and get the last sum bit from previous CC
  SixteenB: if N = 16 or N = 64 generate
    --generate carry chains without C_out
    genCC: for i in 0 to cThird-1 generate
    begin  
      Chain: CARRY4
      port map(
        O   => sr(i)(3*i+3 downto 3*i),
        CI  => carry_sig(i),
        CYINIT  => '0',
        DI  => ar(3*i+3 downto 3*i),
        S   => p(3*i+3 downto 3*i)
      );
      PrevCC: if i < cThird-1 generate
        sg(3*i+2 downto 3*i)  <= sr(i)(3*i+2 downto 3*i);
      end generate PrevCC;
      LastCC: if i = cThird-1 generate
        sg(3*i+3 downto 3*i)  <= sr(i)(3*i+3 downto 3*i);
      end generate LastCC;
    end generate genCC;
  end generate SixteenB;

end rtl;
