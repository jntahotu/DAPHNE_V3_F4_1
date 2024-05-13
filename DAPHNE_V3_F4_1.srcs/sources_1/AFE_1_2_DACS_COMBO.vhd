
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/9/2024 18:43:10 PM
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- ----------------------------------------------------------------------------------
-- This firmware is made for the DAPHNE V3 to write to 4 AD5327 in a daisy chaine configuration with 2 AFE
--	chips that share sclk, sdata and sdout with 24 clock cycles. 
-- if the AD5327 is not daisy chained, change the clk_togle_len to 16, same with the data_length. 
----------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY AFE_1_2_SPI IS
  GENERIC(
    clk_togle_len: integer :=24;
	dac_data_len: integer :=32;
    data_length : INTEGER := 24);     --data length in bits
  PORT(
    clk     : IN     STD_LOGIC;                             --system clock
    reset_n : IN     STD_LOGIC;                             --asynchronous active low reset for afes
	reset_n1: in STD_LOGIC;                   -- for dacs trim and off

	chip_slector: in STD_LOGIC_VECTOR(2 downto 0);   -- this select what chip you want to talk to
 
    AFE_MISO    : IN     STD_LOGIC;                             --master in slave out for the AFEs - shared signal between them
   
    AFE1_SEN    : OUT    STD_LOGIC;                             --chip select for the afe1 
    AFE2_SEN    : OUT    STD_LOGIC;                             --chip select for the afe2
		
	AFE_1_CS_TRIM: OUT STD_LOGIC;							  -- Chip select for afe1 trim dac
	AFE_1_CS_OFF: OUT STD_LOGIC;							  -- chip select for afe1 offset dac  	
		
	AFE_2_CS_TRIM: OUT STD_LOGIC;							  -- Chip select for afe2 trim dac
	AFE_2_CS_OFF: OUT STD_LOGIC;							  -- chip select for afe2 offset dac 
		
    SDATA    : OUT    STD_LOGIC;                             --master out slave in 	shared between all 6 chips
    sclk    : OUT    STD_LOGIC;                             --spi clock --- 10MHZ    worked better durring the test	  shared btween all 6 chips
	
	AFE_1_LDACN_TRIM: OUT STD_LOGIC;
	AFE_1_LDACN_OFF: OUT STD_LOGIC;	
	
	AFE_2_LDACN_TRIM: OUT STD_LOGIC;
	AFE_2_LDACN_OFF: OUT STD_LOGIC;
	
    AFE_1_TX		: IN     STD_LOGIC_VECTOR(data_length-1 DOWNTO 0);  --data to transmit for afe 1	-- shifted register
    AFE_2_TX		: IN     STD_LOGIC_VECTOR(data_length-1 DOWNTO 0);  --data to transmit for afe 2		
		
	AFE_1_TX_TRIM: IN STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);	-- data to be transimited for the afe 1 trim dacs
	AFE_1_TX_OFF: IN STD_LOGIC_VECTOR(dac_data_len-1 DOWNTO 0);  -- data to be transimited for the afe 1 offeset dacs 
		
	AFE_2_TX_TRIM: IN STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);	-- data to be transimited for the afe 2 trim dacs
	AFE_2_TX_OFF: IN STD_LOGIC_VECTOR(dac_data_len-1 DOWNTO 0);  -- data to be transimited for the afe 2 offeset dacs 
		
	AFE_2_rx	   : OUT    STD_LOGIC_VECTOR(data_length-1 DOWNTO 0);  --data received	for afe1	
    AFE_1_rx	   : OUT    STD_LOGIC_VECTOR(data_length-1 DOWNTO 0)); --data received	for afe2  
	
END AFE_1_2_SPI;

ARCHITECTURE behavioural OF AFE_1_2_SPI IS
  TYPE FSM IS(init, execute);                           		--state machine for afe
  SIGNAL state       : FSM;                             --state machine for offset and trim dacs
  TYPE FSM1 is (init1, execute1);
  SIGNAL state1 : FSM1; 
  SIGNAL receive_transmit : STD_LOGIC;                      --'1' for tx, '0' for rx 	for AFES
  SIGNAL receive_transmit_trim_off: STD_LOGIC;   		   --'1' for tx, '0' for rx 	for DACS
  SIGNAL clk_toggles : INTEGER RANGE 0 TO clk_togle_len*2 + 1;    --clock toggle counter for AFES
  SIGNAL last_bit		: INTEGER RANGE 0 TO clk_togle_len*2;        --last bit indicator
  SIGNAL clk_toggles_trim_off : INTEGER RANGE 0 TO dac_data_len*2 + 1;    --clock toggle counter for DACS
  SIGNAL last_bit_trim_off		: INTEGER RANGE 0 TO dac_data_len*2;        --last bit indicator
  
  SIGNAL AFE_1_rxBuffer    : STD_LOGIC_VECTOR(data_length-1 DOWNTO 0) := (OTHERS => '0'); --receive data buffer	 for AFE 1
  SIGNAL AFE_2_rxBuffer    : STD_LOGIC_VECTOR(data_length-1 DOWNTO 0) := (OTHERS => '0'); --receive data buffer	 for AFE 2
  
  SIGNAL AFE_1_txBuffer    : STD_LOGIC_VECTOR(data_length-1 DOWNTO 0) := (OTHERS => '0'); --transmit afe data buffer for AFE1
  SIGNAL AFE_2_txBuffer    : STD_LOGIC_VECTOR(data_length-1 DOWNTO 0) := (OTHERS => '0'); --transmit afe data buffer for AFE2
	  
  SIGNAL AFE_1_txBuffer_trim    : STD_LOGIC_VECTOR(dac_data_len-1 DOWNTO 0) := (OTHERS => '0'); --transmit trim dacs data buffer 
  SIGNAL AFE_2_txBuffer_trim    : STD_LOGIC_VECTOR(dac_data_len-1 DOWNTO 0) := (OTHERS => '0'); --transmit trim dacs data buffer
  
  SIGNAL AFE_1_txBuffer_off   : STD_LOGIC_VECTOR(dac_data_len-1 DOWNTO 0) := (OTHERS => '0'); --transmit offeset dacs data buffer
  SIGNAL AFE_2_txBuffer_off   : STD_LOGIC_VECTOR(dac_data_len-1 DOWNTO 0) := (OTHERS => '0'); --transmit offeset dacs data buffer
  
  SIGNAL AFE_1_INT_ss_n    : STD_LOGIC;                            --Internal register for ss_n  
  SIGNAL AFE_2_INT_ss_n    : STD_LOGIC;                            --Internal register for ss_n 
	  
  SIGNAL AFE_1_INT_SS_N_TRIM: STD_LOGIC;
  SIGNAL AFE_1_INT_SS_OFF: STD_LOGIC;  
  
  SIGNAL AFE_2_INT_SS_N_TRIM: STD_LOGIC;
  SIGNAL AFE_2_INT_SS_OFF: STD_LOGIC;	
  
  SIGNAL AFE_1_INT_afe_sclk    : STD_LOGIC;                            --Internal register for sclk 
  SIGNAL AFE_1_INT_off_sclk    : STD_LOGIC;                            --Internal register for sclk 
  SIGNAL AFE_1_INT_trim_sclk    : STD_LOGIC;                            --Internal register for sclk   
	  
  SIGNAL AFE_2_INT_afe_sclk    : STD_LOGIC;                            --Internal register for sclk 
  SIGNAL AFE_2_INT_off_sclk    : STD_LOGIC;                            --Internal register for sclk 
  SIGNAL AFE_2_INT_trim_sclk    : STD_LOGIC;                            --Internal register for sclk  
	  
	  -- spi protocal enable and mode selection	  
	  
  SIGNAL enable    : STD_LOGIC;
  SIGNAL cpha    : STD_LOGIC;
  SIGNAL cpol    : STD_LOGIC;
  
  -- signal buffers for input and outputs
	  
  SIGNAL AFE_1_mosi_afe_buff    : STD_LOGIC;
  SIGNAL AFE_1_mosi_trim_buff    : STD_LOGIC;
  SIGNAL AFE_1_mosi_off_buff    : STD_LOGIC;  
  
  SIGNAL AFE_2_mosi_afe_buff    : STD_LOGIC;
  SIGNAL AFE_2_mosi_trim_buff    : STD_LOGIC;
  SIGNAL AFE_2_mosi_off_buff    : STD_LOGIC;
  
  SIGNAL AFE_1_sclk_off_buff    : STD_LOGIC;
  SIGNAL AFE_1_sclk_trim_buff    : STD_LOGIC;
  SIGNAL AFE_1_sclk_afe_buff    : STD_LOGIC;
  
  SIGNAL AFE_2_sclk_off_buff    : STD_LOGIC;
  SIGNAL AFE_2_sclk_trim_buff    : STD_LOGIC;
  SIGNAL AFE_2_sclk_afe_buff    : STD_LOGIC;
  
  SIGNAL AFE_1_ldacn_trim_buff: STD_LOGIC;
  SIGNAL AFE_1_ldacn_off_buff: STD_LOGIC;

  SIGNAL AFE_2_ldacn_trim_buff: STD_LOGIC;
  SIGNAL AFE_2_ldacn_off_buff: STD_LOGIC;
  
  SIGNAL AFE_1_CS_TRIM_BUFF : STD_LOGIC;
  SIGNAL AFE_1_CS_AFE_BUFF : STD_LOGIC;
  SIGNAL AFE_1_CS_OFF_BUFF: STD_LOGIC;
  
  SIGNAL AFE_2_CS_TRIM_BUFF : STD_LOGIC;
  SIGNAL AFE_2_CS_AFE_BUFF : STD_LOGIC;
  SIGNAL AFE_2_CS_OFF_BUFF: STD_LOGIC;	

  SIGNAL AFE_1_MISO_BUFF : STD_LOGIC;
  SIGNAL AFE_2_MISO_BUFF: STD_LOGIC;

BEGIN
	
  
  enable <= '1';   
  cpha <= '1';
  cpol <= '1'; 
  
  AFE_1_CS_AFE_BUFF <= AFE_1_INT_ss_n;
  AFE_2_CS_AFE_BUFF <= AFE_2_INT_ss_n; 
  
  AFE_1_sclk_afe_buff <= AFE_1_INT_afe_sclk; 
  AFE_2_sclk_afe_buff <= AFE_2_INT_afe_sclk; 
  
  AFE_1_CS_TRIM_BUFF <= AFE_1_INT_SS_N_TRIM;
  AFE_2_CS_TRIM_BUFF <= AFE_2_INT_SS_N_TRIM;
  
  AFE_1_sclk_trim_buff <= AFE_1_INT_trim_sclk;
  AFE_2_sclk_trim_buff <= AFE_2_INT_trim_sclk;
  
  AFE_1_CS_OFF_BUFF <= AFE_1_INT_SS_OFF;
  AFE_2_CS_OFF_BUFF <= AFE_2_INT_SS_OFF; 
  
  AFE_1_sclk_off_buff <= AFE_1_INT_off_sclk;
  AFE_2_sclk_off_buff <= AFE_2_INT_off_sclk;

  
  
  
  -- process for afe data in and out. sending 24 bits and receiving 24. FOR BOTH AFES
  
  PROCESS(clk, reset_n)
  BEGIN

    IF(reset_n = '0') THEN        --reset everything
                
      AFE_1_INT_ss_n <= '1';
	  AFE_2_INT_ss_n <= '1';
      AFE_1_rx <= (OTHERS => '0');
	  AFE_1_mosi_afe_buff <= 'Z';
	  AFE_2_rx <= (OTHERS => '0');
	  AFE_2_mosi_afe_buff <= 'Z';
      state <= init;              

    ELSIF(falling_edge(clk)) THEN
      CASE state IS               

        WHEN init =>					 -- bus is idle
  
      		AFE_1_INT_ss_n <= '1';
	 		AFE_2_INT_ss_n <= '1';
	  		AFE_1_mosi_afe_buff <= 'Z';
	  		AFE_2_mosi_afe_buff <= 'Z';            
   
          IF(enable = '1') THEN       		--initiate communication
 
                   
            AFE_1_INT_afe_sclk <= cpol;        		--set spi clock polarity   
			AFE_2_INT_afe_sclk <= cpol;    
			
            receive_transmit <= NOT cpha; --set spi clock phase	
			
            AFE_1_txBuffer <= AFE_1_TX;    				--put data to buffer to transmit 
			AFE_2_txBuffer <= AFE_2_TX;
			
            clk_toggles <= 0;        		--initiate clock toggle counter
            last_bit <= data_length*2 + conv_integer(cpha) - 1; --set last rx data bit
            state <= execute;        
          ELSE
            state <= init;          
          END IF;


        WHEN execute =>

		AFE_1_INT_ss_n <= '0';           						--pull the slave select signal down	  
		AFE_2_INT_ss_n <= '0';
			 receive_transmit <= NOT receive_transmit;   --change receive transmit mode
          
			 -- counter
			 IF(clk_toggles = clk_togle_len*2 + 1) THEN
				clk_toggles <= 0;               				--reset counter
          ELSE
				clk_toggles <= clk_toggles + 1; 				--increment counter
          END IF;
            
          -- toggle sclk
          IF(clk_toggles <= clk_togle_len*2 AND (AFE_1_INT_ss_n = '0'or AFE_2_INT_ss_n = '0')) THEN 
            AFE_1_INT_afe_sclk <= NOT AFE_1_INT_afe_sclk; --toggle spi clock  
			AFE_2_INT_afe_sclk <= NOT AFE_2_INT_afe_sclk;
          END IF;
            
          --receive 
          IF(receive_transmit = '0' AND clk_toggles < last_bit + 1 AND (AFE_1_INT_ss_n = '0'or AFE_2_INT_ss_n = '0')) THEN 
            AFE_1_rxBuffer <= AFE_1_rxBuffer(data_length-2 DOWNTO 0) & AFE_1_MISO_BUFF; 
			AFE_2_rxBuffer <= AFE_2_rxBuffer(data_length-2 DOWNTO 0) & AFE_2_MISO_BUFF; 
          END IF;
            
          --transmit 
          IF(receive_transmit = '1' AND clk_toggles < last_bit) THEN 
            AFE_1_mosi_afe_buff <= AFE_1_txBuffer(data_length-1);                    
            AFE_1_txBuffer <= AFE_1_txBuffer(data_length-2 DOWNTO 0) & '0'; 
            AFE_2_mosi_afe_buff <= AFE_2_txBuffer(data_length-1);                    
            AFE_2_txBuffer <= AFE_2_txBuffer(data_length-2 DOWNTO 0) & '0';
          END IF;
            
          --  resume the communication
          IF(clk_toggles = clk_togle_len*2 + 1) THEN   
            AFE_1_INT_ss_n <= '1';         
            AFE_1_mosi_afe_buff <= 'Z';             
            AFE_1_rx <= AFE_1_rxBuffer;
			
            AFE_2_INT_ss_n <= '1';         
            AFE_2_mosi_afe_buff <= 'Z';             
            AFE_2_rx <= AFE_2_rxBuffer;	  
			
            state <= init;          
          ELSE                       
            state <= execute;        
          END IF;
      END CASE;
    END IF;
  END PROCESS;   
  
  
  
  
  
  
  
  -- process for trim and offeset dacs data in and out. sending 32 bits not receiving any. 
-- Here we talk to to a total of 8 DACs chips 4 (2 for offeset and 2 for trim) for AFE 1 and 4 for AFE 2.  -- check with the board design again. 
  
  PROCESS(clk, reset_n1)
  BEGIN

    IF(reset_n1 = '0') THEN        --reset everything
      AFE_1_ldacn_trim_buff <='1';
	  AFE_1_ldacn_off_buff <='1';                
      AFE_1_INT_SS_N_TRIM <= '1';   
	  AFE_1_INT_SS_OFF <= '1';
      AFE_1_mosi_trim_buff <= 'Z';   
	  AFE_1_mosi_off_buff <= 'Z';

      AFE_2_ldacn_trim_buff <='1';
	  AFE_2_ldacn_off_buff <='1';                
      AFE_2_INT_SS_N_TRIM <= '1';   
	  AFE_2_INT_SS_OFF <= '1';
      AFE_2_mosi_trim_buff <= 'Z';   
	  AFE_2_mosi_off_buff <= 'Z'; 
	  
      state1 <= init1;              

    ELSIF(falling_edge(clk)) THEN
      CASE state1 IS               

        WHEN init1 =>					 -- bus is idle	
		
         AFE_1_ldacn_trim_buff <='0';
	     AFE_1_ldacn_off_buff <='0';                
         AFE_1_INT_SS_N_TRIM <= '1';   
	     AFE_1_INT_SS_OFF <= '1';
         AFE_1_mosi_trim_buff <= 'Z';   
	     AFE_1_mosi_off_buff <= 'Z'; 
		 
         AFE_2_ldacn_trim_buff <='0';
	     AFE_2_ldacn_off_buff <='0';                
         AFE_2_INT_SS_N_TRIM <= '1';   
	     AFE_2_INT_SS_OFF <= '1';
         AFE_2_mosi_trim_buff <= 'Z';   
	     AFE_2_mosi_off_buff <= 'Z';
   
          IF(enable = '1') THEN       		--initiate communication
            AFE_1_ldacn_trim_buff <= '1';  
			AFE_1_ldacn_off_buff <= '1';
			AFE_2_ldacn_trim_buff <= '1';  
			AFE_2_ldacn_off_buff <= '1';
                     
            AFE_1_INT_trim_sclk <= cpol;        		--set spi clock polarity   
			AFE_1_INT_off_sclk <= cpol;	  	 
            AFE_2_INT_trim_sclk <= cpol;        	
			AFE_2_INT_off_sclk <= cpol;
			
            receive_transmit_trim_off <= NOT cpha; --set spi clock phase	 
			
            AFE_1_txBuffer_off <= AFE_1_TX_OFF;    				--put data to buffer to transmit
			AFE_1_txBuffer_trim <= AFE_1_TX_TRIM;
            AFE_2_txBuffer_off <= AFE_1_TX_OFF;    				
			AFE_2_txBuffer_trim <= AFE_1_TX_TRIM;
						
            clk_toggles_trim_off <= 0;        		--initiate clock toggle counter
            last_bit_trim_off <= dac_data_len*2 + conv_integer(cpha) - 1; --set last rx data bit
            state1 <= execute1;        
          ELSE
            state1 <= init1;          
          END IF;


        WHEN execute1 =>
          AFE_1_ldacn_off_buff <= '1'; 
		  AFE_1_ldacn_trim_buff <= '1';
          AFE_1_INT_SS_N_TRIM <= '0';           						--pull the slave select signal down
		  AFE_1_INT_SS_OFF <= '0';
		  
          AFE_2_ldacn_off_buff <= '1'; 
		  AFE_2_ldacn_trim_buff <= '1';
          AFE_2_INT_SS_N_TRIM <= '0';           						
		  AFE_2_INT_SS_OFF <= '0'; 
		  
		  receive_transmit_trim_off <= NOT receive_transmit_trim_off;   --change receive transmit mode
          
			 -- counter
			 IF(clk_toggles_trim_off = dac_data_len*2 + 1) THEN
				clk_toggles_trim_off <= 0;               				--reset counter
          ELSE
				clk_toggles_trim_off <= clk_toggles_trim_off + 1; 				--increment counter
          END IF;
            
          -- toggle sclk
          IF(clk_toggles_trim_off <= dac_data_len*2 AND (AFE_1_INT_SS_N_TRIM OR AFE_1_INT_SS_OFF OR AFE_2_INT_SS_N_TRIM OR AFE_2_INT_SS_OFF) = '0') THEN 
            
			AFE_1_INT_off_sclk<= NOT AFE_1_INT_off_sclk; 
			AFE_1_INT_trim_sclk<= NOT AFE_1_INT_trim_sclk;  
			AFE_2_INT_off_sclk<= NOT AFE_2_INT_off_sclk; 
			AFE_2_INT_trim_sclk<= NOT AFE_2_INT_trim_sclk; 			
          END IF;
            
            
          --transmit 
          IF(receive_transmit_trim_off = '1' AND clk_toggles_trim_off < last_bit_trim_off) THEN 
            AFE_1_mosi_trim_buff <= AFE_1_txBuffer_trim(dac_data_len-1); 
			AFE_1_mosi_off_buff <= AFE_1_txBuffer_off(dac_data_len-1);
            AFE_1_txBuffer_off <= AFE_1_txBuffer_off(dac_data_len-2 DOWNTO 0) & '0'; 
			AFE_1_txBuffer_trim <= AFE_1_txBuffer_trim(dac_data_len-2 DOWNTO 0) & '0';
			
            AFE_2_mosi_trim_buff <= AFE_2_txBuffer_trim(dac_data_len-1); 
			AFE_2_mosi_off_buff <= AFE_2_txBuffer_off(dac_data_len-1);
            AFE_2_txBuffer_off <= AFE_2_txBuffer_off(dac_data_len-2 DOWNTO 0) & '0'; 
			AFE_2_txBuffer_trim <= AFE_2_txBuffer_trim(dac_data_len-2 DOWNTO 0) & '0';
          END IF;
            
          --  resume the communication
          IF(clk_toggles_trim_off = dac_data_len*2 + 1) THEN
			  
            AFE_1_ldacn_off_buff <= '0';
			AFE_1_ldacn_trim_buff <= '0';
            AFE_1_INT_SS_N_TRIM <= '1'; 
			AFE_1_INT_SS_OFF <= '1'; 
            AFE_1_mosi_trim_buff <= 'Z';             
            AFE_1_mosi_off_buff <= 'Z';
			
            AFE_2_ldacn_off_buff <= '0';
			AFE_2_ldacn_trim_buff <= '0';
            AFE_2_INT_SS_N_TRIM <= '1'; 
			AFE_2_INT_SS_OFF <= '1'; 
            AFE_2_mosi_trim_buff <= 'Z';             
            AFE_2_mosi_off_buff <= 'Z';
			
            state1 <= init1;          
          ELSE                       
            state1 <= execute1;        
          END IF;
      END CASE;
    END IF;
  END PROCESS;   
   
  
    
  process(clk)
begin
    case (chip_slector)is
        when "001"=>  
  ---- process outputs
  
  -- desired output signals for AFE 1trim dacs 
	  
			sclk <= AFE_1_sclk_trim_buff ;
			SDATA <= AFE_1_mosi_trim_buff ;
			AFE_1_LDACN_TRIM <= AFE_1_ldacn_trim_buff ;
			AFE_1_CS_TRIM <= AFE_1_CS_TRIM_BUFF  ;	
			
			-- other signals in the design are set to 1
			AFE_1_LDACN_OFF <= '1';
			AFE_1_CS_OFF <= '1';
			AFE_2_LDACN_TRIM <= '1';
			AFE_2_CS_TRIM  <= '1';
			AFE_2_LDACN_OFF <= '1';
			AFE_2_CS_OFF <= '1'; 
			AFE1_SEN <= '1';
			AFE2_SEN  <= '1';
			AFE_1_MISO_BUFF <= '0';
			AFE_2_MISO_BUFF	 <= '0';
			
		when "010"=> 
			-- desired output signals for AFE 1 offset dacs
			sclk <= AFE_1_sclk_off_buff ;
			SDATA <= AFE_1_mosi_off_buff  ;
			AFE_1_LDACN_OFF <= AFE_1_ldacn_off_buff ;
			AFE_1_CS_OFF <= AFE_1_CS_OFF_BUFF ;	
			
			-- other signals

			AFE_1_LDACN_TRIM <= '1';
			AFE_1_CS_TRIM <= '1';
			AFE_2_LDACN_TRIM <= '1';
			AFE_2_CS_TRIM  <= '1';
			AFE_2_LDACN_OFF <= '1';
			AFE_2_CS_OFF <= '1'; 
			AFE1_SEN <= '1';
			AFE2_SEN  <= '1';
			AFE_1_MISO_BUFF <= '0';
			AFE_2_MISO_BUFF	 <= '0';

        when "011"=>  
  
  
  -- desired output signals for AFE 2 trim dacs 
	  
			sclk <= AFE_2_sclk_trim_buff ;
			SDATA <= AFE_2_mosi_trim_buff ;
			AFE_2_LDACN_TRIM <= AFE_2_ldacn_trim_buff ;
			AFE_2_CS_TRIM <= AFE_2_CS_TRIM_BUFF  ;	
			
			-- other signals in the design are set to 1
			AFE_1_LDACN_OFF <= '1';
			AFE_1_CS_OFF <= '1';
			AFE_1_LDACN_TRIM <= '1';
			AFE_1_CS_TRIM  <= '1';
			AFE_2_LDACN_OFF <= '1';
			AFE_2_CS_OFF <= '1'; 
			AFE1_SEN <= '1';
			AFE2_SEN  <= '1';
			AFE_1_MISO_BUFF <= '0';
			AFE_2_MISO_BUFF	 <= '0';			


		when "100"=> 
			-- desired output signals for AFE 1 offset dacs
			sclk <= AFE_2_sclk_off_buff ;
			SDATA <= AFE_2_mosi_off_buff  ;
			AFE_2_LDACN_OFF <= AFE_2_ldacn_off_buff ;
			AFE_2_CS_OFF <= AFE_2_CS_OFF_BUFF ;	
			
			-- other signals

			AFE_1_LDACN_TRIM <= '1';
			AFE_1_CS_TRIM <= '1';
			AFE_2_LDACN_TRIM <= '1';
			AFE_2_CS_TRIM  <= '1';
			AFE_1_LDACN_OFF <= '1';
			AFE_1_CS_OFF <= '1'; 
			AFE1_SEN <= '1';
			AFE2_SEN  <= '1';
			AFE_1_MISO_BUFF <= '0';
			AFE_2_MISO_BUFF	 <= '0';
			
		when "101"=> 	
		-- desired output signals for afe1 
			
			AFE1_SEN <= AFE_1_CS_AFE_BUFF ;
			sclk <= AFE_1_sclk_afe_buff  ;
			SDATA <= AFE_1_mosi_afe_buff  ;
			AFE_1_MISO_BUFF <= AFE_MISO	 ;
			
			-- other signals 
			AFE_1_LDACN_TRIM <= '1' ;
			AFE_1_CS_TRIM <= '1'  ;	
			AFE_1_LDACN_OFF <= '1';
			AFE_1_CS_OFF <= '1';
			AFE_2_LDACN_TRIM <= '1';
			AFE_2_CS_TRIM  <= '1';
			AFE_2_LDACN_OFF <= '1';
			AFE_2_CS_OFF <= '1'; 
			AFE2_SEN  <= '1';
			AFE_2_MISO_BUFF	 <= '0';			
			
		when "110"=> 	
		-- desired output signals	for afe2 
			
			AFE2_SEN <= AFE_2_CS_AFE_BUFF ;
			sclk <= AFE_2_sclk_afe_buff  ;
			SDATA <= AFE_2_mosi_afe_buff  ;
			AFE_2_MISO_BUFF <= AFE_MISO	 ;
			
			-- other signals  
			
			AFE_1_LDACN_TRIM <= '1' ;
			AFE_1_CS_TRIM <= '1'  ;	
			AFE_1_LDACN_OFF <= '1';
			AFE_1_CS_OFF <= '1';
			AFE_2_LDACN_TRIM <= '1';
			AFE_2_CS_TRIM  <= '1';
			AFE_2_LDACN_OFF <= '1';
			AFE_2_CS_OFF <= '1'; 
			AFE1_SEN  <= '1';
			AFE_1_MISO_BUFF	 <= '0';
			
        when others => 
		
		-- shared signals
			sclk <= '1'  ;
			SDATA <= '1'  ;	
			AFE_1_MISO_BUFF <= '0';
			AFE_2_MISO_BUFF <= '0';	
		
			-- other signals
			AFE_1_LDACN_TRIM <= '1' ;
			AFE_1_CS_TRIM <= '1'  ;	
			AFE_1_LDACN_OFF <= '1';
			AFE_1_CS_OFF <= '1';
			AFE_2_LDACN_TRIM <= '1';
			AFE_2_CS_TRIM  <= '1';
			AFE_2_LDACN_OFF <= '1';
			AFE_2_CS_OFF <= '1'; 
			AFE1_SEN  <= '1';
			AFE2_SEN  <= '1';			

    end case;
  end process;
  
  

  
END behavioural;

