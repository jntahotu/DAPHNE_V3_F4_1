#J.OLSEN
# J.NTAHOTURI, T.DELINE, M.MARCHAN
# this file contains all signals locations and voltage properties
# for the DAPHNE_V3


#timing constraints goes here  

# DAPHNE3 PL TIMING constraints

# define primary clocks...

create_clock -name sysclk100    -period 10.000  [get_pins -hierarchical  -filter {NAME=~"*sysclk100*"}]
create_clock -name rx_tmg_clk   -period 16.000  [get_ports rx0_tmg_p ]
create_clock -name sb_axi_clk   -period 8.000   [get_pins -hierarchical  -filter {NAME=~"*SB_AXI_ACLK*"}]
create_clock -name fe_axi_clk   -period 8.000   [get_pins -hierarchical  -filter {NAME=~"*FE_AXI_ACLK*"}]
create_clock -name ep_axi_clk   -period 8.000   [get_pins -hierarchical  -filter {NAME=~"*EP_AXI_ACLK*"}]

# rename the auto-generated clocks...

create_generated_clock -name local_clk62p5  [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/mmcm0_clkout0]
create_generated_clock -name clk100         [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/mmcm0_clkout2]
create_generated_clock -name mmcm0_clkfbout [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/mmcm0_clkfbout]

create_generated_clock -name ep_clk62p5  [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/pdts_endpoint_inst/pdts_endpoint_inst/rxcdr/mmcm/CLKOUT0]
create_generated_clock -name ep_clk4x    [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/pdts_endpoint_inst/pdts_endpoint_inst/rxcdr/mmcm/CLKOUT1]
create_generated_clock -name ep_clk2x    [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/pdts_endpoint_inst/pdts_endpoint_inst/rxcdr/mmcm/CLKOUT1]
create_generated_clock -name ep_clkfbout [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/pdts_endpoint_inst/pdts_endpoint_inst/rxcdr/mmcm/CLKFBOUT] 

create_generated_clock -name clk500_0        -master_clock ep_clk62p5 [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/mmcm1_inst/CLKOUT0]
create_generated_clock -name clock_0         -master_clock ep_clk62p5 [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/mmcm1_inst/CLKOUT1]
create_generated_clock -name clk125_0        -master_clock ep_clk62p5 [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/mmcm1_inst/CLKOUT2]
create_generated_clock -name mmcm1_clkfbout0 -master_clock ep_clk62p5 [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/mmcm1_inst/CLKFBOUT]

create_generated_clock -name clk500_1        -master_clock local_clk62p5 [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/mmcm1_inst/CLKOUT0]
create_generated_clock -name clock_1         -master_clock local_clk62p5 [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/mmcm1_inst/CLKOUT1]
create_generated_clock -name clk125_1        -master_clock local_clk62p5 [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/mmcm1_inst/CLKOUT2]
create_generated_clock -name mmcm1_clkfbout1 -master_clock local_clk62p5 [get_nets DAPHNE_V3_F4_1_i/DAPHNE3_0/U0/endpoint_inst/mmcm1_inst/CLKFBOUT]

# define clock groups this is how we tell vivado which clocks are related and which are NOT

set_clock_groups -name async_groups -asynchronous \
-group {sysclk100 clk100 mmcm0_clkfbout} \
-group {sb_axi_clk fe_axi_clk ep_axi_clk} \
-group {local_clk62p5} \
-group {clk500_0 clock_0 clk125_0 mmcm1_clkfbout0} \
-group {clk500_1 clock_1 clk125_1 mmcm1_clkfbout1} \
-group {ep_clk62p5 ep_clk4x ep_clk2x ep_clkfbout} \
-group {rx_tmg_clk} 

# tell vivado about places where signals cross clock domains so timing can be ignored here...

#set_false_path -from [get_pins fe_inst/gen_afe[*].afe_inst/auto_fsm_inst/done_reg_reg/C]      
#set_false_path -from [get_pins fe_inst/gen_afe[*].afe_inst/auto_fsm_inst/warn_reg_reg/C]      
#set_false_path -from [get_pins fe_inst/gen_afe[*].afe_inst/auto_fsm_inst/errcnt_reg_reg[*]/C] 
#set_false_path -from [get_pins trig_gbe*_reg_reg/C] -to [get_pins trig_sync_reg/D]
#set_false_path -to [get_pins led0_reg_reg[*]/C]
#set_false_path -from [get_pins test_reg_reg[*]/C]
#set_false_path -from [get_ports gbe_sfp_??s]
#set_false_path -from [get_ports cdr_sfp_??s]
#set_false_path -from [get_ports daq?_sfp_??s]
#set_false_path -from [get_pins st_enable_reg_reg[*]/C]
#set_false_path -from [get_pins outmode_reg_reg[*]/C]
#set_false_path -from [get_pins threshold_reg_reg[*]/C]
#set_false_path -from [get_pins daq_out_param_reg_reg[*]/C]
#set_false_path -from [get_pins core_inst/input_inst/*select_reg_reg*/C]







#end of timing constraints  




#PIN LOCATIONS ON THE SOM, SCHEMATIC AND SCHEMATIC NAME

#SFPs DAQ Control signals

#set_property PACKAGE_PIN W10      [get_ports {SFP_GTH0_TX_DIS}]   # pin location SOM240_2_A46
#set_property PACKAGE_PIN Y10      [get_ports {SFP_GTH0_ABS}]   # pin location SOM240_2_A47
#set_property PACKAGE_PIN Y9       [get_ports {SFP_GTH0_LOS}]   # pin location SOM240_2_A48
#set_property PACKAGE_PIN AA10     [get_ports {SFP_GTH1TX_DIS}]   # pin location SOM240_2_B48
#set_property PACKAGE_PIN AB11     [get_ports {SFP_GTH1_ABS}]   # pin location SOM240_2_B49
#set_property PACKAGE_PIN AA8      [get_ports {SFP_GTH1_LOS}]   # pin location SOM240_2_A50
#set_property PACKAGE_PIN AC11     [get_ports {SFP_GTH2_TX_DIS}]   # pin location SOM240_2_B50
#set_property PACKAGE_PIN AB10     [get_ports {SFP_GTH2_ABS}]   # pin location SOM240_2_A51
#set_property PACKAGE_PIN AA13     [get_ports {SFP_GTH2_LOS}]   # pin location SOM240_2_B52
#set_property PACKAGE_PIN AB9      [get_ports {SFP_GTH3_TX_DIS}]   # pin location SOM240_2_A52
#set_property PACKAGE_PIN AB13     [get_ports {SFP_GTH3_ABS}]   # pin location SOM240_2_B53
#set_property PACKAGE_PIN W14      [get_ports {SFP_GTH3_LOS}]   # pin location SOM240_2_B54


# SPI DAC controll signals

set_property PACKAGE_PIN AD14     [get_ports {DACS_SCLK}] ;  # pin location SOM240_2_D53
set_property PACKAGE_PIN AD15     [get_ports {DACS_MOSI}] ;  # pin location SOM240_2_D52
set_property PACKAGE_PIN AF10     [get_ports {DACS_CS}] ; # pin location SOM240_2_C52
set_property PACKAGE_PIN AE10     [get_ports {DACS_LDACN}]  ; # pin location SOM240_2_C51

set_property IOSTANDARD LVTTL [get_ports {DACS_SCLK}];
set_property IOSTANDARD LVTTL [get_ports {DACS_MOSI}];
set_property IOSTANDARD LVTTL [get_ports {DACS_CS}];
set_property IOSTANDARD LVTTL [get_ports {DACS_LDACN}];

# PL I2C signals
set_property PACKAGE_PIN AD11     [get_ports {IIC_0_scl_io}]  ; # pin location SOM240_2_B44
set_property PACKAGE_PIN AD10     [get_ports {IIC_0_sda_io}]  ; # pin location SOM240_2_B45

set_property IOSTANDARD LVTTL [get_ports {IIC_0_scl_io}];
set_property IOSTANDARD LVTTL [get_ports {IIC_0_sda_io}];
#set_property PACKAGE_PIN AA11     [get_ports {PL_I2C_Resetn}]   # pin location SOM240_2_B46




#clocks  ----- AFE clocks not included---------------

#set_property PACKAGE_PIN V6       [get_ports {GTH1_REFCLK_P}]   # pin location SOM240_2_A7
#set_property PACKAGE_PIN V5       [get_ports {GTH1_REFCLK_N}]   # pin location SOM240_2_A8
#set_property PACKAGE_PIN J5       [get_ports {CLK625_P}]   # pin location SOM240_2_A11
#set_property PACKAGE_PIN J4       [get_ports {CLK625_N}]   # pin location SOM240_2_A12
#set_property PACKAGE_PIN Y6       [get_ports {GTH0_REFCLK_P}]   # pin location SOM240_2_C3
#set_property PACKAGE_PIN Y5       [get_ports {GTH0_REFCLK_N}]   # pin location SOM240_2_C4
#set_property PACKAGE_PIN F23      [get_ports {GTR_REFCLK_P}]   # pin location SOM240_1_C47      
#set_property PACKAGE_PIN F24      [get_ports {GTR_REFCLK_N}]   # pin location SOM240_1_C48
#set_property PACKAGE_PIN L7       [get_ports {CLK100_P}]   # pin location SOM240_2_B12
#set_property PACKAGE_PIN L6       [get_ports {CLK100_N}]   # pin location SOM240_2_B13
set_property PACKAGE_PIN AE5      [get_ports {afe_clk_p}] ;  # pin location SOM240_2_C41
set_property PACKAGE_PIN AF5      [get_ports {afe_clk_n}]  ; # pin location SOM240_2_C42

set_property IOSTANDARD LVDS [get_ports {afe_clk_p}];
set_property IOSTANDARD LVDS [get_ports {afe_clk_n}];


# DAQ RX-TX DATA LINE FOR SFPs

#set_property PACKAGE_PIN Y2       [get_ports {RX0_GTH_P}]   # pin location SOM240_2_B9
#set_property PACKAGE_PIN Y1       [get_ports {RX0_GTH_N}]   # pin location SOM240_2_B10
#set_property PACKAGE_PIN W4       [get_ports {TX0_GTH_P}]   # pin location SOM240_2_D9
#set_property PACKAGE_PIN W3       [get_ports {TX0_GTH_N}]   # pin location SOM240_2_D10

#set_property PACKAGE_PIN V2       [get_ports {RX1_GTH_P}]   # pin location SOM240_2_D1
#set_property PACKAGE_PIN V1       [get_ports {RX1_GTH_N}]   # pin location SOM240_2_D2
#set_property PACKAGE_PIN U4       [get_ports {TX1_GTH_P}]   # pin location SOM240_2_C7
#set_property PACKAGE_PIN U3       [get_ports {TX1_GTH_N}]   # pin location SOM240_2_C8

#set_property PACKAGE_PIN P2       [get_ports {RX2_GTH_P}]   # pin location SOM240_2_D5
#set_property PACKAGE_PIN P1       [get_ports {RX2_GTH_N}]   # pin location SOM240_2_D6
#set_property PACKAGE_PIN N4       [get_ports {TX2_GTH_P}]   # pin location SOM240_2_A3
#set_property PACKAGE_PIN N3       [get_ports {TX2_GTH_N}]   # pin location SOM240_2_A4

#set_property PACKAGE_PIN T2       [get_ports {RX3_GTH_P}]   # pin location SOM240_2_B1
#set_property PACKAGE_PIN T1       [get_ports {RX3_GTH_N}]   # pin location SOM240_2_B2
#set_property PACKAGE_PIN R4       [get_ports {TX3_GTH_P}]   # pin location SOM240_2_B5
#set_property PACKAGE_PIN R3       [get_ports {TX3_GTH_N}]   # pin location SOM240_2_B6

#Timinng SFP ---- including the controll signals-------


set_property PACKAGE_PIN AD5      [get_ports {tx0_tmg_p}]  ; # pin location SOM240_2_C29
set_property PACKAGE_PIN AD4      [get_ports {tx0_tmg_n}]  ; # pin location SOM240_2_C30
set_property PACKAGE_PIN K4       [get_ports {rx0_tmg_p}]  ; # pin location SOM240_2_C11
set_property PACKAGE_PIN K3       [get_ports {rx0_tmg_n}]  ; # pin location SOM240_2_C12
set_property PACKAGE_PIN D11      [get_ports {sfp_tmg_tx_dis}]  ; # pin location SOM240_1_B22
#set_property PACKAGE_PIN AH12     [get_ports {SFP_TMG_ABS}]   # pin location SOM240_2_C46
set_property PACKAGE_PIN AE12     [get_ports {sfp_tmg_los}]  ; # pin location SOM240_2_D44

set_property IOSTANDARD LVDS [get_ports {tx0_tmg_p}];
set_property IOSTANDARD LVDS [get_ports {tx0_tmg_n}];
set_property IOSTANDARD LVDS [get_ports {rx0_tmg_p}];
set_property IOSTANDARD LVDS [get_ports {rx0_tmg_n}];

set_property IOSTANDARD LVTTL [get_ports {sfp_tmg_tx_dis}];
set_property IOSTANDARD LVTTL [get_ports {sfp_tmg_los}];


#   NOTE: some signals for these AFE are shared between two AFEs


#AFE 0

set_property PACKAGE_PIN H4       [get_ports {afe0_p[0]}]    ; # pin location SOM240_2_A14
set_property PACKAGE_PIN H3       [get_ports {afe0_n[0]}]   ;  # pin location SOM240_2_A15
set_property PACKAGE_PIN K2       [get_ports {afe0_p[1]}]    ; # pin location SOM240_2_B15
set_property PACKAGE_PIN J2       [get_ports {afe0_n[1]}]    ; # pin location SOM240_2_B16
set_property PACKAGE_PIN N7       [get_ports {afe0_p[2]}]    ; # pin location SOM240_2_A17
set_property PACKAGE_PIN N6       [get_ports {afe0_n[2]}]    ; # pin location SOM240_2_A18
set_property PACKAGE_PIN J1       [get_ports {afe0_p[3]}]   ;  # pin location SOM240_2_A20
set_property PACKAGE_PIN H1       [get_ports {afe0_n[3]}]    ; # pin location SOM240_2_A21
set_property PACKAGE_PIN J7       [get_ports {afe0_p[4]}]    ; # pin location SOM240_2_A23
set_property PACKAGE_PIN H7       [get_ports {afe0_n[4]}]    ; # pin location SOM240_2_A24
set_property PACKAGE_PIN R8       [get_ports {afe0_p[5]}]     ;# pin location SOM240_2_B24
set_property PACKAGE_PIN T8       [get_ports {afe0_n[5]}]    ;# pin location SOM240_2_B25
set_property PACKAGE_PIN H9       [get_ports {afe0_p[6]}]   ;  # pin location SOM240_2_A26
set_property PACKAGE_PIN H8       [get_ports {afe0_n[6]}]    ; # pin location SOM240_2_A27
set_property PACKAGE_PIN AF8      [get_ports {afe0_p[7]}]   ;  # pin location SOM240_2_B27
set_property PACKAGE_PIN AG8      [get_ports {afe0_n[7]}]   ;  # pin location SOM240_2_B28


set_property IOSTANDARD LVDS [get_ports {afe0_p[0]}];
set_property IOSTANDARD LVDS [get_ports {afe0_n[0]}];
set_property IOSTANDARD LVDS [get_ports {afe0_p[1]}];
set_property IOSTANDARD LVDS [get_ports {afe0_n[1]}];
set_property IOSTANDARD LVDS [get_ports {afe0_p[2]}];
set_property IOSTANDARD LVDS [get_ports {afe0_n[2]}];
set_property IOSTANDARD LVDS [get_ports {afe0_p[3]}];
set_property IOSTANDARD LVDS [get_ports {afe0_n[3]}];
set_property IOSTANDARD LVDS [get_ports {afe0_p[4]}];
set_property IOSTANDARD LVDS [get_ports {afe0_n[4]}];
set_property IOSTANDARD LVDS [get_ports {afe0_p[5]}];
set_property IOSTANDARD LVDS [get_ports {afe0_n[5]}];
set_property IOSTANDARD LVDS [get_ports {afe0_p[6]}];
set_property IOSTANDARD LVDS [get_ports {afe0_n[6]}];
set_property IOSTANDARD LVDS [get_ports {afe0_p[7]}];
set_property IOSTANDARD LVDS [get_ports {afe0_n[7]}];

set_property PACKAGE_PIN M6       [get_ports {afe0_p[8]}] ;  # pin location SOM240_2_B21   -fclk
set_property PACKAGE_PIN L5       [get_ports {afe0_n[8]}] ;  # pin location SOM240_2_B22
set_property IOSTANDARD LVDS [get_ports {afe0_p[8]}];
set_property IOSTANDARD LVDS [get_ports {afe0_n[8]}];


set_property PACKAGE_PIN Y13      [get_ports {AFE0_MISO}]    ;     # pin location SOM240_2_A55
set_property PACKAGE_PIN W12      [get_ports {AFE0_CS_OFF}]    ;# pin location SOM240_2_A56
set_property PACKAGE_PIN W11      [get_ports {AFE0_LDACN_OFF}] ;    # pin location SOM240_2_A58
set_property PACKAGE_PIN Y12      [get_ports {AFE0_LDACN_TRIM}]   ;  # pin location SOM240_2_A59
set_property PACKAGE_PIN AA12     [get_ports {AFE0_CS}]      ; # pin location SOM240_2_A60
set_property PACKAGE_PIN W13      [get_ports {AFE0_SDATA}]  ;     # pin location SOM240_2_B56
set_property PACKAGE_PIN AB15     [get_ports {AFE0_SCLK}]    ;   # pin location SOM240_2_B57
set_property PACKAGE_PIN AB14     [get_ports {AFE0_CS_TRIM}]   ;    # pin location SOM240_2_B58

set_property IOSTANDARD LVTTL [get_ports {AFE0_MISO}];
set_property IOSTANDARD LVTTL [get_ports {AFE0_CS_OFF}];
set_property IOSTANDARD LVTTL [get_ports {AFE0_LDACN_OFF}];
set_property IOSTANDARD LVTTL [get_ports {AFE0_LDACN_TRIM}];
set_property IOSTANDARD LVTTL [get_ports {AFE0_CS_TRIM}];
set_property IOSTANDARD LVTTL [get_ports {AFE0_CS}];
set_property IOSTANDARD LVTTL [get_ports {AFE0_SDATA}];
set_property IOSTANDARD LVTTL [get_ports {AFE0_SCLK}];




#AFE 1

set_property PACKAGE_PIN F8       [get_ports {afe1_p[0]}]  ; # pin location SOM240_1_D13
set_property PACKAGE_PIN E8       [get_ports {afe1_n[0]}]   ;# pin location SOM240_1_D14
set_property PACKAGE_PIN D7       [get_ports {afe1_p[1]}]  ; # pin location SOM240_1_C12
set_property PACKAGE_PIN D6       [get_ports {afe1_n[1]}]  ; # pin location SOM240_1_C13
set_property PACKAGE_PIN D4       [get_ports {afe1_p[2]}]  ; # pin location SOM240_1_D10
set_property PACKAGE_PIN C4       [get_ports {afe1_n[2]}]  ; # pin location SOM240_1_D11
set_property PACKAGE_PIN B4       [get_ports {afe1_p[3]}]   ;# pin location SOM240_1_C9
set_property PACKAGE_PIN A4       [get_ports {afe1_n[3]}]   ;# pin location SOM240_1_C10
set_property PACKAGE_PIN G3       [get_ports {afe1_p[4]}]   ;# pin location SOM240_1_C6
set_property PACKAGE_PIN F3       [get_ports {afe1_n[4]}]  ; # pin location SOM240_1_C7
set_property PACKAGE_PIN F2       [get_ports {afe1_p[5]}]   ;# pin location SOM240_1_D4
set_property PACKAGE_PIN E2       [get_ports {afe1_n[5]}]  ; # pin location SOM240_1_D5
set_property PACKAGE_PIN G1       [get_ports {afe1_p[6]}] ;  # pin location SOM240_1_C3
set_property PACKAGE_PIN F1       [get_ports {afe1_n[6]}] ;  # pin location SOM240_1_C4
set_property PACKAGE_PIN C1       [get_ports {afe1_p[7]}]  ; # pin location SOM240_1_B1
set_property PACKAGE_PIN B1       [get_ports {afe1_n[7]}]  ; # pin location SOM240_1_B2

set_property IOSTANDARD LVDS [get_ports {afe1_p[0]}];
set_property IOSTANDARD LVDS [get_ports {afe1_n[0]}];
set_property IOSTANDARD LVDS [get_ports {afe1_p[1]}];
set_property IOSTANDARD LVDS [get_ports {afe1_n[1]}];
set_property IOSTANDARD LVDS [get_ports {afe1_p[2]}];
set_property IOSTANDARD LVDS [get_ports {afe1_n[2]}];
set_property IOSTANDARD LVDS [get_ports {afe1_p[3]}];
set_property IOSTANDARD LVDS [get_ports {afe1_n[3]}];
set_property IOSTANDARD LVDS [get_ports {afe1_p[4]}];
set_property IOSTANDARD LVDS [get_ports {afe1_n[4]}];
set_property IOSTANDARD LVDS [get_ports {afe1_p[5]}];
set_property IOSTANDARD LVDS [get_ports {afe1_n[5]}];
set_property IOSTANDARD LVDS [get_ports {afe1_p[6]}];
set_property IOSTANDARD LVDS [get_ports {afe1_n[6]}];
set_property IOSTANDARD LVDS [get_ports {afe1_p[7]}];
set_property IOSTANDARD LVDS [get_ports {afe1_n[7]}];

set_property PACKAGE_PIN E1       [get_ports {afe1_p[8]}] ;  # pin location SOM240_1_D7   -fclk
set_property PACKAGE_PIN D1       [get_ports {afe1_n[8]}] ;  # pin location SOM240_1_D8
set_property IOSTANDARD LVDS [get_ports {afe1_p[8]}];
set_property IOSTANDARD LVDS [get_ports {afe1_n[8]}];

set_property PACKAGE_PIN E12      [get_ports {AFE12_AFE_MISO}]     ;    # pin location SOM240_1_B21
set_property PACKAGE_PIN D10      [get_ports {AFE12_AFE_1_CS_OFF}]  ;  # pin location SOM240_1_D21
set_property PACKAGE_PIN C11      [get_ports {AFE12_AFE_1_LDACN_OFF}] ;    # pin location SOM240_1_D22
set_property PACKAGE_PIN A10      [get_ports {AFE12_AFE_1_LDACN_TRIM}]  ;   # pin location SOM240_1_C23
set_property PACKAGE_PIN E10      [get_ports {AFE12_AFE1_SEN}]     ;  # pin location SOM240_1_D20
set_property PACKAGE_PIN J12      [get_ports {AFE12_SDATA}]   ;    # pin location SOM240_1_A16
set_property PACKAGE_PIN F12      [get_ports {AFE12_SCLK}]     ;  # pin location SOM240_1_C20
set_property PACKAGE_PIN B11      [get_ports {AFE12_AFE_1_CS_TRIM}]  ;     # pin location SOM240_1_C22

set_property IOSTANDARD LVTTL [get_ports {AFE12_AFE_MISO}];
set_property IOSTANDARD LVTTL [get_ports {AFE12_AFE_1_CS_OFF}];
set_property IOSTANDARD LVTTL [get_ports {AFE12_AFE_1_LDACN_OFF}];
set_property IOSTANDARD LVTTL [get_ports {AFE12_AFE_1_LDACN_TRIM}];
set_property IOSTANDARD LVTTL [get_ports {AFE12_AFE1_SEN}];
set_property IOSTANDARD LVTTL [get_ports {AFE12_SDATA}];
set_property IOSTANDARD LVTTL [get_ports {AFE12_SCLK}];
set_property IOSTANDARD LVTTL [get_ports {AFE12_AFE_1_CS_TRIM}];


#AFE 2

set_property PACKAGE_PIN K8       [get_ports {afe2_p[0]}] ;  # pin location SOM240_2_D24
set_property PACKAGE_PIN K7       [get_ports {afe2_n[0]}]  ; # pin location SOM240_2_D25
set_property PACKAGE_PIN K9       [get_ports {afe2_p[1]}]   ;# pin location SOM240_2_C23
set_property PACKAGE_PIN J9       [get_ports {afe2_n[1]}]   ;# pin location SOM240_2_C24
set_property PACKAGE_PIN R7       [get_ports {afe2_p[2]}]  ; # pin location SOM240_2_D21
set_property PACKAGE_PIN T7       [get_ports {afe2_n[2]}]  ; # pin location SOM240_2_D22
set_property PACKAGE_PIN P7       [get_ports {afe2_p[3]}]  ; # pin location SOM240_2_C20
set_property PACKAGE_PIN P6       [get_ports {afe2_n[3]}] ;  # pin location SOM240_2_C21
set_property PACKAGE_PIN U8       [get_ports {afe2_p[4]}]  ; # pin location SOM240_2_C17
set_property PACKAGE_PIN V8       [get_ports {afe2_n[4]}] ;  # pin location SOM240_2_C18
set_property PACKAGE_PIN W8       [get_ports {afe2_p[5]}] ;  # pin location SOM240_2_D15
set_property PACKAGE_PIN Y8       [get_ports {afe2_n[5]}]  ; # pin location SOM240_2_D16
set_property PACKAGE_PIN N9       [get_ports {afe2_p[6]}]  ; # pin location SOM240_2_C14
set_property PACKAGE_PIN N8       [get_ports {afe2_n[6]}]  ; # pin location SOM240_2_C15
set_property PACKAGE_PIN U9       [get_ports {afe2_p[7]}] ;  # pin location SOM240_2_D12
set_property PACKAGE_PIN V9       [get_ports {afe2_n[7]}]  ; # pin location SOM240_2_D13

set_property IOSTANDARD LVDS [get_ports {afe2_p[0]}];
set_property IOSTANDARD LVDS [get_ports {afe2_n[0]}];
set_property IOSTANDARD LVDS [get_ports {afe2_p[1]}];
set_property IOSTANDARD LVDS [get_ports {afe2_n[1]}];
set_property IOSTANDARD LVDS [get_ports {afe2_p[2]}];
set_property IOSTANDARD LVDS [get_ports {afe2_n[2]}];
set_property IOSTANDARD LVDS [get_ports {afe2_p[3]}];
set_property IOSTANDARD LVDS [get_ports {afe2_n[3]}];
set_property IOSTANDARD LVDS [get_ports {afe2_p[4]}];
set_property IOSTANDARD LVDS [get_ports {afe2_n[4]}];
set_property IOSTANDARD LVDS [get_ports {afe2_p[5]}];
set_property IOSTANDARD LVDS [get_ports {afe2_n[5]}];
set_property IOSTANDARD LVDS [get_ports {afe2_p[6]}];
set_property IOSTANDARD LVDS [get_ports {afe2_n[6]}];
set_property IOSTANDARD LVDS [get_ports {afe2_p[7]}];
set_property IOSTANDARD LVDS [get_ports {afe2_n[7]}];

set_property PACKAGE_PIN L3       [get_ports {afe2_p[8]}] ;  # pin location SOM240_2_D18
set_property PACKAGE_PIN L2       [get_ports {afe2_n[8]}] ;  # pin location SOM240_2_D19
set_property IOSTANDARD LVDS [get_ports {afe2_p[8]}];
set_property IOSTANDARD LVDS [get_ports {afe2_n[8]}];

#set_property PACKAGE_PIN E12      [get_ports {AFE2_SDOUT}]         # pin location SOM240_1_B21
set_property PACKAGE_PIN K12      [get_ports {AFE12_AFE_2_CS_OFF}] ;   # pin location SOM240_1_B18
set_property PACKAGE_PIN H12      [get_ports {AFE12_AFE_2_LDACN_OFF}]  ;   # pin location SOM240_1_A17
set_property PACKAGE_PIN J10       [get_ports {AFE12_AFE_2_LDACN_TRIM}] ;    # pin location B16
set_property PACKAGE_PIN B10      [get_ports {AFE12_AFE2_SEN}]  ;     # pin location SOM240_1_B20
#set_property PACKAGE_PIN J12      [get_ports {AFE12_SDATA}]       # pin location SOM240_1_A16
#set_property PACKAGE_PIN F12      [get_ports {AFE12_SCLK}]       # pin location SOM240_1_C20
set_property PACKAGE_PIN K13      [get_ports {AFE12_AFE_2_CS_TRIM}]  ;     # pin location SOM240_1_B17

set_property IOSTANDARD LVTTL [get_ports {AFE12_AFE_2_CS_OFF}];
set_property IOSTANDARD LVTTL [get_ports {AFE12_AFE_2_LDACN_OFF}];
set_property IOSTANDARD LVTTL [get_ports {AFE12_AFE_2_LDACN_TRIM}];
set_property IOSTANDARD LVTTL [get_ports {AFE12_AFE2_SEN}];
set_property IOSTANDARD LVTTL [get_ports {AFE12_AFE_2_CS_TRIM}];

#AFE 3

set_property PACKAGE_PIN AB7      [get_ports {afe3_p[0]}]  ; # pin location SOM240_2_D39
set_property PACKAGE_PIN AC7      [get_ports {afe3_n[0]}]  ; # pin location SOM240_2_D40
set_property PACKAGE_PIN AG9      [get_ports {afe3_p[1]}]   ;# pin location SOM240_2_C38
set_property PACKAGE_PIN AH9      [get_ports {afe3_n[1]}]  ; # pin location SOM240_2_C39
set_property PACKAGE_PIN AB8      [get_ports {afe3_p[2]}]   ;# pin location SOM240_2_D36
set_property PACKAGE_PIN AC8      [get_ports {afe3_n[2]}] ;  # pin location SOM240_2_D37
set_property PACKAGE_PIN AB4      [get_ports {afe3_p[3]}]  ; # pin location SOM240_2_C35
set_property PACKAGE_PIN AB3      [get_ports {afe3_n[3]}] ;  # pin location SOM240_2_C36
set_property PACKAGE_PIN AC4      [get_ports {afe3_p[4]}] ;  # pin location SOM240_2_C32
set_property PACKAGE_PIN AC3      [get_ports {afe3_n[4]}] ;  # pin location SOM240_2_C33
set_property PACKAGE_PIN AE9      [get_ports {afe3_p[5]}]  ; # pin location SOM240_2_D30
set_property PACKAGE_PIN AE8      [get_ports {afe3_n[5]}]  ; # pin location SOM240_2_D31
set_property PACKAGE_PIN AF7      [get_ports {afe3_p[6]}]  ; # pin location SOM240_2_D27
set_property PACKAGE_PIN AF6      [get_ports {afe3_n[6]}]  ; # pin location SOM240_2_D28
set_property PACKAGE_PIN AE3      [get_ports {afe3_p[7]}]  ; # pin location SOM240_2_C26
set_property PACKAGE_PIN AF3      [get_ports {afe3_n[7]}]  ; # pin location SOM240_2_C27

set_property IOSTANDARD LVDS      [get_ports {afe3_p[0]}]  ;
set_property IOSTANDARD LVDS      [get_ports {afe3_n[0]}]  ;
set_property IOSTANDARD LVDS      [get_ports {afe3_p[1]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe3_n[1]}]  ;
set_property IOSTANDARD LVDS      [get_ports {afe3_p[2]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe3_n[2]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe3_p[3]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe3_n[3]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe3_p[4]}]  ;
set_property IOSTANDARD LVDS      [get_ports {afe3_n[4]}]  ;
set_property IOSTANDARD LVDS      [get_ports {afe3_p[5]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe3_n[5]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe3_p[6]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe3_n[6]}]  ;
set_property IOSTANDARD LVDS      [get_ports {afe3_p[7]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe3_n[7]}]  ;

set_property PACKAGE_PIN AC9      [get_ports {afe3_p[8]}] ;  # pin location SOM240_2_D33
set_property PACKAGE_PIN AD9      [get_ports {afe3_n[8]}] ;  # pin location SOM240_2_D34
set_property IOSTANDARD LVDS      [get_ports {afe3_p[8]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe3_n[8]}]  ;

set_property PACKAGE_PIN AH14     [get_ports {AFE34_AFE_MISO}]  ;       # pin location SOM240_2_D58
set_property PACKAGE_PIN AC12     [get_ports {AFE34_AFE_1_CS_OFF}] ;   # pin location SOM240_2_C48
set_property PACKAGE_PIN AH10     [get_ports {AFE34_AFE_1_LDACN_OFF}]  ;   # pin location SOM240_2_D48
set_property PACKAGE_PIN AH11     [get_ports {AFE34_AFE_1_LDACN_TRIM}]  ;   # pin location SOM240_2_C47
set_property PACKAGE_PIN AF11     [get_ports {AFE34_AFE1_SEN}];       # pin location SOM240_2_D49
set_property PACKAGE_PIN AC13     [get_ports {AFE34_SDATA}]   ;    # pin location SOM240_2_C58
set_property PACKAGE_PIN AD12     [get_ports {AFE34_SCLK}]     ;  # pin location SOM240_2_C50
set_property PACKAGE_PIN AG10     [get_ports {AFE34_AFE_1_CS_TRIM}]   ;    # pin location SOM240_2_D46

set_property IOSTANDARD LVTTL     [get_ports {AFE34_AFE_MISO}]     ;
set_property IOSTANDARD LVTTL     [get_ports {AFE34_AFE_1_CS_OFF}]   ;
set_property IOSTANDARD LVTTL     [get_ports {AFE34_AFE_1_LDACN_OFF}]    ;
set_property IOSTANDARD LVTTL     [get_ports {AFE34_AFE_1_LDACN_TRIM}]    ;
set_property IOSTANDARD LVTTL     [get_ports {AFE34_AFE1_SEN}]      ;
set_property IOSTANDARD LVTTL     [get_ports {AFE34_SDATA}]       ;
set_property IOSTANDARD LVTTL     [get_ports {AFE34_SCLK}]       ;
set_property IOSTANDARD LVTTL     [get_ports {AFE34_AFE_1_CS_TRIM}]    ; 

#AFE 4

set_property PACKAGE_PIN AG6      [get_ports {afe4_p[0]}] ;  # pin location SOM240_2_A29
set_property PACKAGE_PIN AG5      [get_ports {afe4_n[0]}]  ; # pin location SOM240_2_A30
set_property PACKAGE_PIN AD2      [get_ports {afe4_p[1]}]  ; # pin location SOM240_2_B30
set_property PACKAGE_PIN AD1      [get_ports {afe4_n[1]}]   ;# pin location SOM240_2_B31
set_property PACKAGE_PIN AH2      [get_ports {afe4_p[2]}]   ;# pin location SOM240_2_A32
set_property PACKAGE_PIN AH1      [get_ports {afe4_n[2]}]   ;# pin location SOM240_2_A33
set_property PACKAGE_PIN AG3      [get_ports {afe4_p[3]}]  ; # pin location SOM240_2_B33
set_property PACKAGE_PIN AH3      [get_ports {afe4_n[3]}]  ; # pin location SOM240_2_B34
set_property PACKAGE_PIN AH8      [get_ports {afe4_p[4]}]   ;# pin location SOM240_2_B36
set_property PACKAGE_PIN AH7      [get_ports {afe4_n[4]}]   ;# pin location SOM240_2_B37
set_property PACKAGE_PIN AG4      [get_ports {afe4_p[5]}]  ; # pin location SOM240_2_A38
set_property PACKAGE_PIN AH4      [get_ports {afe4_n[5]}]   ;# pin location SOM240_2_A39
set_property PACKAGE_PIN AE2      [get_ports {afe4_p[6]}]  ; # pin location SOM240_2_B39
set_property PACKAGE_PIN AF2      [get_ports {afe4_n[6]}] ;  # pin location SOM240_2_B40
set_property PACKAGE_PIN AD7      [get_ports {afe4_p[7]}]  ; # pin location on SOM240_2_A41
set_property PACKAGE_PIN AE7      [get_ports {afe4_n[7]}]   ;# pin location on SOM240_2_A42

set_property IOSTANDARD LVDS      [get_ports {afe4_p[0]}]  ;
set_property IOSTANDARD LVDS      [get_ports {afe4_n[0]}]  ;
set_property IOSTANDARD LVDS      [get_ports {afe4_p[1]}]   ;
set_property IOSTANDARD LVDS     [get_ports {afe4_n[1]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe4_p[2]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe4_n[2]}]  ;
set_property IOSTANDARD LVDS      [get_ports {afe4_p[3]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe4_n[3]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe4_p[4]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe4_n[4]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe4_p[5]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe4_n[5]}]  ;
set_property IOSTANDARD LVDS      [get_ports {afe4_p[6]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe4_n[6]}]  ;
set_property IOSTANDARD LVDS      [get_ports {afe4_p[7]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe4_n[7]}]   ;

set_property PACKAGE_PIN AB2      [get_ports {afe4_p[8]}] ;  # pin location SOM240_2_A35
set_property PACKAGE_PIN AC2      [get_ports {afe4_n[8]}] ;  # pin location SOM240_2_A36
set_property IOSTANDARD LVDS      [get_ports {afe4_p[8]}]   ;
set_property IOSTANDARD LVDS      [get_ports {afe4_n[8]}]   ;

#set_property PACKAGE_PIN AH14     [get_ports {AFE4_SDOUT}]         # pin location SOM240_2_D58
set_property PACKAGE_PIN AC14     [get_ports {AFE34_AFE_2_CS_OFF}] ;   # pin location SOM240_2_C56
set_property PACKAGE_PIN AE14     [get_ports {AFE34_AFE_2_LDACN_OFF}];     # pin location SOM240_2_D56
set_property PACKAGE_PIN AH13     [get_ports {AFE34_AFE_2_LDACN_TRIM}]  ;   # pin location SOM240_2_C55
set_property PACKAGE_PIN AG14     [get_ports {AFE34_AFE2_SEN}]       ;# pin location SOM240_2_D57
#set_property PACKAGE_PIN AC13     [get_ports {AFE34_SDATA}]       # pin location SOM240_2_C58
#set_property PACKAGE_PIN AD12     [get_ports {AFE34_SCLK}]       # pin location SOM240_2_C50
set_property PACKAGE_PIN AE15     [get_ports {AFE34_AFE_2_CS_TRIM}]   ;    # pin location SOM240_2_D54

set_property IOSTANDARD LVTTL     [get_ports {AFE34_AFE_2_CS_OFF}]   ;
set_property IOSTANDARD LVTTL     [get_ports {AFE34_AFE_2_LDACN_OFF}]    ; 
set_property IOSTANDARD LVTTL     [get_ports {AFE34_AFE_2_LDACN_TRIM}]   ;
set_property IOSTANDARD LVTTL     [get_ports {AFE34_AFE2_SEN}]     ;
set_property IOSTANDARD LVTTL     [get_ports {AFE34_AFE_2_CS_TRIM}]     ;  

#SHARED AFE SIGNALS
set_property PACKAGE_PIN AG13     [get_ports {AFE_PD_RST[0]}]    ;   # pin location SOM240_2_C54  ----- RESET
set_property PACKAGE_PIN AE13     [get_ports {AFE_PD_RST[1]}]    ;   # pin location SOM240_2_C59  ------ POWER DOWN

set_property IOSTANDARD LVTTL      [get_ports {AFE_PD_RST[0]}]   ;   
set_property IOSTANDARD LVTTL      [get_ports {AFE_PD_RST[1]}]     ; 


# MUX

#set_property PACKAGE_PIN Y14      [get_ports {MUXEN0}]  	     # pin location SOM240_2_A54
#set_property PACKAGE_PIN AF13     [get_ports {MUXEN1}]  	     # pin location SOM240_2_C60
#set_property PACKAGE_PIN AG11     [get_ports {MUXA0}]  	     # pin location SOM240_2_D50
#set_property PACKAGE_PIN AF12     [get_ports {MUXA1}]  	     # pin location SOM240_2_D45



# PL STAT LEDs

#set_property PACKAGE_PIN A2       [get_ports {PL_STAT_LED0}]   # pin location SOM240_1_A3
#set_property PACKAGE_PIN E18      [get_ports {PL_STAT_LED1}]   # pin location SOM240_1_A4
#set_property PACKAGE_PIN C3       [get_ports {PL_STAT_LED2}]   # pin location SOM240_1_A6
#set_property PACKAGE_PIN C2       [get_ports {PL_STAT_LED3}]   # pin location SOM240_1_A7
#set_property PACKAGE_PIN G6       [get_ports {PL_STAT_LED4}]   # pin location SOM240_1_A9
#set_property PACKAGE_PIN F6       [get_ports {PL_STAT_LED5}]   # pin location SOM240_1_A10








# These signals don't need to be assigned. 



# Ps STAT LEDs

#set_property PACKAGE_PIN xxx[get_ports {PS_STAT_LED0}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN xxx[get_ports {PS_STAT_LED1}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN xxx[get_ports {PS_STAT_LED2}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN xxx[get_ports {PS_STAT_LED3}]   # pin location on the schematic is XX



# TEST POINTS


#set_property PACKAGE_PIN xxx[get_ports {PWRGD_FPD_M2C}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN xxx[get_ports {PWRGD_LPD_M2C}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN xxx[get_ports {PWRGD_PL_M2C}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN xxx[get_ports {PS_ERROR_OUT_M2C}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN xxx[get_ports {PS_ERROR_STATUS_M2C}]   # pin location on the schematic is XX


# CM SPI SIGNALS

set_property PACKAGE_PIN G11 [get_ports {CM_SCLK}] ;  # pin location on the schematic is SOM_1 D16
set_property PACKAGE_PIN F10 [get_ports {CM_CSn}]  ; # pin location on the schematic is SOM_1 D17
set_property PACKAGE_PIN J11 [get_ports {CM_DOUT}] ;  # pin location on the schematic is SOM_1 D18
set_property PACKAGE_PIN H11 [get_ports {CM_DIN}]   ;# pin location on the schematic is SOM_1 C18
#set_property PACKAGE_PIN xxx[get_ports {CM_DRDYn}]   # pin location on the schematic is SOM_1 C19

set_property IOSTANDARD LVTTL  [get_ports {CM_SCLK}]  ;
set_property IOSTANDARD LVTTL  [get_ports {CM_CSn}]  ;
set_property IOSTANDARD LVTTL  [get_ports {CM_DOUT}]   ;
set_property IOSTANDARD LVTTL  [get_ports {CM_DIN}]   ;

# OTHER SIGNALS

#set_property PACKAGE_PIN XX[get_ports {PS_POR_B_C2M}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN XX[get_ports {PS_SRST_B_C2M}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN XX[get_ports {MIO24_I2C_SCK}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN XX[get_ports {MIO24_I2C_SDA}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN XX[get_ports {VBIAS_EN}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN XX[get_ports {PWR_OFF_C2M_L}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN XX[get_ports {RXD}]   # pin location on the schematic is XX
#set_property PACKAGE_PIN XX[get_ports {TXD}]   # pin location on the schematic is XX


set_property PACKAGE_PIN E3 [get_ports {FAN_CONTROL}] ;  # pin location on the schematic is SOM_1 D16
set_property IOSTANDARD LVCMOS18  [get_ports {FAN_CONTROL}]   ;









































# voltage properties for LVTTL signals

#set_property IOSTANDARD LVTTL [get_ports {NAME*}]




# voltage properties for LVCMOS signals

#set_property IOSTANDARD LVCMOS18 [get_ports {NAME*}]




# voltage properties for LVDS signals

#set_property IOSTANDARD LVDS [get_ports {NAME*}]
