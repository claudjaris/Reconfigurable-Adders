----------------------------------------------------------------------------------
-- RCA-KSA combo cutting the carry chain at N/2 providing the carry_in from the KSA-part
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pkg_KSA.all;

library UNISIM;
use UNISIM.VComponents.all;

entity RCA_KSA is
    generic (
      N : positive := 16);

    Port ( a      : in std_logic_vector(N-1 downto 0);
           b      : in std_logic_vector(N-1 downto 0);
           c_in   : in std_logic;
           s      : out std_logic_vector(N-1 downto 0);
           c_out  : out std_logic);
end RCA_KSA;

architecture rtl of RCA_KSA is

  constant k : natural  := log2ceil(N/2); --number of stages
  constant M : positive := N/4;           --second part of carry and sum calculation

  constant Half : positive := N/2;
  constant Quarter : positive := N/4;

  signal carry_KSA : std_logic_vector(N downto 0) := (others => '0');
  signal carry_sig : std_logic_vector(N downto 0) := (others => '0');
  signal carry_ins : std_logic_vector(N downto 0) := (others => '0');

  signal p, g : std_logic_vector(N-1 downto 0) := (others => '0');
  
  subtype tStage is std_logic_vector(N-1 downto 0);
  type tStages is array(natural range<>) of tStage;

  --the group propagate and generate signals for every stage
  signal pp, gg : tStages(0 to k) := (others => (others => '0'));
  
begin

  --------------------------carry signals--------------------------

  --assign the carry in
  carry_ins(0) <= c_in;
  
  --carry input signal assignment
  carry_ins(N downto Half+Quarter+1) <= carry_sig(N downto Half+Quarter+1);
  carry_ins(Half+Quarter) <= carry_sig(Half+Quarter);
  carry_ins(Half+Quarter-1 downto Half+1) <= carry_sig(Half+Quarter-1 downto Half+1);
  carry_ins(Half) <= carry_KSA(Half);
  carry_ins(Half-1 downto Half-Quarter+1) <= carry_sig(Half-1 downto Half-Quarter+1);
  carry_ins(Quarter) <= carry_sig(Quarter);
  carry_ins(Half-Quarter-1 downto 1) <= carry_sig(Half-Quarter-1 downto 1);
  
  --assign the carry out
  c_out <= carry_sig(N);

  -----------------------------KSA part----------------------------

  --generate gp signals together with stage 1 except for the LSB
  genStg0and1: for i in 1 to Half-1 generate
  begin
    Stg0and1: LUT6_2
    generic map(
      INIT => X"F880F88006600660"
    )
    port map(
      O6 => gg(1)(i),
      O5 => pp(1)(i),
      I5 => '1',
      I4 => '1',
      I3 => a(i),
      I2 => b(i),
      I1 => a(i-1),
      I0 => b(i-1)
    );
  end generate genStg0and1;
  
  --generate group G and P for stages 2 to K-1
  genStages: for j in 2 to K-1 generate
  constant D  : natural := 2**(j-1);
  
  constant H  : natural := D/2;           --Half D
  constant P  : natural := D + H;         --1 and half D
  
  constant Q  : natural := halfceil(H);   --Quarter D
  constant F  : natural := D + Q;         --1 and quarter D
  
  constant E  : natural := halfceil(Q);   --Eighth of D
  constant X  : natural := D + E;         --1 and Eighth D
  
  constant Sx : natural := halfceil(E);   --Sixteenth of D
  constant Th : natural := halfceil(Sx);  --Thirtysecond of D
  begin
    --generate the high stages with just taking inputs from the previous stage
    genStgHigh: for i in P to Half-1 generate
    begin
      StgHigh: LUT6_2
      generic map(
        INIT => X"FFC0FFC0A0A0A0A0"
      )
      port map(
        O6 => gg(j)(i),
        O5 => pp(j)(i),
        I5 => '1',
        I4 => '1',
        I3 => gg(j-1)(i),
        I2 => pp(j-1)(i),
        I1 => gg(j-1)(i-D),
        I0 => pp(j-1)(i-D)
      );
    end generate genStgHigh;

    --generate the mid stages taking inputs from 2 stages before
    genStgMid: for i in F to P-1 generate
    begin
      StgMid: LUT6_2
      generic map(
        INIT => X"FFC0FFC0A0A0A0A0"
      )
      port map(
        O6 => gg(j)(i),
        O5 => pp(j)(i),
        I5 => '1',
        I4 => '1',
        I3 => gg(j-1)(i),
        I2 => pp(j-1)(i),
        I1 => gg(j-2)(i-D),
        I0 => pp(j-2)(i-D)
      );
    end generate genStgMid;
    
    --generate the low stages taking inputs from 3 stages before
    genStgLow: for i in X to F-1 generate
    begin
      StgLow: LUT6_2
      generic map(
        INIT => X"FFC0FFC0A0A0A0A0"
      )
      port map(
        O6 => gg(j)(i),
        O5 => pp(j)(i),
        I5 => '1',
        I4 => '1',
        I3 => gg(j-1)(i),
        I2 => pp(j-1)(i),
        I1 => gg(j-3)(i-D),
        I0 => pp(j-3)(i-D)
      );
    end generate genStgLow;
    
    --generate the lower stages taking inputs from 4 stages before
    genStgLower: for i in D+Sx to X-1 generate
    begin
      StgLower: LUT6_2
      generic map(
        INIT => X"FF80FF8060606060"
      )
      port map(
        O6 => gg(j)(i),
        O5 => pp(j)(i),
        I5 => '1',
        I4 => '1',
        I3 => gg(j-1)(i),
        I2 => pp(j-1)(i),
        I1 => gg(j-4)(i-D),
        I0 => pp(j-4)(i-D)
      );
    end generate genStgLower;         
    
    --generate the lower stages taking inputs from 5 stages before
    genStgLowest: for i in D+Th to D+Sx-1 generate
    begin
      StgLowest: LUT6_2
      generic map(
        INIT => X"FF80FF8060606060"
      )
      port map(
        O6 => gg(j)(i),
        O5 => pp(j)(i),
        I5 => '1',
        I4 => '1',
        I3 => gg(j-1)(i),
        I2 => pp(j-1)(i),
        I1 => gg(j-5)(i-D),
        I0 => pp(j-5)(i-D)
      );
    end generate genStgLowest; 
    
    --generate the P and G taking inputs from the LSBs
    StgLSB: LUT6_2
    generic map(
      INIT => X"FF80FF8060606060"
    )
    port map(
      O6 => gg(j)(D),
      O5 => pp(j)(D),
      I5 => '1',
      I4 => '1',
      I3 => gg(j-1)(D),
      I2 => pp(j-1)(D),
      I1 => a(0),
      I0 => b(0)
    );  
  end generate genStages;
  
  --generate group G and P for stage K
  genLastStage: for j in K to K generate
  constant D  : natural := 2**(j-1);
  
  constant H  : natural := D/2;           --Half D
  constant P  : natural := D + H;         --1 and half D
  
  constant Q  : natural := halfceil(H);   --Quarter D
  constant F  : natural := D + Q;         --1 and quarter D
  
  constant E  : natural := halfceil(Q);   --Eighth of D
  constant X  : natural := D + E;         --1 and Eighth D
  
  constant Sx : natural := halfceil(E);   --Sixteenth of D
  constant Th : natural := halfceil(Sx);  --Thirtysecond of D
  begin
    --generate the high stages with just taking inputs from the previous stage
    genStgHigh: for i in P to Half-1 generate
    begin
      StgHigh: LUT6_2
      generic map(
        INIT => X"FFC0FFC0A0A0A0A0"
      )
      port map(
        O6 => gg(j)(i),
        O5 => pp(j)(i),
        I5 => '1',
        I4 => '1',
        I3 => gg(j-1)(i),
        I2 => pp(j-1)(i),
        I1 => gg(j-1)(i-D),
        I0 => pp(j-1)(i-D)
      );
    end generate genStgHigh;

    --generate the mid stages taking inputs from 2 stages before
    genStgMid: for i in F to P-1 generate
    begin
      StgMid: LUT6_2
      generic map(
        INIT => X"FFC0FFC0A0A0A0A0"
      )
      port map(
        O6 => gg(j)(i),
        O5 => pp(j)(i),
        I5 => '1',
        I4 => '1',
        I3 => gg(j-1)(i),
        I2 => pp(j-1)(i),
        I1 => gg(j-2)(i-D),
        I0 => pp(j-2)(i-D)
      );
    end generate genStgMid;
    
    --generate the low stages taking inputs from 3 stages before
    genStgLow: for i in X to F-1 generate
    begin
      StgLow: LUT6_2
      generic map(
        INIT => X"FFC0FFC0A0A0A0A0"
      )
      port map(
        O6 => gg(j)(i),
        O5 => pp(j)(i),
        I5 => '1',
        I4 => '1',
        I3 => gg(j-1)(i),
        I2 => pp(j-1)(i),
        I1 => gg(j-3)(i-D),
        I0 => pp(j-3)(i-D)
      );
    end generate genStgLow;
    
    --generate the lower stages taking inputs from 4 stages before
    genStgLower: for i in D+Sx to X-1 generate
    begin
      StgLower: LUT6_2
      generic map(
        INIT => X"FF80FF8060606060"
      )
      port map(
        O6 => gg(j)(i),
        O5 => pp(j)(i),
        I5 => '1',
        I4 => '1',
        I3 => gg(j-1)(i),
        I2 => pp(j-1)(i),
        I1 => gg(j-4)(i-D),
        I0 => pp(j-4)(i-D)
      );
    end generate genStgLower;         
    
    --generate the lower stages taking inputs from 5 stages before
    genStgLowest: for i in D+Th to D+Sx-1 generate
    begin
      StgLowest: LUT6_2
      generic map(
        INIT => X"FF80FF8060606060"
      )
      port map(
        O6 => gg(j)(i),
        O5 => pp(j)(i),
        I5 => '1',
        I4 => '1',
        I3 => gg(j-1)(i),
        I2 => pp(j-1)(i),
        I1 => gg(j-5)(i-D),
        I0 => pp(j-5)(i-D)
      );
    end generate genStgLowest; 
    
    --generate the P and G stages taking inputs from the LSBs
    StgLSB: LUT6_2
    generic map(
      INIT => X"FF80FF8060606060"
    )
    port map(
      O6 => gg(j)(D),
      O5 => pp(j)(D),
      I5 => '1',
      I4 => '1',
      I3 => gg(j-1)(D),
      I2 => pp(j-1)(D),
      I1 => a(0),
      I0 => b(0)
    );   
  end generate genLastStage;  

  --calculate the carry out
  Cout: LUT6_2
  generic map(
    INIT => X"FFFFF800FFFFF800"
    )
    port map(
      O6 => carry_KSA(Half),
      I5 => '1',
      I4 => gg(k-1)(Half-1),
      I3 => pp(k-1)(Half-1),
      I2 => gg(k-1)(M-1),
      I1 => pp(k-1)(M-1),
      I0 => c_in
    );

  -----------------------------RCA part----------------------------
  
  --generate the propagates for each bit for the carry chains
  genPG: for i in 0 to N-1 generate
  begin
    PG: LUT6_2
    generic map(
      INIT => X"6666666688888888"
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

  --generate carry chains
  genCC: for i in 0 to Quarter-1 generate
  begin  
    Chain: CARRY4
      port map(
        CO  => carry_sig(4*i+4 downto 4*i+1),
        O   => s(4*i+3 downto 4*i),
        CI  => carry_ins(4*i),
        CYINIT  => '0',
        DI  => a(4*i+3 downto 4*i),
        S   => p(4*i+3 downto 4*i)
      );
  end generate genCC;

end rtl;
