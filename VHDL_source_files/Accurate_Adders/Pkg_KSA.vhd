----------------------------------------------------------------------------------
-- functional package for logarithmic and division functions
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


package Pkg_KSA is

  function log2ceil(arg : positive) return natural;     --base 2 logarithm function
  function halfceil(arg : positive) return natural;     --division by 2 with round up
  function quarterceil(arg : positive) return natural;  --division by 4 with round up
  function thirdfloor(arg : positive) return natural;
  function twelffloor(arg : positive) return natural;
  function divisionfloor(arg, div : positive) return natural;  --division of arg by div

end Pkg_KSA;

package body Pkg_KSA is

  function log2ceil(arg : positive) return natural is
      variable tmp : positive;
      variable log : natural;
    begin
      if arg = 1 then return 0; end if;
        tmp := 1;
        log := 0;
        while arg > tmp loop
          tmp := tmp * 2;
          log := log + 1;
        end loop;
      return log;
  end function;
  
  function halfceil(arg : positive) return natural is
      variable log : positive;
    begin
      if arg <= 1 then return 1; end if;
        log := arg/2;
      return log;
  end function;
  
  function quarterceil(arg : positive) return natural is
    variable tmp : positive;
    variable quarter : natural;
    begin
      if arg < 4 then return 1; end if;
      tmp := 4;
      quarter := 1;
      while arg > tmp loop
        tmp := tmp +4;
        quarter := quarter + 1;
      end loop;
    return quarter;
  end function;   
  
  function thirdfloor(arg : positive) return natural is
      variable tmp    : positive;
      variable third  : natural;
    begin
      if arg <= 3 then return 0; end if;
        tmp   := 3;
        third := 0;
        while arg > tmp loop
          tmp := tmp + 3;
          third := third + 1;
        end loop;
      return third;
  end function;
  
  function twelffloor(arg : positive) return natural is
      variable tmp    : positive;
      variable val  : natural;
    begin
      if arg < 4 then return 0; end if;
        tmp   := 4;
        val := 0;
        while arg > tmp loop
          tmp := tmp + 4;
          val := val + 1;
        end loop;
      return val;
  end function;
 
  function divisionfloor(arg, div : positive) return natural is
      variable tmp : positive;
      variable result : natural;
      begin
        if arg < div then return 0; end if;
        tmp := div;
        result := 0;
        while arg >= tmp loop
          tmp := tmp + div;
          result := result + 1;
        end loop;
      return result;
    end function;   

end package body;
