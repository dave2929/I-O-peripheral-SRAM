library ieee;
use ieee.std_logic_1164.all; 

entity sram_ctrl is 
	port
	(
		clk, reset :  in  std_logic; 
        -- to/from main system
		sram_ctrl :  in  std_logic_vector(1 downto 0);
		we_n, oe_n, tri_n:  out  std_logic 
        -- SRAM chip a
	);
end sram_ctrl;

architecture arch of sram_ctrl is 
   type state_type is (idle , rd1 , rd2 , wr1 , wr2);
   signal	state_reg, state_next :  state_type;
   signal	we_buf, oe_buf, tri_buf :  std_logic;
   signal	we_reg, oe_reg, tri_reg :  std_logic;
   
begin 
   -- state & data registers
   process (clk,reset)
   begin
      if (reset='1') then
         state_reg <= idle;
         tri_reg <= '1';
         we_reg <= '1';
         oe_reg <= '1';
      elsif (clk'event and clk='1') then
         state_reg <= state_next;
         tri_reg <= tri_buf;
         we_reg <= we_buf;
         oe_reg <= oe_buf;
      end if;
   end process; 
   -- next-state logic
   process (state_reg, sram_ctrl)
   begin
      case state_reg is
         when idle =>
            if (sram_ctrl(1) = '0' and sram_ctrl(0) = '0') then
               state_next <= idle;
            else
               if sram_ctrl(1) = '0' then --write
                  state_next <= wr1; 
               else -- read
                  state_next <= rd1;
               end if;
            end if;
         when wr1 =>
            state_next <= wr2;
         when wr2 =>
            state_next <= idle;
         when rd1 =>
            state_next <= rd2;
         when rd2 =>
            state_next <= idle;
      end case;
   end process; 
   -- "look-ahead" output logic
   process (state_next)
   begin
      tri_buf <= '1'; -- default
      we_buf <= '1';
      oe_buf <= '1';
      case state_next is
         when idle =>
         when wr1 =>
            tri_buf <= '0';
            we_buf <= '0';
         when wr2 =>
            tri_buf <= '0';
         when rd1 =>
            oe_buf <= '0';
         when rd2 =>
            oe_buf <= '0';
      end case;
   end process;
   -- to SRAM
   we_n <= we_reg;
   oe_n <= oe_reg;
   tri_n <= tri_reg;   
   -- i/o for SRAM chip a
end arch;