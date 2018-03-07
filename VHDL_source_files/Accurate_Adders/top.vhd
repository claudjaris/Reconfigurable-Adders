----------------------------------------------------------------------------------
-- top module for accurate adders
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is

    generic (
      N : positive := 8;  --set bit width
      L : positive := 10; --set Fast carry length for FCCA2 (L </= N)
      T : natural  := 7); --set adder type 
                          -- 0 RCA
                          -- 1 RCA LUT only P
                          -- 2 RCA LUT PG
                          -- 3 Full KSA
                          -- 4 RCA KSA Combo
                          -- 5 Signed Digit unconverted
                          -- 6 Signed Digit Adder
                          -- 7 Fast CCA
                          -- 8 Fast CCA2

    Port ( clk        : in std_logic;
           a          : in std_logic_vector(N-1 downto 0);
           b          : in std_logic_vector(N-1 downto 0);
           c_in       : in std_logic;
           s          : out std_logic_vector(N-1 downto 0);
           c_out      : out std_logic);
end top;

architecture structure of top is

  signal a_reg : std_logic_vector(N-1 downto 0) := (others => '0');
  signal b_reg : std_logic_vector(N-1 downto 0) := (others => '0');
  signal c_reg : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_reg : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_g   : std_logic_vector(N-1 downto 0) := (others => '0');
  signal cin_reg  : std_logic := '0';
  signal cout_reg : std_logic := '0';
  signal cout_g   : std_logic := '0';

begin

  a_reg   <= a;
  b_reg   <= b;
  cin_reg <= c_in;
  s_g      <= s_reg;
  cout_g  <= cout_reg;
  
  s <= s_g;
  c_out <= cout_g;

  ----------------------------Adder types----------------------------
  
  genRCA: if T = 0 generate
    RCA_Adder: entity work.RCA_basic (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);
  end generate;

  genRCA_LUT: if T = 1 generate
    RCA_LUT: entity work.RCA_LUT (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);
  end generate;

  genRCA_LUT_PG: if T = 2 generate
    RCA_LUT_PG: entity work.RCA_LUT_PG (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);
  end generate;

  genKSA: if T = 3 generate
    KSA_Adder: entity work.KSA_Kmap (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);
  end generate;
  
  genRCKSA: if T = 4 generate
    RCA_KSA: entity work.RCA_KSA (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);
  end generate;  

  genSDAdderUnconv: if T = 5 generate  
    SignedDigitUnconv: entity work.Signed_DigitUnconv (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);  
  end generate;
    
  genSDAdder: if T = 6 generate  
    SignedDigit: entity work.Signed_Digit (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);  
  end generate;
  
  genFCCA: if T = 7 generate  
    FastCCA: entity work.Fast_CCA (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);  
  end generate;

  genFCCA2: if T = 8 generate  
    FCCA2: entity work.FCCA2 (rtl)
      generic map (
        N   => N,
        L   => L)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);  
  end generate;
  
      
end structure;
