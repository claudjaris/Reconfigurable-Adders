----------------------------------------------------------------------------------
-- the top module of approximate adders
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pkg_Functions.all;

library UNISIM;
use UNISIM.VComponents.all;

entity top is

    generic (
      N : positive := 4; --set bit width
      R_vect : my_array_t :=   (3,1); --used for QuAd Adder
      P_vect : my_array_t :=   (0,2); --used for QuAd Adder
      T : natural  :=  1); --set adder type 
                          -- 0 RCA_basic  / accurate
                          -- 1 RCA_LUT    / accurate
                          -- 2 RCA_cut1LUT
                          -- 3 RCA_cut1LUT_switch
                          -- 4 RCA_cut2LUT
                          -- 5 RCA_cut2LUT_switch
                          -- 6 QuAd_LUT

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
    Basic: entity work.RCA_basic (rtl)
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
    LUT: entity work.RCA_LUT (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);
  end generate;

  genRCA_cut1LUT: if T = 2 generate
    cut1LUT: entity work.RCA_cut1LUT (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);
  end generate;

  genRCA_cut1LUT_switch: if T = 3 generate
    cut1LUT_switch: entity work.RCA_cut1LUT_switch (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);
  end generate;

  genRCA_cut2LUT: if T = 4 generate
    cut2LUT: entity work.RCA_cut2LUT (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);
  end generate;

  genRCA_cut2LUT_switch: if T = 5 generate
    cut2LUT_switch: entity work.RCA_cut2LUT_switch (rtl)
      generic map (
        N   => N)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);
  end generate;
  
   genQuAd_LUT: if T = 6 generate
    QuAd: entity work.QuAd_LUT (rtl)
      generic map (
        N   => N,
        R   => R_vect,
        P   => P_vect)
      port map (
        a     => a_reg,
        b     => b_reg,
        c_in  => cin_reg,
        s     => s_reg,
        c_out => cout_reg);
  end generate; 
end structure;
