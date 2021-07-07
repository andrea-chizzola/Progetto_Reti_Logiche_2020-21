library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath is
    Port ( i_clk : in std_logic;
           i_rst : in std_logic; 
           i_data : in std_logic_vector(7 downto 0);
           o_data : out std_logic_vector (7 downto 0);
           r1_load : in std_logic; 
           r2_sel : in std_logic; 
           r2_load : in std_logic;  
           r3_sel : in std_logic;
           r3_load : in std_logic; 
           r4_load : in std_logic; 
           r5_sel : in std_logic; 
           r5_load : in std_logic;   
           r6_sel : in std_logic; 
           r6_load : in std_logic;
           r7_sel : in std_logic;
           r7_load : in std_logic;
           r8_load : in std_logic;       
           r9_load : in std_logic;           
           r10_load : in std_logic;           
           r11_load : in std_logic;           
           r12_load : in std_logic;           
           r13_load : in std_logic;           
           r14_load : in std_logic;
           d_sel : in std_logic;
           o_finish : out std_logic;
           o_end : out std_logic;
           o_address : out std_logic_vector (15 downto 0));
    
end datapath;

architecture Behavioral of datapath is
signal o_reg1 : std_logic_vector (7 downto 0);
signal o_reg2 : std_logic_vector (7 downto 0);
signal o_reg3 : std_logic_vector (7 downto 0);
signal o_reg4 : std_logic_vector (7 downto 0);
signal o_reg5 : std_logic_vector (15 downto 0);
signal o_reg6 : std_logic_vector (7 downto 0);
signal o_reg7 : std_logic_vector (15 downto 0);
signal o_reg8 : std_logic_vector (15 downto 0);
signal o_reg9 : std_logic_vector (7 downto 0);
signal o_reg10 : std_logic_vector (7 downto 0);
signal o_reg11 : std_logic_vector (7 downto 0);
signal o_reg12 : std_logic_vector (15 downto 0);
signal o_reg13 : std_logic_vector (15 downto 0);
signal o_reg14 : std_logic_vector (7 downto 0);

signal mux_reg2 : std_logic_vector(7 downto 0);
signal mux_reg3 : std_logic_vector(7 downto 0);
signal mux_reg5 : std_logic_vector(15 downto 0);
signal mux_reg6 : std_logic_vector(7 downto 0);
signal mux_reg7 : std_logic_vector(15 downto 0);

signal max : std_logic_vector(7 downto 0);
signal min : std_logic_vector(7 downto 0);
signal delta : std_logic_vector(7 downto 0);
signal floor : std_logic_vector(7 downto 0);
signal floor_8 : std_logic_vector(7 downto 0);
signal curr_delta : std_logic_vector(7 downto 0);
signal shift : std_logic_vector(15 downto 0);
signal final : std_logic_vector(7 downto 0);
------------------------------------------------------
signal totpixel : std_logic_vector(15 downto 0);
signal sub : std_logic_vector(7 downto 0);
signal cont : std_logic_vector(15 downto 0);
signal firstout : std_logic_vector(15 downto 0);
begin 

--circuito reset reg1
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg1 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r1_load = '1') then
                o_reg1 <= i_data;
            end if;
        end if;
    end process;

--process per trovare max e min   
    process(o_reg1, o_reg2)
    begin
        if(o_reg2 >= o_reg1) then
            max <= o_reg2;
        else
            max <= o_reg1;
        end if;
    end process;
    
    process(o_reg1, o_reg3 )
    begin
        if(o_reg3 <= o_reg1) then
            min <= o_reg3;
        else
            min <= o_reg1;
        end if;
    end process;
    
--multiplexer reg2        
    with r2_sel select
        mux_reg2 <= i_data when '0',
                    max when '1',
                    "XXXXXXXX" when others; 

--circuito reset reg2                    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg2 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r2_load = '1') then
                o_reg2 <= mux_reg2;
            end if;
        end if;
    end process;                

--multiplexer reg3
    with r3_sel select
        mux_reg3 <= min when '0',
                    i_data when '1',
                    "XXXXXXXX" when others;

--circuito reset reg3    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg3 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r3_load = '1') then
                o_reg3 <= mux_reg3;
            end if;
        end if;
    end process;

--DELTA_VALUE = MAX_PIXEL_VALUE – MIN_PIXEL_VALUE  
    delta <= o_reg2 - o_reg3;
        
--circuito reset reg9                    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg9 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r9_load = '1') then
                o_reg9 <= delta;
            end if;
        end if;
    end process; 
 
 --FLOOR(LOG2(DELTA_VALUE +1))
    process (i_clk, o_reg9) 
    begin
       if(to_integer(unsigned(o_reg9)) = 0) then
           floor <= "00000000";
       elsif(to_integer(unsigned(o_reg9)) > 0 and to_integer(unsigned(o_reg9)) < 3) then
           floor <= "00000001";
       elsif(to_integer(unsigned(o_reg9)) > 2 and to_integer(unsigned(o_reg9)) < 7) then
           floor <= "00000010";
       elsif(to_integer(unsigned(o_reg9)) > 6 and to_integer(unsigned(o_reg9)) < 15) then
           floor <= "00000011";
       elsif(to_integer(unsigned(o_reg9)) > 14 and to_integer(unsigned(o_reg9)) < 31) then
           floor <= "00000100";
       elsif(to_integer(unsigned(o_reg9)) > 30 and to_integer(unsigned(o_reg9)) < 63) then
           floor <= "00000101";
       elsif(to_integer(unsigned(o_reg9)) > 62 and to_integer(unsigned(o_reg9)) < 127) then
           floor <= "00000110";
       elsif(to_integer(unsigned(o_reg9)) > 126 and to_integer(unsigned(o_reg9)) < 255) then
           floor <= "00000111";  
       elsif(to_integer(unsigned(o_reg9)) = 255) then
           floor <= "00001000"; 
       else 
           floor <= "XXXXXXXX"; 
       end if;       
    end process;   
 
--circuito reset reg10
    process(i_clk, i_rst)
       begin
           if(i_rst = '1') then
               o_reg10 <= "00000000";
           elsif rising_edge(i_clk) then
               if(r10_load = '1') then
                   o_reg10 <= floor;
               end if;
           end if;
       end process;   
    
 --SHIFT_LEVEL = (8 – FLOOR(LOG2(DELTA_VALUE +1)))
    floor_8 <= "00001000" - o_reg10; 
    
--circuito reset reg11
    process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                o_reg11 <= "00000000";
            elsif rising_edge(i_clk) then
                if(r11_load = '1') then
                    o_reg11 <= floor_8;
                end if;
            end if;
        end process;                                                             

--CURRENT_PIXEL_VALUE - MIN_PIXEL_VALUE    
    curr_delta <= o_reg1 - o_reg3;
                              
--circuito reset reg12
    process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                o_reg12 <= "0000000000000000";
            elsif rising_edge(i_clk) then
                if(r12_load = '1') then
                    o_reg12 <= "00000000" & curr_delta;
                end if;
            end if;
        end process; 
        
 --TEMP_PIXEL = (CURRENT_PIXEL_VALUE - MIN_PIXEL_VALUE) << SHIFT_LEVEL                             
    process(o_reg12, o_reg11)
    begin           
        shift <= std_logic_vector(unsigned(o_reg12) sll to_integer(unsigned(o_reg11)));
    end process;
    
--circuito reset reg13     
    process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                o_reg13 <= "0000000000000000";
            elsif rising_edge(i_clk) then
                if(r13_load = '1') then
                    o_reg13 <= shift;
                end if;
            end if;
        end process; 
        
--NEW_PIXEL_VALUE = MIN( 255 , TEMP_PIXEL)
    process(o_reg13)
    begin
        if(o_reg13 < "0000000011111111") then
            final <= o_reg13(7 downto 0);
          else 
            final <= "11111111";
        end if;
    end process;

--circuito reset reg14
    process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                o_reg14 <= "00000000";
            elsif rising_edge(i_clk) then
                if(r14_load = '1') then
                    o_reg14 <= final;
                end if;
            end if;
        end process; 
        
--scrittura NEW_PIXEL_VALUE in memoria        
    o_data <= o_reg14;
    
--circuito reset reg4
    process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                o_reg4 <= "00000000";
            elsif rising_edge(i_clk) then
                if(r4_load = '1') then
                    o_reg4 <= i_data;
                end if;
            end if;
        end process;  
        
--calcolo indirizzo ultimo pixel    
    totpixel <= ("00000000" & o_reg4) + o_reg5;
        
--multiplexer reg5
    with r5_sel select
            mux_reg5 <= "0000000000000000" when '0',
                        totpixel when '1',
                        "XXXXXXXXXXXXXXXX" when others;     
                        
--circuito reset reg5
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg5 <= "0000000000000000";
        elsif rising_edge(i_clk) then
            if(r5_load = '1') then
                o_reg5 <= mux_reg5;
            end if;
        end if;
    end process;  
    
--multiplexer reg6
    with r6_sel select
        mux_reg6 <= i_data when '0',
                    sub when '1',
                    "XXXXXXXX" when others;
                    
--circuito reset reg6
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg6 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r6_load = '1') then
                o_reg6 <= mux_reg6;
            end if;
        end if;
    end process; 
    
--decremento numero righe   
    sub <= o_reg6 - "00000001";
    
--multiplexer reg7
    with r7_sel select
        mux_reg7 <= "0000000000000000" when '0',
                    cont when '1',
                    "XXXXXXXXXXXXXXXX" when others;
                    
--circuito reset reg7
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg7 <= "0000000000000000";
        elsif rising_edge(i_clk) then
            if(r7_load = '1') then
                o_reg7 <= mux_reg7;
            end if;
        end if;
    end process;  
    
--incrementa indirizzo
    cont <= o_reg7 + "0000000000000001";
                   
--circuito reset reg8      
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg8 <= "0000000000000000";
        elsif rising_edge(i_clk) then
            if(r8_load = '1') then
                o_reg8 <= firstout;
            end if;
        end if;
    end process;   
    
--genera indirizzo di scrittura
    firstout <= o_reg5 + cont;
    
--seleziona indirizzo lettura/scrittura
    with d_sel select
        o_address <= o_reg8 when '0',
                     o_reg7 when '1',
                     "XXXXXXXXXXXXXXXX" when others;   
                  
--segnali comparatori
    o_finish <= '1' when (o_reg7 - o_reg5 = "0000000000000001") else '0';
    o_end <= '1' when (o_reg4 = "00000000" or o_reg6 = "00000000") else '0';

    
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

               
entity project_reti_logiche is
  Port ( 
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
  );

end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component datapath is
    Port ( i_clk : in std_logic;
           i_rst : in std_logic; 
           i_data : in std_logic_vector(7 downto 0);
           o_data : out std_logic_vector (7 downto 0);
           o_address : out std_logic_vector(15 downto 0);
           r1_load : in std_logic; 
           r2_sel : in std_logic; 
           r2_load : in std_logic;  
           r3_sel : in std_logic;
           r3_load : in std_logic; 
           r4_load : in std_logic; 
           r5_sel : in std_logic; 
           r5_load : in std_logic;   
           r6_sel : in std_logic; 
           r6_load : in std_logic;
           r7_sel : in std_logic;
           r7_load : in std_logic;           
           r8_load : in std_logic;          
           r9_load : in std_logic;           
           r10_load : in std_logic;           
           r11_load : in std_logic;           
           r12_load : in std_logic;           
           r13_load : in std_logic;           
           r14_load : in std_logic;
           d_sel : in std_logic;           
           o_finish : out std_logic;
           o_end : out std_logic);
           
end component; 

signal r1_load : std_logic; 
signal r2_sel : std_logic; 
signal r2_load : std_logic;  
signal r3_sel : std_logic;
signal r3_load : std_logic;
signal r4_load : std_logic; 
signal r5_sel : std_logic; 
signal r5_load : std_logic;   
signal r6_sel : std_logic; 
signal r6_load : std_logic;
signal r7_sel : std_logic;
signal r7_load : std_logic;
signal r8_load : std_logic;
signal r9_load : std_logic;
signal r10_load : std_logic;
signal r11_load : std_logic;
signal r12_load : std_logic;
signal r13_load : std_logic;
signal r14_load : std_logic;
signal d_sel : std_logic;
signal o_finish : std_logic;
signal o_end : std_logic;
type S is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,S17,S18,S19,S20,S21,S22,S23,S24,S25,S26);
signal cur_state, next_state : S;


begin
    DATAPATH0 : datapath port map(
           i_clk,
           i_rst, 
           i_data,
           o_data,
           o_address,
           r1_load,
           r2_sel, 
           r2_load,  
           r3_sel,
           r3_load, 
           r4_load, 
           r5_sel, 
           r5_load,   
           r6_sel, 
           r6_load,
           r7_sel,
           r7_load,          
           r8_load,          
           r9_load,           
           r10_load,          
           r11_load,           
           r12_load,
           r13_load,           
           r14_load,
           d_sel,
           o_finish,
           o_end
     );  
     
     process (i_clk, i_rst)
     begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif rising_edge(i_clk) then
            cur_state <= next_state;
        end if;
     end process;
     
     process (cur_state, i_start, o_finish, o_end)
     begin
        next_state <= cur_state;
        case cur_state is       
            when S0 => 
                if i_start = '1' then
                    next_state <= S1;      
                end if;
            when S1 => 
                next_state <= S2;
            when S2 => 
                next_state <= S3;
            when S3 => 
                next_state <= S4;
            when S4 =>
                if o_end = '1' then 
                    next_state <= S25;
                else
                    next_state <= S5;
                end if;
            when S5 => 
                next_state <= S6;
            when S6 =>
                if o_end = '1' then 
                    next_state <= S25;
                else
                    next_state <= S7;
                end if;
            when S7 =>
                if o_end = '0' then 
                    next_state <= S7;
                else
                    next_state <= S8;
                end if;
            when S8 =>
                next_state <= S9;
            when S9 => 
                next_state <= S10;
            when S10 =>
                next_state <= S11;
            when S11 => 
                if o_finish = '0' then 
                    next_state <= S12;
                else
                    next_state <= S15;
                end if;
            when S12 =>
                next_state <= S13;
            when S13 =>
                next_state <= S14;
            when S14 =>
                next_state <= S11;
            when S15 =>
                next_state <= S16;
            when S16 =>
                next_state <= S17;
            when S17 =>
                next_state <= S18;
            when S18 =>
                next_state <= S19;
            when S19 =>
                next_state <= S20;
            when S20 =>
                next_state <= S21;
            when S21 =>
                next_state <= S22;
            when S22 =>
                next_state <= S23;
            when S23 =>
                next_state <= S24;
            when S24 =>
                if o_finish = '0' then 
                    next_state <= S18;
                else
                    next_state <= S25;
                end if;
            when S25 => 
                if i_start = '1' then
                    next_state <= S25;
                else 
                    next_state <= S26;
                end if;    
            when S26 =>
                next_state <= S0;
        end case;
    end process;
    
    process(cur_state)
    begin
        r1_load <= '0';
        r2_sel <= '0';
        r2_load <= '0';
        r3_sel <= '1';
        r3_load <= '0';
        r4_load <= '0';
        r5_sel <= '0';
        r5_load <= '0';
        r6_sel <= '0';
        r6_load <= '0';
        r7_sel <= '0';
        r7_load <= '0';        
        r8_load <= '0';
        r9_load <= '0';
        r10_load <= '0';
        r11_load <= '0';
        r12_load <= '0';
        r13_load <= '0';
        r14_load <= '0';
        d_sel <= '1';
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        case cur_state is
            when S0 =>
            when S1 =>
                r7_sel <= '0';
                r7_load <= '1';
            when S2 =>
                o_en <= '1';
                d_sel <= '1';
            when S3 =>
                r4_load <= '1';
                r5_sel <= '0';
                r5_load <= '1';
                r6_sel <= '0';
                r6_load <= '1';
                r7_sel <= '1';
                r7_load <= '1';
            when S4 =>
                o_en <= '1';
                d_sel <= '1';
            when S5 =>
                r6_sel <= '0';
                r6_load <= '1';
            when S6 =>
                r6_sel <= '1';
                r6_load <= '1';
            when S7 =>
                r5_sel <= '1';
                r5_load <= '1';
                r6_sel <= '1';
                r6_load <= '1';
            when S8 =>
                r7_sel <= '1';
                r7_load <= '1';
            when S9 =>
                o_en <= '1';
                d_sel <= '1';
            when S10 =>
                r2_sel <= '0';
                r2_load <= '1';
                r3_sel <= '1';
                r3_load <= '1';
            when S11 =>
                r7_sel <= '1';
                r7_load <= '1';
            when S12 =>
                o_en <= '1';
                d_sel <= '1';
            when S13 =>
                r1_load <= '1';
            when S14 =>
                r2_sel <= '1';
                r2_load <= '1';
                r3_sel <= '0';
                r3_load <= '1';
            when S15 =>
                r7_sel <= '0';
                r7_load <= '1';
                r9_load <= '1';
            when S16 =>
                r10_load <= '1';    
            when S17 =>
                r7_sel <= '1';
                r7_load <= '1';
                r11_load <= '1';    
            when S18 =>
                r7_sel <= '1';
                r7_load <= '1';
                r8_load <= '1';     
            when S19 =>
                o_en <= '1';
                d_sel <= '1';
            when S20 =>
                r1_load <= '1';
            when S21 =>
                r12_load <= '1';    
            when S22 =>
                r13_load <= '1';
            when S23 =>
                r14_load <= '1';
            when S24 =>
                o_en <= '1';
                o_we <= '1';
                d_sel <= '0';               
            when S25 =>
                o_done <= '1';    
            when S26 =>
                o_done <= '0';
        end case;
end process;

end Behavioral;