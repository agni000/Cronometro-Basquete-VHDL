-------------------------------------------------------------------------------
-- Company: UFSC
-- Designer: Ney Calazans
-- 
-- Create Date:		17.11.2024 10:51:00
-- Last changed: 	08/05/2025
--
-- Design Name: any
-- Module Name: Debounce - Debounce
-- Target Devices: Nexys 1/2 
--			(FPGA Spartan 3 xc3s200-4ft256/3E xc3s1200e-4fg320)
-- 			Tool Versions: ISE 14.7
-- 			Description: This is the module that adapts push-button pressing in human
--				temporal scale to the electronic time scale of the board/FPGA.
--				When pressig the button internally the module produces a single pulse
--				with the duration of exactly one clock period. Long pressing the
--				button produces an autor repeat effect, similar to what happens in
--				conventional computer keyboards.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity Debounce is          
  generic(DIVISION_RATE: integer := 4_000_000); 
  -- This is the computed value for button work if the clock is a 50MHz one
  port(clock: in STD_LOGIC;
       reset: in STD_LOGIC;
	   -- Atenttion: reset polarity changed to a high active signal
       key: in STD_LOGIC;
       debkey: out STD_LOGIC);
end Debounce;

architecture Debounce of Debounce is
  type State_type is (S1, S2, S3, S4, S5, S6, S7, S8);
  signal EA, EADiv: State_type;
  signal clockLento: STD_LOGIC:='0'; 
  -- Remember, initialization values are merally for simulation,
  --	it is ignored by the synthesis!!
begin
  process(reset, clock)
  begin
    if(clock'event and clock='0') then    
	-- This FSM is sensitive to the falling edge of the clock
      if(reset='1') then
        EA <= S1;
      else  
        case EA is
             when S1 =>  if(key='1') then   EA <= S2;  end if;
             when S2 =>  EA <= S3;
             when S3 =>  if(clockLento='1') then EA <= S4;  end if;
             when S4 =>  if(clockLento='0') then EA <= S5;  end if;
             when S5 =>  if(clockLento='1') then EA <= S6;  end if;
             when S6 =>  if(clockLento='0') then EA <= S7;  end if;
             when S7 =>  if(clockLento='1') then EA <= S8;  end if;
				 when S8 =>  if(clockLento='0') then EA <= S1;  end if;		   
        end case;
      end if;
    end if;
  end process;

-- The debkey debounce output is active-high (remember to check how buttons
--	of the target board work). Also, check how the design specifies button
--	polarities
    debkey <= '1' when (EA=S2) else '0';
	 
-- This is an input clock divisor to produce a slow clock lento,
--	based on the DIVISION_RATE parameter

  process (reset, clock)
  variable count: integer;
  begin
    if(clock'event and clock='1') then
	  -- This FSM is sensitive to the rising edge of the external clock
      if(reset='1') then
        EADiv <= S1;
        clockLento <= '0';
      else    
        case EADiv is
             when S1 => count := 0;
                        EADiv <= S2;
             when others =>
                  if(count<DIVISION_RATE) then 
                    count := count + 1; 
                    EADiv <= S2;  
                  else  
                    EADiv <= S1;  
                    clockLento <= NOT(clockLento);
                  end if;
        end case;
      end if;
    end if;
  end process;

end Debounce;						