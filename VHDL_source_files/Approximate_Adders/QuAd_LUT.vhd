----------------------------------------------------------------------------------
-- QuAd-Adder with complete generic parameters for N, R_vect and P_vect
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pkg_Functions.all;

library UNISIM;
use UNISIM.VComponents.all;

entity QuAd_LUT is
    generic (
      N : positive := 8;          --operand bit width
      R : my_array_t := (3,3,2);  --number of resultant bits per sub adder
      P : my_array_t := (0,2,4)); --number of previous bits per sub adder
                                  --P_i < R_i-1 + P_i-1 , P(0) = 0
      
    Port ( a      : in std_logic_vector(N-1 downto 0);
           b      : in std_logic_vector(N-1 downto 0);
           c_in   : in std_logic;
           s      : out std_logic_vector(N-1 downto 0);
           c_out  : out std_logic);
end QuAd_LUT;

architecture rtl of QuAd_LUT is
  
  constant K : positive := R'length;              --Number of sub adders
  constant R_sum : my_array_t := array_sum(R, K); --Summed up Bits of all sub adders
  constant L : my_array_t := array_add(R, P, K);  --sub-adder bit width
  constant Q : my_array_t := array_quarter(L, K); --Number of Carry Chains per Sub-Adder - 1

  subtype tStage is std_logic_vector(2*N downto 0);
  type tStages is array(natural range<>) of tStage; --custom type for an array of SLVs
  
  signal temp : tStages(0 to K-1) := (others => (others => '0'));   --partial results per sub adder

  signal ar : std_logic_vector(2*N downto 0) := (others => '0');
  signal result : std_logic_vector(N downto 0) := (others => '0');  --final result including carry out
  
  signal pp, gg : tStages(0 to K-1) := (others => (others => '0')); --propagate/generate signals
  signal carry_sig : tStages(0 to K-1) := (others => (others => '0'));  --carry signals from the carry chains

begin

  carry_sig(0)(0) <= c_in;  --assign the carry_in to the Carry Chains
  ar(N-1 downto 0)  <= a;
  
  --start of the adder generation
  Gen_LUT: for i in 0 to K-1 generate --for each sub adder
    LowBit: if i = 0 generate --for the first sub adder
      --reduce the hardware amount when sub adders are smaller than 3
      SmallAdd1: if L(i) = 1 generate
        PGSmall: LUT6_2
        generic map(
          INIT => X"9696969696969696"
        )
        port map(
          O6 => result(R_sum(i)-1),
          I5 => '1',
          I4 => '1',
          I3 => '1',
          I2 => carry_sig(i)(R_sum(i)-1),
          I1 => a(R_sum(i)-1),
          I0 => b(R_sum(i)-1)
        );
      end generate SmallAdd1;
    
    SmallAdd2: if L(i) = 2 generate
        PGSmall: LUT6_2
        generic map(
          INIT => X"E81717E896969696"
        )
        port map(
          O6 => result(R_sum(i)-1),
          O5 => result(R_sum(i)-2),
          I5 => '1',
          I4 => a(R_sum(i)-1),
          I3 => b(R_sum(i)-1),
          I2 => a(R_sum(i)-2),
          I1 => b(R_sum(i)-2),
          I0 => carry_sig(i)(R_sum(i)-2)
        );
      end generate SmallAdd2;
      --normal calculation with LUTs and CCs
      BigAdd: if L(i) > 2 generate
        LowLUT: for j in 0 to R(i)-1 generate --for first sub adder width
          --generate PG signals
          PGLow: LUT6_2
          generic map(
            INIT => X"6666666666666666"
          )
          port map(
            O6 => pp(i)(j),
            I5 => '1',
            I4 => '1',
            I3 => '1',
            I2 => '1',
            I1 => a(j),
            I0 => b(j)
          );
        end generate LowLUT;
        --generate Carry Chain(s)
        LowCarry: for m in 0 to Q(i) generate
          ChainLow: CARRY4
          port map(
            CO  => carry_sig(i)(4*m+4 downto 4*m+1),
            O   => temp(i)(4*m+3 downto 4*m),
            CI  => carry_sig(i)(4*m),
            CYINIT  => '0',
            DI  => ar(4*m+3 downto 4*m),
            S   => pp(i)(4*m+3 downto 4*m)
          );
        end generate LowCarry;
   
      end generate BigAdd;
    end generate LowBit;
    
    MidBit: if i /= 0 and i /= K-1 generate --for middle sub adders
      --reduce the hardware amount when sub adders are smaller than 3
      SmallAdd1: if L(i) = 1 generate
        PGSmall: LUT6_2
        generic map(
          INIT => X"8778877887788778"
        )
        port map(
          O6 => result(R_sum(i)-1),
          I5 => '1',
          I4 => '1',
          I3 => a(R_sum(i)-1),
          I2 => b(R_sum(i)-1),
          I1 => a(R_sum(i)-2),
          I0 => b(R_sum(i)-2)
        );
      end generate SmallAdd1;
      
      SmallAdd2: if L(i) = 2 and R(i) = 2 generate
        PGSmall: LUT6_2
        generic map(
          INIT => X"8778877866666666"
        )
        port map(
          O6 => result(R_sum(i)-1),
          O5 => result(R_sum(i)-2),
          I5 => '1',
          I4 => '1',
          I3 => a(R_sum(i)-1),
          I2 => b(R_sum(i)-1),
          I1 => a(R_sum(i)-2),
          I0 => b(R_sum(i)-2)
        );
      end generate SmallAdd2;
      SmallAdd3: if L(i) = 2 and R(i) = 1 generate
        PGSmall: LUT6_2
        generic map(
          INIT => X"8778877887788778"
        )
        port map(
          O6 => result(R_sum(i)-1),
          I5 => '1',
          I4 => '1',
          I3 => a(R_sum(i)-1),
          I2 => b(R_sum(i)-1),
          I1 => a(R_sum(i)-2),
          I0 => b(R_sum(i)-2)
        );
      end generate SmallAdd3;
            
      --normal calculation with LUTs and CCs
      BigAdd: if L(i) > 2 generate
        MidLUT: for j in R_sum(i-1)-P(i) to R_sum(i)-1 generate --for sub adders bit width
          FirstMid: if j = R_sum(i-1)-P(i) generate
            --generate group PG signal
            PGMidFirst: LUT6_2
            generic map(
              INIT => X"06600660F880F880"
            )
            port map(
              O6 => pp(i)(j),
              O5 => gg(i)(j),
              I5 => '1',
              I4 => '1',
              I3 => a(j),
              I2 => b(j),
              I1 => a(j-1),
              I0 => b(j-1)
            );
          end generate FirstMid;
          OthersMid: if j /= R_sum(i-1)-P(i) generate
            --generate PG signals
            PGMid: LUT6_2
            generic map(
              INIT => X"6666666666666666"
            )
            port map(
              O6 => pp(i)(j),
              I5 => '1',
              I4 => '1',
              I3 => '1',
              I2 => '1',
              I1 => a(j),
              I0 => b(j)
            );
          end generate OthersMid;
        end generate MidLUT;
        --generate Carry Chains
        MidCarry: for m in 0 to Q(i) generate
          ChainMid: CARRY4
          port map(
            CO  => carry_sig(i)(4*m+4 downto 4*m+1),
            O   => temp(i)(4*m+3 downto 4*m),
            CI  => carry_sig(i)(4*m),
            CYINIT  => '0',
            DI  => ar(4*m+3+R_sum(i-1)-P(i) downto 4*m+R_sum(i-1)-P(i)),
            S   => pp(i)(4*m+3+R_sum(i-1)-P(i) downto 4*m+R_sum(i-1)-P(i))
          );
        end generate MidCarry;
        
      end generate BigAdd;
    end generate MidBit;
    
    HighBit: if i = K-1 generate  --for last sub adder
      --reduce the hardware amount when sub adders are smaller than 2
      SmallAdd1: if L(i) = 1 generate
        PGSmall: LUT6_2
        generic map(
          INIT => X"87788778F880F880"
        )
        port map(
          O6 => result(R_sum(i)-1),
          O5 => carry_sig(i)(L(i)),
          I5 => '1',
          I4 => '1',
          I3 => a(R_sum(i)-1),
          I2 => b(R_sum(i)-1),
          I1 => a(R_sum(i)-2),
          I0 => b(R_sum(i)-2)
        );
      end generate SmallAdd1;

      --normal calculation with LUTs and CCs
      BigAdd: if L(i) > 1 generate
        HighLUT: for j in R_sum(i-1)-P(i) to R_sum(i)-1 generate  --for last sub adder width
          FirstHigh: if j = R_sum(i-1)-P(i) generate
            --generate group PG signal
            PGHighFirst: LUT6_2
            generic map(
              INIT => X"06600660F880F880"
            )
            port map(
              O6 => pp(i)(j),
              O5 => gg(i)(j),
              I5 => '1',
              I4 => '1',
              I3 => a(j),
              I2 => b(j),
              I1 => a(j-1),
              I0 => b(j-1)
            );
          end generate FirstHigh;
          OthersHigh: if j /= R_sum(i-1)-P(i) generate
            --generate PG signals
            PGHigh: LUT6_2
            generic map(
              INIT => X"6666666666666666"
            )
            port map(
              O6 => pp(i)(j),
              I5 => '1',
              I4 => '1',
              I3 => '1',
              I2 => '1',
              I1 => a(j),
              I0 => b(j)
            );
          end generate OthersHigh;
        end generate HighLUT;
        --generate Carry Chains
        HighCarry: for m in 0 to Q(i) generate
          ChainHigh: CARRY4
          port map(
            CO  => carry_sig(i)(4*m+4 downto 4*m+1),
            O   => temp(i)(4*m+3 downto 4*m),
            CI  => carry_sig(i)(4*m),
            CYINIT  => '0',
            DI  => ar(4*m+3+R_sum(i-1)-P(i) downto 4*m+R_sum(i-1)-P(i)),
            S   => pp(i)(4*m+3+R_sum(i-1)-P(i) downto 4*m+R_sum(i-1)-P(i))
          );
        end generate HighCarry;
      
      end generate BigAdd;
    end generate HighBit;
        
  end generate Gen_LUT;
  
  --result assignment
  Gen_Sum: for i in 0 to K-1 generate
    Low_Res: if i = 0 and L(i) > 2 generate  --first partial result
      result(R(i)-1 downto 0) <= std_logic_vector(temp(i)((L(i)-1) downto 0));
    end generate Low_Res;
    Mid_Res: if i /= 0 and i /= K-1 and L(i) > 2 generate  --mid partial results
      result(R_sum(i)-1 downto R_sum(i-1)) <= std_logic_vector(temp(i)(L(i)-1 downto P(i)));
    end generate Mid_Res;
    High_Res: if i = K-1 and L(i) > 1 generate --last partial result including carry out
      result(R_sum(i)-1 downto R_sum(i-1)) <= std_logic_vector(temp(i)(L(i)-1 downto P(i)));
    end generate High_Res;     
  end generate Gen_Sum;

  c_out <= carry_sig(K-1)(L(K-1)); --carry out
  s     <= result(N-1 downto 0);  --final sum

end rtl;
