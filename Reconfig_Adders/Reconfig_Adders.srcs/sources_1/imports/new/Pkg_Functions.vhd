----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Pkg_Functions is

  type my_array_t is array(natural range<>) of natural;

  function log2ceil(arg : positive) return natural; --logarithm of 2 with round up
  function halfceil(arg : positive) return natural; --division by 2 with round up
  function thirdfloor(arg : positive) return natural; --division by 3 with round down
  function quarterceil(arg : positive) return natural;  --division by 4 with round up
  function twelffloor(arg : positive) return natural; --division by 12 with round down
  function divisionceil(arg, div : positive) return natural;  --division of arg by div
  function array_sum(arr : my_array_t; K : positive) return my_array_t; --sum up the contents of 1 array
  function array_add(arr1, arr2 : my_array_t; K : positive) return my_array_t; --add the contents of 2 array fields
  function array_quarter(arr : my_array_t; K : positive) return my_array_t;  --floor division by 4
  
end Pkg_Functions;

package body Pkg_Functions is

  function array_sum(arr : my_array_t; K : positive) return my_array_t is
    variable tmp : natural;
    variable sum : natural;
    variable arr_sum : my_array_t(0 to K-1);
    begin
      tmp := 0;
      sum := 0;
      while tmp < K loop
        sum := sum + arr(tmp);
        arr_sum(tmp) := sum;
        tmp := tmp + 1;
      end loop;
    return arr_sum;
  end function;
  
  function array_add(arr1, arr2 : my_array_t; K : positive) return my_array_t is
    variable i : natural;
    variable arr_add : my_array_t(0 to K-1);
    begin
      i := 0;
      while i < K loop
        arr_add(i) := arr1(i) + arr2(i);
        i := i + 1;
      end loop;
    return arr_add;
  end function;  
  
  function array_quarter(arr : my_array_t; K : positive) return my_array_t is
    variable i : natural;
    variable tmp : natural;
    variable sum_i : my_array_t(0 to K-1);
    variable arr_quarter : my_array_t(0 to K-1);
    begin
      i := 0;
      tmp := 0;
      sum_i := arr;
      while i < K loop
        while sum_i(i) > 4 loop
          sum_i(i) := sum_i(i) - 4;
          tmp := tmp + 1;
        end loop;
        arr_quarter(i) := tmp;
        i := i + 1;
        tmp := 0;
      end loop;
    return arr_quarter;
  end function;  

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
  
  function divisionceil(arg, div : positive) return natural is
      variable tmp : positive;
      variable result : natural;
      begin
        if arg < div then return 1; end if;
        tmp := div;
        result := 1;
        while arg > tmp loop
          tmp := tmp + div;
          result := result + 1;
        end loop;
      return result;
    end function;  
  
end package body;
