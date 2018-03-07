----------------------------------------------------------------------------------
-- testbench for top module of approximate adders
--
-- input testfile location should be in the main folder of the Vivado project
-- when testing in functional implementation mode

-- output testfile will be in the same location
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all;
use IEEE.MATH_REAL.all;

library UNISIM;
use UNISIM.VComponents.all;

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is

  constant kClkPeriod : time := 6 ns;  --set clock period
  constant N          : positive := 4; --set bit width
  constant R          : positive := 2;
  constant P          : positive := 2;

  --top.vhd signals
  signal a        : std_logic_vector(N-1 downto 0);
  signal b        : std_logic_vector(N-1 downto 0);
  signal c_in     : std_logic;
  signal s        : std_logic_vector(N-1 downto 0);
  --testbench sum signal
  signal TestSum  : std_logic_vector(N-1 downto 0);
  
  signal c_out    : std_logic;
  --testbench c_out signal
  signal TestCout : std_logic;
  
  --testbench signals
  signal RegClk       : std_logic := '0';
  signal StopSim      : boolean := false;
  
  --file IO signal
  file outfile: TEXT open write_mode is "../../../../tb_output.csv";
  file infileA: TEXT open read_mode is "../../../../tb_inputA1.txt";
  file infileB: TEXT open read_mode is "../../../../tb_inputB1.txt";
  
  
  -- This procedure waits for X rising edges of RegClk
  procedure ClkWait (X : integer := 1) is
  begin
    for i in 1 to X loop
      wait until rising_edge(RegClk);
    end loop;
  end procedure ClkWait;

begin

  -- Set up the clock
  RegClk <= not RegClk after kClkPeriod/2 when not StopSim else '0';

  DUT: entity work.top (structure)
  port map (
    clk       => RegClk,
    a         => a,
    b         => b,
    c_in      => c_in,
    s         => s,
    c_out     => c_out);

    
  MainTestProc: process
  variable TestAdd : std_logic_vector(N downto 0);
  variable ApprAdd : std_logic_vector(N downto 0);
  variable inA : line; --line number
  variable inB : line; --line number
  variable outL : line; --line number
  
  --random number generator variables
  variable Seed1  : positive;
  variable Seed2  : positive;
  variable a_rand : integer;
  variable a_re   : real;
  variable b_rand : integer;
  variable b_re   : real;    
      
  begin
  
    --initialize inputs
    a       <= (others=>'0');
    b       <= (others=>'0');
    c_in    <= '0';
    TestSum <= (others=>'0');
    TestCout  <= '0';
    
    ClkWait(50);
    
    write(outL, string'("a"), right, 8);
    write(outL, string'(","));
    write(outL, string'(" b"), right, 8);
    write(outL, string'(","));
    write(outL, string'(" a-binary"), right, 18);
    write(outL, string'(","));
    write(outL, string'(" b-binary"), right, 18);
    write(outL, string'(","));
    write(outL, string'(" acc result"), right, 12);
    write(outL, string'(","));
    write(outL, string'(" appr result"), right, 12);
    write(outL, string'(","));
    write(outL, string'(" acc result binary"), right, 22);
    write(outL, string'(","));
    write(outL, string'(" appr result binary"), right, 22);
    write(outL, string'(","));
    write(outL, string'(" error"), right, 8);
    write(outL, string'(","));
    write(outL, string'(" rel error"), right, 8);
    writeline(outfile, outL);
    
    ClkWait(5);
    
    file_open(infileA, "../../../../tb_inputA1.txt", read_mode);
    --test without carry in
    for i in 0 to 2**N-1 loop
      readline(infileA, inA);
      read(inA, a_rand);
      file_open(infileB, "../../../../tb_inputB1.txt", read_mode);
      for j in 0 to 2**N-1 loop
        readline(infileB, inB);
        read(inB, b_rand);
        a <= std_logic_vector(to_unsigned(a_rand,N));
        b <= std_logic_vector(to_unsigned(b_rand,N));
        c_in  <= '0';
        ClkWait(2);
        TestAdd := std_logic_vector(('0' & unsigned(a)) + ('0' & unsigned(b)) +  (unsigned'("" & c_in)));
        TestSum <= TestAdd(N-1 downto 0);
        TestCout  <= TestAdd(N);
        ApprAdd := c_out & s;
        ClkWait(2);
        write(outL, integer'image(to_integer(unsigned(a))), right, 8);
        write(outL, string'(","));
        write(outL, integer'image(to_integer(unsigned(b))), right, 8);
        write(outL, string'(","));
        write(outL, a, right, 18);
        write(outL, string'(","));
        write(outL, b, right, 18);
        write(outL, string'(","));
        write(outL, integer'image(to_integer(unsigned(TestAdd))), right, 12);
        write(outL, string'(","));
        write(outL, integer'image(to_integer(unsigned(ApprAdd))), right, 12);
        write(outL, string'(","));
        write(outL, TestAdd, right, 22);
        write(outL, string'(","));
        write(outL, ApprAdd, right, 22);
        write(outL, string'(","));
        writeline(outfile, outL);
        
        -- uncomment this part to receive error report on the console for every inaccurate result
        --assert s = TestSum
        --   report "Incorrect value " & integer'image(to_integer(unsigned(s))) & " read from Sum register instead of " & integer'image(to_integer(unsigned(TestSum))) & "!"
        --   severity error;
        --assert c_out = TestCout
        --   report "Incorrect value read from C_out register!"
        --   severity error;
      end loop;
    file_close(infileB);
    end loop;
  file_close(infileA);
  
    ClkWait(5);
    
    --initialize inputs
    a       <= (others=>'0');
    b       <= (others=>'0');
    c_in    <= '0';
    TestSum <= (others=>'0');
    TestCout  <= '0';
    
    ClkWait(5);
    
    file_open(infileA, "../../../../tb_inputA1.txt", read_mode);
    --test with carry in
    for i in 0 to 2**N-1 loop
      readline(infileA, inA);
      file_open(infileB, "../../../../tb_inputB1.txt", read_mode);
      for j in 0 to 2**N-1 loop
        readline(infileB, inB);
        read(inB, b_rand);
        a <= std_logic_vector(to_unsigned(a_rand,N));
        b <= std_logic_vector(to_unsigned(b_rand,N));
        c_in  <= '1';
        ClkWait(2);
        TestAdd := std_logic_vector(('0' & unsigned(a)) + ('0' & unsigned(b)) +  (unsigned'("" & c_in)));
        TestSum <= TestAdd(N-1 downto 0);
        TestCout  <= TestAdd(N);
        ApprAdd := c_out & s;
        ClkWait(2);
        write(outL, integer'image(to_integer(unsigned(a))), right, 8);
        write(outL, string'(","));
        write(outL, integer'image(to_integer(unsigned(b))), right, 8);
        write(outL, string'(","));
        write(outL, a, right, 18);
        write(outL, string'(","));
        write(outL, b, right, 18);
        write(outL, string'(","));
        write(outL, integer'image(to_integer(unsigned(TestAdd))), right, 12);
        write(outL, string'(","));
        write(outL, integer'image(to_integer(unsigned(ApprAdd))), right, 12);
        write(outL, string'(","));
        write(outL, TestAdd, right, 22);
        write(outL, string'(","));
        write(outL, ApprAdd, right, 22);
        write(outL, string'(","));
        writeline(outfile, outL);
        
        -- uncomment this part to receive error report on the console for every inaccurate result
        --assert s = TestSum
        --   report "Incorrect value " & integer'image(to_integer(unsigned(s))) & " read from Sum register instead of " & integer'image(to_integer(unsigned(TestSum))) & "!"
        --   severity error;
        --assert c_out = TestCout
        --   report "Incorrect value read from C_out register!"
        --   severity error;
      end loop;
    file_close(infileB);
    end loop;
  file_close(infileA);
            
    ClkWait(20);
    
    StopSim <= true;
    
    wait;
  end process;

end Behavioral;
