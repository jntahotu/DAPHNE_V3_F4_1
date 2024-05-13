----------------------------------------------------------------------------------
-- Company: Fermilab
-- Engineer: Jacques Ntahoturi
-- 
-- Create Date: 04/19/2024 12:39:53 AM
-- Design Name: Daphne v3
-- Module Name: SPI_MASTER_TOP - Behavioral
-- Project Name: daphne v3 spi firmware
-- Target Devices: k26c
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity SPI_MASTER_TOP is

	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line
    clk_togle_len: integer :=24;
	dac_data_len: integer :=32;
    data_length : INTEGER := 24;
		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
	);
  Port ( 
-- shared signals
clk     : IN     STD_LOGIC;                             --system clock
rst	: in std_logic;

--AFE0_OUT_IN SIGNALS
    AFE0_MISO    : IN     STD_LOGIC;                             --master in slave out
    AFE0_SCLK    : OUT    STD_LOGIC;                             --spi clock --- 10MHZ    worked better durring the test
    AFE0_CS    : OUT    STD_LOGIC;                             --chip select
	AFE0_CS_TRIM: OUT STD_LOGIC;
	AFE0_CS_OFF: OUT STD_LOGIC;
    AFE0_SDATA    : OUT    STD_LOGIC;                             --master out slave in
	AFE0_LDACN_TRIM: OUT STD_LOGIC;
	AFE0_LDACN_OFF: OUT STD_LOGIC;

--AFE 1&2 OUT_IN SIGNALS

    AFE12_AFE_MISO    : IN     STD_LOGIC;                             --master in slave out for the AFEs - shared signal between them
   
    AFE12_AFE1_SEN    : OUT    STD_LOGIC;                             --chip select for the afe1 
    AFE12_AFE2_SEN    : OUT    STD_LOGIC;                             --chip select for the afe2
		
	AFE12_AFE_1_CS_TRIM: OUT STD_LOGIC;							  -- Chip select for afe1 trim dac
	AFE12_AFE_1_CS_OFF: OUT STD_LOGIC;							  -- chip select for afe1 offset dac  	
		
	AFE12_AFE_2_CS_TRIM: OUT STD_LOGIC;							  -- Chip select for afe2 trim dac
	AFE12_AFE_2_CS_OFF: OUT STD_LOGIC;							  -- chip select for afe2 offset dac 
		
    AFE12_SDATA    : OUT    STD_LOGIC;                             --master out slave in 	shared between all 6 chips
    AFE12_SCLK    : OUT    STD_LOGIC;                             --spi clock --- 10MHZ    worked better durring the test	  shared btween all 6 chips
	
	AFE12_AFE_1_LDACN_TRIM: OUT STD_LOGIC;
	AFE12_AFE_1_LDACN_OFF: OUT STD_LOGIC;	
	
	AFE12_AFE_2_LDACN_TRIM: OUT STD_LOGIC;
	AFE12_AFE_2_LDACN_OFF: OUT STD_LOGIC;
	
--AFE 3&4 OUT_IN SIGNALS

    AFE34_AFE_MISO    : IN     STD_LOGIC;                             --master in slave out for the AFEs - shared signal between them
   
    AFE34_AFE1_SEN    : OUT    STD_LOGIC;                             --chip select for the afe1 
    AFE34_AFE2_SEN    : OUT    STD_LOGIC;                             --chip select for the afe2
		
	AFE34_AFE_1_CS_TRIM: OUT STD_LOGIC;							  -- Chip select for afe1 trim dac
	AFE34_AFE_1_CS_OFF: OUT STD_LOGIC;							  -- chip select for afe1 offset dac  	
		
	AFE34_AFE_2_CS_TRIM: OUT STD_LOGIC;							  -- Chip select for afe2 trim dac
	AFE34_AFE_2_CS_OFF: OUT STD_LOGIC;							  -- chip select for afe2 offset dac 
		
    AFE34_SDATA    : OUT    STD_LOGIC;                             --master out slave in 	shared between all 6 chips
    AFE34_SCLK    : OUT    STD_LOGIC;                             --spi clock --- 10MHZ    worked better durring the test	  shared btween all 6 chips
	
	AFE34_AFE_1_LDACN_TRIM: OUT STD_LOGIC;
	AFE34_AFE_1_LDACN_OFF: OUT STD_LOGIC;	
	
	AFE34_AFE_2_LDACN_TRIM: OUT STD_LOGIC;
	AFE34_AFE_2_LDACN_OFF: OUT STD_LOGIC;
	
-- 3 DACS SIGNALS TO GO TO CURRENT MONITOR

	DACS_SCLK: OUT std_logic ;
    DACS_CS: OUT std_logic ;
    DACS_MOSI: OUT std_logic ;
    DACS_LDACN: OUT std_logic ;
	
-- AFE 0 AND DACS AXI INTERFACE SIGNALS

		AFE0_AXI_ACLK	: in std_logic;
		AFE0_AXI_ARESETN	: in std_logic;
		AFE0_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		AFE0_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		AFE0_AXI_AWVALID	: in std_logic;
		AFE0_AXI_AWREADY	: out std_logic;
		AFE0_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);   
		AFE0_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		AFE0_AXI_WVALID	: in std_logic;
		AFE0_AXI_WREADY	: out std_logic;
		AFE0_AXI_BRESP	: out std_logic_vector(1 downto 0);
		AFE0_AXI_BVALID	: out std_logic;
		AFE0_AXI_BREADY	: in std_logic;
		AFE0_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		AFE0_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		AFE0_AXI_ARVALID	: in std_logic;
		AFE0_AXI_ARREADY	: out std_logic;
		AFE0_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		AFE0_AXI_RRESP	: out std_logic_vector(1 downto 0);
		AFE0_AXI_RVALID	: out std_logic;
		AFE0_AXI_RREADY	: in std_logic		;
		
-- AFE 1&2 AND DACS AXI INTERFACE SIGNALS

		AFE12_AXI_ACLK	: in std_logic;		
		AFE12_AXI_ARESETN	: in std_logic;		
		AFE12_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		AFE12_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		AFE12_AXI_AWVALID	: in std_logic;
		AFE12_AXI_AWREADY	: out std_logic;
		AFE12_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);   
		AFE12_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		AFE12_AXI_WVALID	: in std_logic;
		AFE12_AXI_WREADY	: out std_logic;
		AFE12_AXI_BRESP	: out std_logic_vector(1 downto 0);
		AFE12_AXI_BVALID	: out std_logic;
		AFE12_AXI_BREADY	: in std_logic;
		AFE12_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		AFE12_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		AFE12_AXI_ARVALID	: in std_logic;
		AFE12_AXI_ARREADY	: out std_logic;
		AFE12_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		AFE12_AXI_RRESP	: out std_logic_vector(1 downto 0);
		AFE12_AXI_RVALID	: out std_logic;
		AFE12_AXI_RREADY	: in std_logic	;
		
-- AFE 3&4 AND DACS AXI INTERFACE SIGNALS

		AFE34_AXI_ACLK	: in std_logic;
		AFE34_AXI_ARESETN	: in std_logic;
		AFE34_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		AFE34_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		AFE34_AXI_AWVALID	: in std_logic;
		AFE34_AXI_AWREADY	: out std_logic;
		AFE34_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);   
		AFE34_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		AFE34_AXI_WVALID	: in std_logic;
		AFE34_AXI_WREADY	: out std_logic;
		AFE34_AXI_BRESP	: out std_logic_vector(1 downto 0);
		AFE34_AXI_BVALID	: out std_logic;
		AFE34_AXI_BREADY	: in std_logic;
		AFE34_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		AFE34_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		AFE34_AXI_ARVALID	: in std_logic;
		AFE34_AXI_ARREADY	: out std_logic;
		AFE34_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		AFE34_AXI_RRESP	: out std_logic_vector(1 downto 0);
		AFE34_AXI_RVALID	: out std_logic;
		AFE34_AXI_RREADY	: in std_logic	
	

);
end SPI_MASTER_TOP;

architecture Behavioral of SPI_MASTER_TOP is
-- SIGNALS signal
--AFE0 DACS MAPING signal 
 signal    AFE0_tx_REG:STD_LOGIC_VECTOR(data_length-1 DOWNTO 0);
signal 	AFE0_TX_TRIM_REG:    STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
signal 	AFE0_TX_OFF_REG   : STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
 signal    AFE0_rx_REG	   :   STD_LOGIC_VECTOR(data_length-1 DOWNTO 0); 
 signal    AFE0_reset_n_REG:STD_LOGIC;
signal 	AFE0_reset_n1_REG:    STD_LOGIC;
signal 	AFE0_chip_slector_REG   : STD_LOGIC_VECTOR (1 DOWNTO 0);

-- AFE 1 AND 2 SIGNALS
   signal  AFE12_reset_n_REG :  STD_LOGIC;
	signal AFE12_reset_n1_REG : STD_LOGIC;

	signal AFE12_chip_slector_REG :STD_LOGIC_VECTOR (2 DOWNTO 0);
    signal AFE12_AFE_1_TX_REG	:	 STD_LOGIC_VECTOR(data_length-1 DOWNTO 0);
   signal  AFE12_AFE_2_TX_REG	:	STD_LOGIC_VECTOR(data_length-1 DOWNTO 0); 
		
	signal AFE12_AFE_1_TX_TRIM_REG:STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
	signal AFE12_AFE_1_TX_OFF_REG :STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
		
	signal AFE12_AFE_2_TX_TRIM_REG :STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
	signal AFE12_AFE_2_TX_OFF_REG :STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
		
	signal AFE12_AFE_2_rx_REG:	 STD_LOGIC_VECTOR(data_length-1 DOWNTO 0);   
   signal  AFE12_AFE_1_rx_REG:	STD_LOGIC_VECTOR(data_length-1 DOWNTO 0);
   
--AFE 3 AND 4 SIGNALS

   signal  AFE34_reset_n_REG :  STD_LOGIC;
	signal AFE34_reset_n1_REG : STD_LOGIC;

	signal AFE34_chip_slector_REG :STD_LOGIC_VECTOR (2 DOWNTO 0);
    signal AFE34_AFE_1_TX_REG	:	 STD_LOGIC_VECTOR(data_length-1 DOWNTO 0);
   signal  AFE34_AFE_2_TX_REG	:	STD_LOGIC_VECTOR(data_length-1 DOWNTO 0); 
		
	signal AFE34_AFE_1_TX_TRIM_REG:STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
	signal AFE34_AFE_1_TX_OFF_REG :STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
		
	signal AFE34_AFE_2_TX_TRIM_REG :STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
	signal AFE34_AFE_2_TX_OFF_REG :STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
		
	signal AFE34_AFE_2_rx_REG:	 STD_LOGIC_VECTOR(data_length-1 DOWNTO 0);   
   signal  AFE34_AFE_1_rx_REG:	STD_LOGIC_VECTOR(data_length-1 DOWNTO 0);
   
   -- SIGNALS FOR THE THREE DACS
   
   signal DACS_RESET_N: std_logic ;
signal DACS_TX: std_logic_vector (47 downto 0);
   
  --AXI_AFE0 AND DACS SIGNALS 
  
    signal AFE0_afe_offset_reset:std_logic ;
    signal AFE0_afe_offset_tx:STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
    signal AFE0_afe_trim_tx:STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
    signal AFE0_Chip_selector:STD_LOGIC_VECTOR (1 DOWNTO 0);
    signal afe_0_SPI_tx:STD_LOGIC_VECTOR(data_length-1 DOWNTO 0); 
    signal afe_0_SPI_Rx:STD_LOGIC_VECTOR(data_length-1 DOWNTO 0); 
    signal afe_0_SPI_reset:std_logic ;
    signal AFE0_dacs: std_logic_vector(47 downto 0);
    signal AFE0_dacs_reset:std_logic ;
    
    
 -- AXI_AFE12 singnals
 
 	    signal AFE12_afe_offset_reset:  std_logic; 
    signal AFE12_afe1_offset_tx:  std_logic_vector(31 downto 0); 
   	signal AFE12_afe2_offset_tx:  std_logic_vector(31 downto 0);
    signal AFE12_afe1_trim_tx:  std_logic_vector(31 downto 0);
	signal AFE12_afe2_trim_tx:  std_logic_vector(31 downto 0);
  signal AFE12_Chip_selector:  std_logic_vector (2 downto 0); -- soft reset afe_offsef spi logic
      signal AFE12_afe_1_SPI_tx:  std_logic_vector(23 downto 0);
     signal AFE12_afe_1_SPI_Rx:  std_logic_vector(23 downto 0); 
      signal AFE12_afe_2_SPI_tx:  std_logic_vector(23 downto 0);
     signal AFE12_afe_2_SPI_Rx:  std_logic_vector(23 downto 0); 
  signal AFE12_afe_1_SPI_reset:  std_logic; -- soft reset afe_offsef spi logic
  
     
 -- AXI_AFE34 singnals
 
 	    signal AFE34_afe_offset_reset:  std_logic; 
    signal AFE34_afe1_offset_tx:  std_logic_vector(31 downto 0); 
   	signal AFE34_afe2_offset_tx:  std_logic_vector(31 downto 0);
    signal AFE34_afe1_trim_tx:  std_logic_vector(31 downto 0);
	signal AFE34_afe2_trim_tx:  std_logic_vector(31 downto 0);
  signal AFE34_Chip_selector:  std_logic_vector (2 downto 0); -- soft reset afe_offsef spi logic
      signal AFE34_afe_1_SPI_tx:  std_logic_vector(23 downto 0);
     signal AFE34_afe_1_SPI_Rx:  std_logic_vector(23 downto 0); 
      signal AFE34_afe_2_SPI_tx:  std_logic_vector(23 downto 0);
     signal AFE34_afe_2_SPI_Rx:  std_logic_vector(23 downto 0); 
  signal AFE34_afe_1_SPI_reset:  std_logic; -- soft reset afe_offsef spi logic
-- componentS HERE

component AFE_0_SPI IS
  GENERIC(
    clk_togle_len: integer :=24;
	dac_data_len: integer :=32;
    data_length : INTEGER := 24);     --data length in bits
  PORT(
    clk     : IN     STD_LOGIC;                             --system clock
    reset_n : IN     STD_LOGIC;                             --asynchronous active low reset
	reset_n1: in STD_LOGIC;                   -- for dacs trim and off
   -- enable  : IN     STD_LOGIC;                             --initiate communication   --- made this signals
	-- cpol    : IN     STD_LOGIC;  									--clock polarity mode      --- made this signals
  --  cpha    : IN     STD_LOGIC;                  --clock phase mode      --- made this signals
	chip_slector: in STD_LOGIC_VECTOR(1 downto 0);   
 
    miso    : IN     STD_LOGIC;                             --master in slave out
    sclk    : OUT    STD_LOGIC;                             --spi clock --- 10MHZ    worked better durring the test
    cs    : OUT    STD_LOGIC;                             --chip select
	CS_TRIM: OUT STD_LOGIC;
	CS_OFF: OUT STD_LOGIC;
    SDATA    : OUT    STD_LOGIC;                             --master out slave in
    --LDACN    : OUT    STD_LOGIC;                             -- USED FOR LDACN
	LDACN_TRIM: OUT STD_LOGIC;
	LDACN_OFF: OUT STD_LOGIC;
    tx		: IN     STD_LOGIC_VECTOR(data_length-1 DOWNTO 0);  --data to transmit
	TX_TRIM: IN STD_LOGIC_VECTOR (dac_data_len-1 DOWNTO 0);
	TX_OFF: IN STD_LOGIC_VECTOR(dac_data_len-1 DOWNTO 0);
    rx	   : OUT    STD_LOGIC_VECTOR(data_length-1 DOWNTO 0)); --data received
 
end component ;


component  AFE_1_2_SPI IS
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
    
end component ;
component DACS IS
  GENERIC(
    clk_togle_len: integer :=48;
    data_length : INTEGER := 48);     --data length in bits
  PORT(
    clk     : IN     STD_LOGIC;                             --system clock
    reset_n : IN     STD_LOGIC;                             --asynchronous active low reset
   -- enable  : IN     STD_LOGIC;                             --initiate communication   --- made this signals
	-- cpol    : IN     STD_LOGIC;  									--clock polarity mode      --- made this signals
  --  cpha    : IN     STD_LOGIC;  									--clock phase mode      --- made this signals
  --  miso    : IN     STD_LOGIC;                             --master in slave out
    sclk    : OUT    STD_LOGIC;                             --spi clock --- 10MHZ    worked better durring the test
    ss_n    : OUT    STD_LOGIC;                             --chip select
    mosi    : OUT    STD_LOGIC;                             --master out slave in
    LDACN    : OUT    STD_LOGIC;                             -- USED FOR LDACN
    tx		: IN     STD_LOGIC_VECTOR(data_length-1 DOWNTO 0));  --data to transmit
   -- rx	   : OUT    STD_LOGIC_VECTOR(data_length-1 DOWNTO 0)); --data received
END component ;

component AXI_FOR_DACS is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
		-- Users to add ports here
	    afe_offset_reset: out std_logic; -- soft reset afe_offsef spi logic
    afe_offset_tx: OUT std_logic_vector(31 downto 0); 
   
    afe_trim_tx: out std_logic_vector(31 downto 0); 
  Chip_selector: out std_logic_vector (1 downto 0); -- soft reset afe_offsef spi logic
   
   
      afe_0_SPI_tx: out std_logic_vector(23 downto 0);
     afe_0_SPI_Rx: IN std_logic_vector(23 downto 0); 
  afe_0_SPI_reset: out std_logic; -- soft reset afe_offsef spi logic
  
  
    dacs: out std_logic_vector(47 downto 0);
      dacs_reset: out std_logic; -- soft reset afe_offsef spi logic
    -- misc interface signals
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
	);

end component ;


component AXI_FOR_DACS_AFE_COMBO is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
		-- Users to add ports here
	    afe_offset_reset: out std_logic; -- soft reset afe_offsef spi logic
    afe1_offset_tx: OUT std_logic_vector(31 downto 0); 
   	afe2_offset_tx: OUT std_logic_vector(31 downto 0);
    afe1_trim_tx: out std_logic_vector(31 downto 0);
	afe2_trim_tx: out std_logic_vector(31 downto 0);
  Chip_selector: out std_logic_vector (2 downto 0); -- soft reset afe_offsef spi logic
   
   
      afe_1_SPI_tx: out std_logic_vector(23 downto 0);
     afe_1_SPI_Rx: IN std_logic_vector(23 downto 0); 
      afe_2_SPI_tx: out std_logic_vector(23 downto 0);
     afe_2_SPI_Rx: IN std_logic_vector(23 downto 0); 
  afe_1_SPI_reset: out std_logic; -- soft reset afe_offsef spi logic
  
  
    

    -- misc interface signals
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
	);
end component ;


begin



 AFE0_tx_REG <= afe_0_SPI_tx;
AFE0_TX_TRIM_REG  <= AFE0_afe_trim_tx;
AFE0_TX_OFF_REG    <= AFE0_afe_offset_tx;
afe_0_SPI_Rx <= AFE0_rx_REG	   ; 
AFE0_reset_n_REG <= afe_0_SPI_reset;
AFE0_reset_n1_REG <= AFE0_afe_offset_reset;
AFE0_chip_slector_REG   <= AFE0_Chip_selector;
DACS_RESET_N <=  AFE0_dacs_reset ;
DACS_TX <=   AFE0_dacs  ;




AFE12_reset_n_REG <= AFE12_afe_1_SPI_reset;
AFE12_reset_n1_REG <= AFE12_afe_offset_reset;

AFE12_chip_slector_REG <= AFE12_Chip_selector;
AFE12_AFE_1_TX_REG	<= AFE12_afe_1_SPI_tx;
AFE12_AFE_2_TX_REG	<= AFE12_afe_2_SPI_tx;
AFE12_AFE_1_TX_TRIM_REG <= AFE12_afe1_trim_tx;
AFE12_AFE_1_TX_OFF_REG <= AFE12_afe1_offset_tx;
		
AFE12_AFE_2_TX_TRIM_REG <= AFE12_afe2_trim_tx;
AFE12_AFE_2_TX_OFF_REG <= AFE12_afe2_offset_tx;
		
AFE12_afe_2_SPI_Rx <= AFE12_AFE_2_rx_REG  ;
AFE12_afe_1_SPI_Rx <= AFE12_AFE_1_rx_REG;





AFE34_reset_n_REG <= AFE34_afe_1_SPI_reset;
AFE34_reset_n1_REG <= AFE34_afe_offset_reset;

AFE34_chip_slector_REG  <= AFE34_Chip_selector;
AFE34_AFE_1_TX_REG	 <= AFE34_afe_1_SPI_tx;
AFE34_AFE_2_TX_REG	 <= AFE34_afe_2_SPI_tx;
		
AFE34_AFE_1_TX_TRIM_REG <= AFE34_afe1_trim_tx;
AFE34_AFE_1_TX_OFF_REG  <= AFE34_afe1_offset_tx;
AFE34_AFE_2_TX_TRIM_REG  <= AFE34_afe2_trim_tx;
AFE34_AFE_2_TX_OFF_REG  <= AFE34_afe2_offset_tx;
		
 AFE34_afe_2_SPI_Rx <= AFE34_AFE_2_rx_REG   ;
AFE34_afe_1_SPI_Rx  <= AFE34_AFE_1_rx_REG;












 -- port maps here
afe_0_dacs_inst: AFE_0_SPI
port map(
    clk    => clk, 
    reset_n     => AFE0_reset_n_REG,
    reset_n1    => AFE0_reset_n1_REG,
	chip_slector    => AFE0_chip_slector_REG,
    miso        => AFE0_MISO,
    sclk        => AFE0_SCLK,
    cs       => AFE0_CS,
	CS_TRIM    => AFE0_CS_TRIM,
	CS_OFF    => AFE0_CS_OFF,
    SDATA       => AFE0_SDATA,
	LDACN_TRIM    => AFE0_LDACN_TRIM,
	LDACN_OFF    => AFE0_LDACN_OFF,
    tx		    => AFE0_tx_REG,
	TX_TRIM    => AFE0_TX_TRIM_REG,
	TX_OFF    => AFE0_TX_OFF_REG,
    rx	      => AFE0_rx_REG
);




afe_1_2_inst: AFE_1_2_SPI

port map(
    clk      => clk,  
    reset_n  => AFE12_reset_n_REG,
	reset_n1 => AFE12_reset_n1_REG,

	chip_slector =>AFE12_chip_slector_REG,
    AFE_MISO       => AFE12_AFE_MISO,
   
    AFE1_SEN       => AFE12_AFE1_SEN,
    AFE2_SEN       => AFE12_AFE2_SEN,
		
	AFE_1_CS_TRIM   => AFE12_AFE_1_CS_TRIM,
	AFE_1_CS_OFF   => AFE12_AFE_1_CS_OFF,
		
	AFE_2_CS_TRIM   => AFE12_AFE_2_CS_TRIM,
	AFE_2_CS_OFF   => AFE12_AFE_2_CS_OFF,
		
    SDATA       => AFE12_SDATA,
    sclk      => AFE12_SCLK,
	AFE_1_LDACN_TRIM   => AFE12_AFE_1_LDACN_TRIM,
	AFE_1_LDACN_OFF   => AFE12_AFE_1_LDACN_OFF,
	
	AFE_2_LDACN_TRIM   => AFE12_AFE_2_LDACN_TRIM,
	AFE_2_LDACN_OFF   => AFE12_AFE_2_LDACN_OFF,
	
    AFE_1_TX	=>	 AFE12_AFE_1_TX_REG,
    AFE_2_TX	=>		AFE12_AFE_2_TX_REG	, 
		
	AFE_1_TX_TRIM 	=>	AFE12_AFE_1_TX_TRIM_REG,
	AFE_1_TX_OFF 	=>	AFE12_AFE_1_TX_OFF_REG,
		
	AFE_2_TX_TRIM 	=>	AFE12_AFE_2_TX_TRIM_REG,
	AFE_2_TX_OFF 	=>	AFE12_AFE_2_TX_OFF_REG,
		
	AFE_2_rx		=>	    AFE12_AFE_2_rx_REG,
    AFE_1_rx		=>	   AFE12_AFE_1_rx_REG
);

afe_3_4_inst: AFE_1_2_SPI

port map(
    clk      => clk,  
    reset_n  => AFE34_reset_n_REG,
	reset_n1 => AFE34_reset_n1_REG,

	chip_slector =>AFE34_chip_slector_REG,
    AFE_MISO       => AFE34_AFE_MISO,
   
    AFE1_SEN       => AFE34_AFE1_SEN,
    AFE2_SEN       => AFE34_AFE2_SEN,
		
	AFE_1_CS_TRIM   => AFE34_AFE_1_CS_TRIM,
	AFE_1_CS_OFF   => AFE34_AFE_1_CS_OFF,
		
	AFE_2_CS_TRIM   => AFE34_AFE_2_CS_TRIM,
	AFE_2_CS_OFF   => AFE34_AFE_2_CS_OFF,
		
    SDATA       => AFE34_SDATA,
    sclk      => AFE34_SCLK,
	AFE_1_LDACN_TRIM   => AFE34_AFE_1_LDACN_TRIM,
	AFE_1_LDACN_OFF   => AFE34_AFE_1_LDACN_OFF,
	
	AFE_2_LDACN_TRIM   => AFE34_AFE_2_LDACN_TRIM,
	AFE_2_LDACN_OFF   => AFE34_AFE_2_LDACN_OFF,
	
    AFE_1_TX	=>	 AFE34_AFE_1_TX_REG,
    AFE_2_TX	=>		AFE34_AFE_2_TX_REG	, 
		
	AFE_1_TX_TRIM 	=>	AFE34_AFE_1_TX_TRIM_REG,
	AFE_1_TX_OFF 	=>	AFE34_AFE_1_TX_OFF_REG,
		
	AFE_2_TX_TRIM 	=>	AFE34_AFE_2_TX_TRIM_REG,
	AFE_2_TX_OFF 	=>	AFE34_AFE_2_TX_OFF_REG,
		
	AFE_2_rx		=>	    AFE34_AFE_2_rx_REG,
    AFE_1_rx		=>	   AFE34_AFE_1_rx_REG
);



DACS_inst: DACS
port map(

    clk        => clk,
    reset_n       =>  DACS_RESET_N,

    sclk        =>  DACS_SCLK,
    ss_n        =>  DACS_CS,
    mosi         =>  DACS_MOSI,
    LDACN        =>  DACS_LDACN,
    tx		     => DACS_TX
  

);


axi_afe_0_dacs_inst: AXI_FOR_DACS
port map(
		
    afe_offset_reset   => AFE0_afe_offset_reset,
    afe_offset_tx   => AFE0_afe_offset_tx,
   
    afe_trim_tx   => AFE0_afe_trim_tx,
    Chip_selector   => AFE0_Chip_selector,
   
   
    afe_0_SPI_tx   => afe_0_SPI_tx,
    afe_0_SPI_Rx   => afe_0_SPI_Rx,
    afe_0_SPI_reset   => afe_0_SPI_reset,
  
  
    dacs   => AFE0_dacs,
    dacs_reset   => AFE0_dacs_reset,
		S_AXI_ACLK	   => AFE0_AXI_ACLK,
		S_AXI_ARESETN	   => AFE0_AXI_ARESETN,
		S_AXI_AWADDR	   => AFE0_AXI_AWADDR,
		S_AXI_AWPROT	   => AFE0_AXI_AWPROT,
		S_AXI_AWVALID	   => AFE0_AXI_AWVALID,
		S_AXI_AWREADY	   => AFE0_AXI_AWREADY,
		S_AXI_WDATA	    => AFE0_AXI_WDATA,
		S_AXI_WSTRB   => AFE0_AXI_WSTRB,
		S_AXI_WVALID	   => AFE0_AXI_WVALID,
		S_AXI_WREADY	   => AFE0_AXI_WREADY,
		S_AXI_BRESP   =>    AFE0_AXI_BRESP,
		S_AXI_BVALID	   => AFE0_AXI_BVALID,
		S_AXI_BREADY	   => AFE0_AXI_BREADY,
		S_AXI_ARADDR	   => AFE0_AXI_ARADDR,
		S_AXI_ARPROT	   => AFE0_AXI_ARPROT,
		S_AXI_ARVALID	   =>  AFE0_AXI_ARVALID,  
		S_AXI_ARREADY	   => AFE0_AXI_ARREADY,
		S_AXI_RDATA	   => AFE0_AXI_RDATA,
		S_AXI_RRESP	   => AFE0_AXI_RRESP,
		S_AXI_RVALID	   => AFE0_AXI_RVALID,
		S_AXI_RREADY	   => AFE0_AXI_RREADY
);

axi_afe_1_2_inst:AXI_FOR_DACS_AFE_COMBO

port map(
  
	    afe_offset_reset  =>AFE12_afe_offset_reset,
    afe1_offset_tx  =>AFE12_afe1_offset_tx,
   	afe2_offset_tx  =>AFE12_afe2_offset_tx,
    afe1_trim_tx  =>AFE12_afe1_trim_tx,
	afe2_trim_tx  =>AFE12_afe2_trim_tx,
  Chip_selector  =>AFE12_Chip_selector,
      afe_1_SPI_tx  =>AFE12_afe_1_SPI_tx,
     afe_1_SPI_Rx  =>AFE12_afe_1_SPI_Rx,
      afe_2_SPI_tx  =>AFE12_afe_2_SPI_tx,
     afe_2_SPI_Rx  =>AFE12_afe_2_SPI_Rx,
  afe_1_SPI_reset  =>AFE12_afe_1_SPI_reset,
		S_AXI_ACLK	  =>AFE12_AXI_ACLK,
		S_AXI_ARESETN	  =>AFE12_AXI_ARESETN,
		S_AXI_AWADDR  =>	AFE12_AXI_AWADDR,
		S_AXI_AWPROT  =>	AFE12_AXI_AWPROT,
		S_AXI_AWVALID  =>	AFE12_AXI_AWVALID,
		S_AXI_AWREADY	  =>AFE12_AXI_AWREADY,
		S_AXI_WDATA	  =>AFE12_AXI_WDATA,
		S_AXI_WSTRB	  =>AFE12_AXI_WSTRB,
		S_AXI_WVALID	  =>AFE12_AXI_WVALID,
		S_AXI_WREADY  =>	AFE12_AXI_WREADY,
		S_AXI_BRESP	  =>AFE12_AXI_BRESP,
		S_AXI_BVALID  =>	AFE12_AXI_BVALID,
		S_AXI_BREADY =>	AFE12_AXI_BREADY,
		S_AXI_ARADDR  =>	AFE12_AXI_ARADDR,
		S_AXI_ARPROT	  =>AFE12_AXI_ARPROT,
		S_AXI_ARVALID	  =>AFE12_AXI_ARVALID,
		S_AXI_ARREADY  =>	AFE12_AXI_ARREADY,
		S_AXI_RDATA  =>	AFE12_AXI_RDATA,
		S_AXI_RRESP	  =>AFE12_AXI_RRESP,
		S_AXI_RVALID  =>	AFE12_AXI_RVALID,
		S_AXI_RREADY	  =>AFE12_AXI_RREADY
);


axi_afe_3_4_inst:AXI_FOR_DACS_AFE_COMBO
port map(

	    afe_offset_reset  =>AFE34_afe_offset_reset,
    afe1_offset_tx  =>AFE34_afe1_offset_tx,
   	afe2_offset_tx  =>AFE34_afe2_offset_tx,
    afe1_trim_tx  =>AFE34_afe1_trim_tx,
	afe2_trim_tx  =>AFE34_afe2_trim_tx,
  Chip_selector  =>AFE34_Chip_selector,
      afe_1_SPI_tx  =>AFE34_afe_1_SPI_tx,
     afe_1_SPI_Rx  =>AFE34_afe_1_SPI_Rx,
      afe_2_SPI_tx  =>AFE34_afe_2_SPI_tx,
     afe_2_SPI_Rx  =>AFE34_afe_2_SPI_Rx,
  afe_1_SPI_reset  =>AFE34_afe_1_SPI_reset,
		S_AXI_ACLK	  =>AFE34_AXI_ACLK,
		S_AXI_ARESETN	  =>AFE34_AXI_ARESETN,
		S_AXI_AWADDR  =>	AFE34_AXI_AWADDR,
		S_AXI_AWPROT  =>	AFE34_AXI_AWPROT,
		S_AXI_AWVALID  =>	AFE34_AXI_AWVALID,
		S_AXI_AWREADY	  =>AFE34_AXI_AWREADY,
		S_AXI_WDATA	  =>AFE34_AXI_WDATA,
		S_AXI_WSTRB	  =>AFE34_AXI_WSTRB,
		S_AXI_WVALID	  =>AFE34_AXI_WVALID,
		S_AXI_WREADY  =>	AFE34_AXI_WREADY,
		S_AXI_BRESP	  =>AFE34_AXI_BRESP,
		S_AXI_BVALID  =>	AFE34_AXI_BVALID,
		S_AXI_BREADY =>	AFE34_AXI_BREADY,
		S_AXI_ARADDR  =>	AFE34_AXI_ARADDR,
		S_AXI_ARPROT	  =>AFE34_AXI_ARPROT,
		S_AXI_ARVALID	  =>AFE34_AXI_ARVALID,
		S_AXI_ARREADY  =>	AFE34_AXI_ARREADY,
		S_AXI_RDATA  =>	AFE34_AXI_RDATA,
		S_AXI_RRESP	  =>AFE34_AXI_RRESP,
		S_AXI_RVALID  =>	AFE34_AXI_RVALID,
		S_AXI_RREADY	  =>AFE34_AXI_RREADY
);


end Behavioral;
