library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mylib;
use mylib.defYaenamiAdc.all;

package defRayrawAdcROV1 is

  constant kNumAsicBlock  : integer:= 4;

  type AdcDataBlockArray  is array(integer range kNumAsicBlock*kNumAdcCh-1 downto 0) of AdcDataType;
  type AdcFrameBlockArray is array(integer range kNumAsicBlock-1 downto 0)           of AdcDataType;

  type TapBlockArray      is array(integer range kNumAsicBlock-1 downto 0)           of TapArray;

  function GetInvPolarity(index : integer) return std_logic_vector;
  function GetGenFlagIdelayCtrl(index : integer) return boolean;
  function GetIdelayGroup(index : integer) return string;

  function GetTapValues(index : integer) return TapArray;


end package defRayrawAdcROV1;
-- ----------------------------------------------------------------------------------
-- Package body
-- ----------------------------------------------------------------------------------
package body defRayrawAdcROV1 is

  -- GetInvPolarity -----------------------------------------------------------------
  function GetInvPolarity(index : integer) return std_logic_vector is
  begin
    case index is
      when 0 => return("011100111");
      when 1 => return("001101110");
      when 2 => return("001110011");
      when 3 => return("110010000");
      when others => return("000000000");

    end case;
  end GetInvPolarity;


  -- GetGenFlagIdelayCtrl -----------------------------------------------------------
  function GetGenFlagIdelayCtrl(index : integer) return boolean is
    variable result : boolean;
  begin
    if (index = 0 or index = 2) then
      result  := true;
    else
      result  := false;
    end if;

    return result;

  end GetGenFlagIdelayCtrl;

  -- GetIdelayGroup -----------------------------------------------------------------
  function GetIdelayGroup(index : integer) return string is
  begin
    if (index = 0 or index = 1) then
      return("idelay_0");
    else
      return("idelay_1");
    end if;

  end GetIdelayGroup;

-- GetTapValues ---------------------------------------------------------------------
  function GetTapValues(index : integer) return TapArray is
  begin
    if (index = 0)  then
      return("00011", "00001", "00001", "00001", "00001", "00001", "00001", "00001", "00001");
    elsif (index = 1)  then
      return("00011", "00001", "00001", "00001", "00001", "00001", "00001", "00001", "00001");
    elsif (index = 2)  then
      return("00011", "00001", "00001", "00001", "00001", "00001", "00001", "00001", "00001");
    else
      return("00011", "00001", "00001", "00001", "00001", "00001", "00001", "00001", "00001");
    end if;

  end GetTapValues;


end package body defRayrawAdcROV1;
