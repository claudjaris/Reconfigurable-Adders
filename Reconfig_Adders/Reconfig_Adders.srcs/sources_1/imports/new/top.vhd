----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity top is

    Port ( a          : in std_logic_vector(7 downto 0);
           s          : out std_logic_vector(7 downto 0));
end top;

architecture structure of top is

  component RCA_Adder
    port( a,b: in std_logic_vector(7 downto 0);
          c_in: in std_logic;
          s: out std_logic_vector(7 downto 0);
          c_out: out std_logic);
  end component;

  signal a_reg : std_logic_vector(7 downto 0) := (others => '0');
  signal b_reg : std_logic_vector(7 downto 0) := (others => '0');
  signal s_reg : std_logic_vector(7 downto 0) := (others => '0');
  signal s_g   : std_logic_vector(7 downto 0) := (others => '0');
  signal cin_reg  : std_logic := '0';
  signal cout_reg : std_logic := '0';
  signal cout_g   : std_logic := '0';

begin

      a_reg   <= a;
      b_reg   <= a;
                  
      cin_reg <= a(0);
      s_g      <= s_reg;
      cout_g  <= cout_reg;
  
  s(7)  <= cout_g xor s_g(7);
  s(6 downto 0) <= s_g(6 downto 0);

  ----------------------------Adder types----------------------------
  
  ReConfig: RCA_Adder port map(
    a     => a_reg,
    b     => b_reg,
    c_in  => cin_reg,
    s     => s_reg,
    c_out => cout_reg
  );
 
end structure;
