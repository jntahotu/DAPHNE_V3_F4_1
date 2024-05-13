-- endpoint.vhd
-- master clock distribution for DAPHNE V3 includes Bristol Timing Endpoint Logic 2.0
-- 
-- MMCM0: takes 100MHz system clock and produces system clocks CLK100, CLK200, and local 62.5MHz clock
--        this MMCM is reset by a hard reset from the PS
--
-- MMCM1: choose between local 62.5MHz clock or timing endpoint 62.5MHz clock. Generates the master clock 62.5MHz
--        and 125MHz + 500MHz clocks for the front end. use_ep is the bit that does the switching.
--
-- Timestamp is generated by endpoint (use_ep=1) or faked with free running counter (use_ep=0)
--
-- updated for DAPHNE V3 
--
-- jamieson olsen <jamieson@fnal.gov>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity endpoint is
port(

    sysclk100:   in std_logic;  -- 100MHz constant system clock from PS or oscillator
    reset_async: in std_logic;  -- async hard reset from the PS
    soft_reset:  out std_logic;  -- soft reset from user sync to axi clock

    -- external optical timing SFP link interface

    sfp_tmg_los: in std_logic; -- loss of signal
    rx0_tmg_p, rx0_tmg_n: in std_logic; -- LVDS recovered serial data ACKCHYUALLY the clock!
    sfp_tmg_tx_dis: out std_logic; -- high to disable timing SFP TX
    tx0_tmg_p, tx0_tmg_n: out std_logic; -- send data upstream

    -- output clocks used by daphne3 logic

    clock:   out std_logic;  -- master clock 62.5MHz
    clk500:  out std_logic;  -- front end clock 500MHz
    clk125:  out std_logic;  -- front end clock 125MHz
    
    timestamp: out std_logic_vector(63 downto 0); -- sync to clock
    
    
    -- DEBUG CLOCKS
   -- MMCM0_IN_CLK_DEB: OUT  STD_LOGIC;
    -- MMCM1_IN_ONE_DEB: OUT STD_LOGIC;
  --   MMCM1_IN_TWO_DEB: OUT STD_LOGIC;
--     MMCM0_OUT_DEB: OUT STD_LOGIC;
  --  MMCM1_OUT_DEB: OUT STD_LOGIC;

    -- AXI-Lite interface for the control/status registers

	S_AXI_ACLK: in std_logic;
	S_AXI_ARESETN: in std_logic;
	S_AXI_AWADDR: in std_logic_vector(31 downto 0);
	S_AXI_AWPROT: in std_logic_vector(2 downto 0);
	S_AXI_AWVALID: in std_logic;
	S_AXI_AWREADY: out std_logic;
	S_AXI_WDATA: in std_logic_vector(31 downto 0);
	S_AXI_WSTRB: in std_logic_vector(3 downto 0);
	S_AXI_WVALID: in std_logic;
	S_AXI_WREADY: out std_logic;
	S_AXI_BRESP: out std_logic_vector(1 downto 0);
	S_AXI_BVALID: out std_logic;
	S_AXI_BREADY: in std_logic;
	S_AXI_ARADDR: in std_logic_vector(31 downto 0);
	S_AXI_ARPROT: in std_logic_vector(2 downto 0);
	S_AXI_ARVALID: in std_logic;
	S_AXI_ARREADY: out std_logic;
	S_AXI_RDATA: out std_logic_vector(31 downto 0);
	S_AXI_RRESP: out std_logic_vector(1 downto 0);
	S_AXI_RVALID: out std_logic;
	S_AXI_RREADY: in std_logic
);
end endpoint;

architecture endpoint_arch of endpoint is

component pdts_endpoint_wrapper is -- wrapped and cleaned up for DAPHNE V2a design
port(
    sys_clk: in std_logic; -- System clock is 100MHz
    sys_rst: in std_logic; -- System reset (sclk domain)
    sys_stat: out std_logic_vector(3 downto 0); -- Status output (sclk domain)
    sys_addr: in std_logic_vector(15 downto 0);
    los: in std_logic := '0'; -- External signal path status (async)
    rxd: in std_logic; -- Timing input (clk domain)
    txd: out std_logic; -- Timing output (clk domain)
    txenb: out std_logic; -- Timing output enable (active low for SFP) (clk domain)
    clk: out std_logic; -- Base clock output is 62.5MHz
    rst: out std_logic; -- Base clock reset (clk domain)
    ready: out std_logic; -- Endpoint ready flag (clk domain)
    tstamp: out std_logic_vector(63 downto 0) -- Timestamp (clk domain)
);
end component;

component ep_axi is
port(
    S_AXI_ACLK: in std_logic;
    S_AXI_ARESETN: in std_logic;
    S_AXI_AWADDR: in std_logic_vector(31 downto 0);
    S_AXI_AWPROT: in std_logic_vector(2 downto 0);
    S_AXI_AWVALID: in std_logic;
    S_AXI_AWREADY: out std_logic;
    S_AXI_WDATA: in std_logic_vector(31 downto 0);
    S_AXI_WSTRB: in std_logic_vector(3 downto 0);
    S_AXI_WVALID: in std_logic;
    S_AXI_WREADY: out std_logic;
    S_AXI_BRESP: out std_logic_vector(1 downto 0);
    S_AXI_BVALID: out std_logic;
    S_AXI_BREADY: in std_logic;
    S_AXI_ARADDR: in std_logic_vector(31 downto 0);
    S_AXI_ARPROT: in std_logic_vector(2 downto 0);
    S_AXI_ARVALID: in std_logic;
    S_AXI_ARREADY: out std_logic;
    S_AXI_RDATA: out std_logic_vector(31 downto 0);
    S_AXI_RRESP: out std_logic_vector(1 downto 0);
    S_AXI_RVALID: out std_logic;
    S_AXI_RREADY: in std_logic;
    ep_ts_rdy: in std_logic;
    ep_stat: in std_logic_vector(3 downto 0);
    mmcm0_locked: in std_logic;
    mmcm1_locked: in std_logic;
    ep_reset: out std_logic;
    ep_addr: out std_logic_vector(15 downto 0);
    soft_reset: out std_logic;
    mmcm1_reset: out std_logic;
    use_ep: out std_logic
);
end component;

-- signal sysclk100_ibuf: std_logic;
signal mmcm0_clkfbout, mmcm0_clkfbout_buf: std_logic;
signal mmcm0_clkout0: std_logic;
-- signal mmcm0_clkout1: std_logic;
signal mmcm0_clkout2: std_logic;
signal local_clk62p5: std_logic;
signal clk100_i: std_logic;
signal rx0_tmg, tx0_tmg: std_logic;

signal ep_clk62p5: std_logic;

signal mmcm1_clkfbout, mmcm1_clkfbout_buf: std_logic;
signal mmcm1_clkout0, mmcm1_clkout1, mmcm1_clkout2: std_logic;
signal clock_i: std_logic;

signal mmcm0_locked: std_logic;
signal mmcm1_locked: std_logic;
signal mmcm1_reset: std_logic;
signal use_ep: std_logic;
signal ep_stat: std_logic_vector(3 downto 0);
signal ep_reset: std_logic;
signal ep_ts_rdy: std_logic;
signal ep_addr: std_logic_vector(15 downto 0);

signal real_timestamp, fake_timestamp, timestamp_reg: std_logic_vector(63 downto 0);

begin

-- if using external LVDS 100MHz sysclk, receive it with IBUFDS.
-- sysclk_ibufds_inst : IBUFGDS 
-- port map(O => sysclk_ibuf, I => sysclk_p, IB => sysclk_n);

mmcm0_inst: MMCME2_ADV
generic map(
    BANDWIDTH            => "OPTIMIZED",
    CLKOUT4_CASCADE      => FALSE,
    COMPENSATION         => "ZHOLD",
    STARTUP_WAIT         => FALSE,
    DIVCLK_DIVIDE        => 1,
    CLKFBOUT_MULT_F      => 10.000, -- VCO = 1000MHz
    CLKFBOUT_PHASE       => 0.000,
    CLKFBOUT_USE_FINE_PS => FALSE,
    CLKOUT0_DIVIDE_F     => 16.000, -- CLKOUT0 = 62.5MHz
    CLKOUT0_PHASE        => 0.000,
    CLKOUT0_DUTY_CYCLE   => 0.500,
    CLKOUT0_USE_FINE_PS  => FALSE,
    CLKOUT1_DIVIDE       => 5, -- CLKOUT1 = 200MHz
    CLKOUT1_PHASE        => 0.000,
    CLKOUT1_DUTY_CYCLE   => 0.500,
    CLKOUT1_USE_FINE_PS  => FALSE,
    CLKOUT2_DIVIDE       => 10, -- CLKOUT2 = 100MHz
    CLKOUT2_PHASE        => 0.000,
    CLKOUT2_DUTY_CYCLE   => 0.500,
    CLKOUT2_USE_FINE_PS  => FALSE,
    CLKIN1_PERIOD        => 10.000 -- 100MHz system clock input
)
port map(
    CLKFBOUT            => mmcm0_clkfbout,
    CLKFBOUTB           => open,
    CLKOUT0             => mmcm0_clkout0, -- 62.5MHz
    CLKOUT0B            => open,
    CLKOUT1             => open, -- mmcm0_clkout1, -- 200MHz
    CLKOUT1B            => open,
    CLKOUT2             => mmcm0_clkout2, -- 100MHz
    CLKOUT2B            => open,     
    CLKOUT3             => open, 
    CLKOUT3B            => open,
    CLKOUT4             => open,
    CLKOUT5             => open,
    CLKOUT6             => open,
    CLKFBIN             => mmcm0_clkfbout_buf,
    CLKIN1              => sysclk100, -- 100 MHz system clock
    CLKIN2              => '0',
    CLKINSEL            => '1', -- high to use CLKIN1
    DADDR               => (others=>'0'),
    DCLK                => '0',
    DEN                 => '0',
    DI                  => (others=>'0'),
    DO                  => open,
    DRDY                => open,
    DWE                 => '0',
    PSCLK               => '0',
    PSEN                => '0',
    PSINCDEC            => '0',
    PSDONE              => open,
    LOCKED              => mmcm0_locked,
    CLKINSTOPPED        => open,
    CLKFBSTOPPED        => open,
    PWRDWN              => '0',
    RST                 => reset_async
);

mmcm0_clkfb_inst: BUFG port map( I => mmcm0_clkfbout, O => mmcm0_clkfbout_buf);

mmcm0_clk0_inst:  BUFG port map( I => mmcm0_clkout0, O => local_clk62p5); -- local clock 62.5MHz

-- mmcm0_clk1_inst:  BUFG port map( I => mmcm0_clkout1, O => clk200); -- system clock 200MHz

mmcm_clk2_inst:  BUFG port map( I => mmcm0_clkout2, O => clk100_i);  -- system clock 100MHz

--clk100 <= clk100_i;

-- On DAPHNE V3 the timing system recevied clock comes directly 
-- from the optical SFP receiver; there is no exernal CDR chip at all

timing_rxclk_inst: IBUFDS
generic map( DIFF_TERM => TRUE, IBUF_LOW_PWR => FALSE )
port map( I => rx0_tmg_p, IB => rx0_tmg_n, O  => rx0_tmg );

-- timing endpoint 2.0 logic from UK Bristol developers

pdts_endpoint_inst: pdts_endpoint_wrapper
	port map(
		sys_clk => clk100_i, -- 100MHz from MMCM0
		sys_rst => ep_reset,
		sys_stat => ep_stat,
        sys_addr => ep_addr,
		los => sfp_tmg_los,
		rxd => rx0_tmg, 
		txd => tx0_tmg, 
		txenb => sfp_tmg_tx_dis, -- Timing output enable (active low for SFP) (clk domain)
		clk => ep_clk62p5, -- output clock from endpoint 62.5MHz
		rst => open, -- endpoint reset output not used here
		ready => ep_ts_rdy,
		tstamp => real_timestamp
	);

-- LVDS driver for timing SFP return channel, this connects directly 
-- to the timing optical SFP transmitter

OBUFDS_inst: OBUFDS
--generic map(IOSTANDARD=>"LVDS_25")
port map( I => tx0_tmg, O => tx0_tmg_p, OB => tx0_tmg_n );

-- MMCM1 chooses between local clock 62.5MHz or the endpoint clock 62.5MHz
-- after switching be sure to reset this MMCM! From the selected clock generate
-- the master 62.5MHz and 125MHz + 500MHz clocks needed for the new front end

mmcm1_inst: MMCME2_ADV
generic map(
    BANDWIDTH            => "OPTIMIZED",
    CLKOUT4_CASCADE      => FALSE,
    COMPENSATION         => "ZHOLD",
    STARTUP_WAIT         => FALSE,
    DIVCLK_DIVIDE        => 1,
    CLKFBOUT_MULT_F      => 16.000, -- VCO = 1000MHz
    CLKFBOUT_PHASE       => 0.000,
    CLKFBOUT_USE_FINE_PS => FALSE,
    CLKOUT0_DIVIDE_F     => 2.000, -- CLKOUT0 = 500 MHz
    CLKOUT0_PHASE        => 0.000,
    CLKOUT0_DUTY_CYCLE   => 0.500,
    CLKOUT0_USE_FINE_PS  => FALSE,
    CLKOUT1_DIVIDE       => 16,    -- CLKOUT1 = 62.5 MHz
    CLKOUT1_PHASE        => 0.000,
    CLKOUT1_DUTY_CYCLE   => 0.500,
    CLKOUT1_USE_FINE_PS  => FALSE,
    CLKOUT2_DIVIDE       => 8,     -- CLKOUT2 = 125 MHz
    CLKOUT2_PHASE        => 0.000,
    CLKOUT2_DUTY_CYCLE   => 0.500,
    CLKOUT2_USE_FINE_PS  => FALSE,
    CLKIN1_PERIOD        => 16.000, -- CLKIN1 = 62.5MHz 
    CLKIN2_PERIOD        => 16.000  -- CLKIN2 = 62.5MHz 
)
port map(
    CLKFBOUT            => mmcm1_clkfbout,
    CLKFBOUTB           => open,
    CLKOUT0             => mmcm1_clkout0, -- 500 MHz
    CLKOUT0B            => open,
    CLKOUT1             => mmcm1_clkout1, -- 62.5 MHz
    CLKOUT1B            => open,
    CLKOUT2             => mmcm1_clkout2, -- 125 MHz
    CLKOUT2B            => open,     
    CLKOUT3             => open, 
    CLKOUT3B            => open,
    CLKOUT4             => open,
    CLKOUT5             => open,
    CLKOUT6             => open,
    CLKFBIN             => mmcm1_clkfbout_buf,
    CLKIN1              => ep_clk62p5,     -- endpoint clock 62.5         
    CLKIN2              => local_clk62p5,  -- local clock 62.5          
    CLKINSEL            => use_ep,         -- 1 = CLKIN1 = endpoint clock, 0 = CLKIN2 = local clock
    DADDR               => (others=>'0'),
    DCLK                => '0',
    DEN                 => '0',
    DI                  => (others=>'0'),
    DO                  => open,
    DRDY                => open,
    DWE                 => '0',
    PSCLK               => '0',
    PSEN                => '0',
    PSINCDEC            => '0',
    PSDONE              => open,
    LOCKED              => mmcm1_locked,
    CLKINSTOPPED        => open,
    CLKFBSTOPPED        => open,
    PWRDWN              => '0',
    RST                 => mmcm1_reset
);

mmcm1_clkfb_inst: BUFG port map( I => mmcm1_clkfbout, O => mmcm1_clkfbout_buf);

mmcm1_clk0_inst:  BUFG port map( I => mmcm1_clkout0, O => clk500); -- fast clock 500MHz for front end logic

mmcm1_clk1_inst:  BUFG port map( I => mmcm1_clkout1, O => clock_i); -- master clock 62.5MHz

clock <= clock_i;

mmcm1_clk2_inst:  BUFG port map( I => mmcm1_clkout2, O => clk125); -- front end clock 125MHz

-- make a fake timestamp for when we're running with local clocks (use_ep=0) free running counter

fake_ts_proc: process(clock_i)
begin
    if rising_edge(clock_i) then
        if (reset_async='1') then
           fake_timestamp <= (others=>'0');
        else
           fake_timestamp <= std_logic_vector(unsigned(fake_timestamp) + 1);
       end if;
   end if;
end process fake_ts_proc;

-- mux and register the timestamps in the master clock domain
--
-- CDC WARNING! real_timestamp launches in ep_clk62p5 domain, but is captured in mclk domain.
-- IF the endpoint clock is selected (use_ep=1) THEN mclk and ep_clk62p5 are frequency locked.
-- BUT the phase is unknown due to routing delays and latency through MMCM1. It is possible 
-- that timestamp_reg may capture garbage here. We'll have to see and maybe make this CDC more robust...

ts_proc: process(clock_i)
begin
    if rising_edge(clock_i) then
        if (use_ep='1') then
            timestamp_reg <= real_timestamp; -- from endpoint
       else
           timestamp_reg <= fake_timestamp;
        end if;
   end if;
end process ts_proc;

timestamp <= timestamp_reg;

-- AXI-LITE interface handles the control and status bits

ep_axi_inst: ep_axi 
port map(
    S_AXI_ACLK => S_AXI_ACLK,
    S_AXI_ARESETN => S_AXI_ARESETN,
    S_AXI_AWADDR => S_AXI_AWADDR,
    S_AXI_AWPROT => S_AXI_AWPROT,
    S_AXI_AWVALID => S_AXI_AWVALID,
    S_AXI_AWREADY => S_AXI_AWREADY,
    S_AXI_WDATA => S_AXI_WDATA,
    S_AXI_WSTRB => S_AXI_WSTRB,
    S_AXI_WVALID => S_AXI_WVALID,
    S_AXI_WREADY => S_AXI_WREADY,
    S_AXI_BRESP => S_AXI_BRESP,
    S_AXI_BVALID => S_AXI_BVALID,
    S_AXI_BREADY => S_AXI_BREADY,
    S_AXI_ARADDR => S_AXI_ARADDR,
    S_AXI_ARPROT => S_AXI_ARPROT,
    S_AXI_ARVALID => S_AXI_ARVALID,
    S_AXI_ARREADY => S_AXI_ARREADY,
    S_AXI_RDATA => S_AXI_RDATA,
    S_AXI_RRESP => S_AXI_RRESP,
    S_AXI_RVALID => S_AXI_RVALID,
    S_AXI_RREADY => S_AXI_RREADY,

    ep_ts_rdy => ep_ts_rdy,
    ep_stat => ep_stat,
    mmcm0_locked => mmcm0_locked,
    mmcm1_locked => mmcm1_locked,

    ep_reset => ep_reset,
    ep_addr => ep_addr,
    soft_reset => soft_reset,
    mmcm1_reset => mmcm1_reset,
    use_ep => use_ep
);
  --  MMCM0_IN_CLK_DEB <= sysclk100;
 --    MMCM1_IN_ONE_DEB <= ep_clk62p5;
  --   MMCM1_IN_TWO_DEB <= local_clk62p5;
  --   MMCM0_OUT_DEB <= mmcm0_clkout0;
 --   MMCM1_OUT_DEB <= mmcm1_clkout1;
end endpoint_arch;
