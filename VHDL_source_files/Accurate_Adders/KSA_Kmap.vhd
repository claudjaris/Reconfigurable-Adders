----------------------------------------------------------------------------------
-- full generic KSA adder up to 64 bits
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pkg_KSA.all;

library UNISIM;
use UNISIM.VComponents.all;

entity KSA_Kmap is
    generic (
      N : positive := 8);

    Port ( a      : in std_logic_vector(N-1 downto 0);
           b      : in std_logic_vector(N-1 downto 0);
           c_in   : in std_logic;
           s      : out std_logic_vector(N-1 downto 0);
           c_out  : out std_logic);
end KSA_Kmap;

architecture rtl of KSA_Kmap is

  constant k : natural  := log2ceil(N); --number of stages
  constant M : positive := N/2;         --second part of carry and sum calculation

  subtype tStage is std_logic_vector(N-1 downto 0);
  type tStages is array(natural range<>) of tStage;

  --the group propagate and generate signals for every stage
  signal pp, gg : tStages(0 to K) := (others => (others => '0'));

  component LUT6_2 is
    generic(
      INIT : bit_vector := X"0000000000000000"
    );
    port(
      O5 : out std_logic;
      O6 : out std_logic;
      I0 : in std_logic;
      I1 : in std_logic;
      I2 : in std_logic;
      I3 : in std_logic;
      I4 : in std_logic;
      I5 : in std_logic
    );
  end component LUT6_2;

begin

  --generate gp signals together with stage 1 except for the LSB
  genStg0and1: for i in 1 to N-1 generate
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
    genStgHigh: for i in P to N-1 generate
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
    genStgHigh: for i in P to N-1 generate
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
  
  --calculate the sum for S3 to N/2
  genSumLow: for j in 2 to K-1 generate
  constant D : natural := 2**(j-1);
  begin
    genSumL: for i in D to 2*D-1 generate
    begin
      SumL: LUT6_2
      generic map(
        INIT => X"F80707F8F80707F8"
      )
      port map(
        O6 => s(i+1),
        I5 => '1',
        I4 => a(i+1),
        I3 => b(i+1),
        I2 => gg(j)(i),
        I1 => pp(j)(i),
        I0 => c_in
      );
    end generate genSumL;
  end generate genSumLow;
  
  --calculate the sum for N/2+1 to N-1
  genSumHigh: for j in K to K generate
  constant D : natural := 2**(j-1);
  begin
    genSumH: for i in D to N-2 generate
    begin
      SumH: LUT6_2
      generic map(
        INIT => X"F80707F8F80707F8"
      )
      port map(
        O6 => s(i+1),
        I5 => '1',
        I4 => a(i+1),
        I3 => b(i+1),
        I2 => gg(j)(i),
        I1 => pp(j)(i),
        I0 => c_in
      );
    end generate genSumH;
  end generate genSumHigh;  
  
  --calculate sum bit S2
  S2: LUT6_2
  generic map(
    INIT => X"F80707F8F80707F8"
  )
  port map(
    O6 => s(2),
    I5 => '1',
    I4 => a(2),
    I3 => b(2),
    I2 => gg(1)(1),
    I1 => pp(1)(1),
    I0 => c_in
  ); 
  
  --calculate the sum bits S1 and S0
  S1S0: LUT6_2
  generic map(
    INIT => X"E81717E896969696"
    )
    port map(
      O6 => s(1),
      O5 => s(0),
      I5 => '1',
      I4 => a(1),
      I3 => b(1),
      I2 => a(0),
      I1 => b(0),
      I0 => c_in
    );

  --calculate the carry out
  Cout: LUT6_2
  generic map(
    INIT => X"FFFFF800FFFFF800"
    )
    port map(
      O6 => c_out,
      I5 => '1',
      I4 => gg(k-1)(N-1),
      I3 => pp(k-1)(N-1),
      I2 => gg(k-1)(M-1),
      I1 => pp(k-1)(M-1),
      I0 => c_in
    );
      
end rtl;
