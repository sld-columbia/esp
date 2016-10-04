-- =============================================================================
-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2013, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--  Project       : MMI64 (Module Message Interface)
--  Module/Entity : axi_p (Entity-Component/Package)
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  MMI64 Package with AXI definitions
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Global declarations package for module message interface.
package axi_pkg is

  --! AXI port width definitions
  constant AXI_LEN_WIDTH    : integer := 8;  --! AXI Burst length width.
  constant AXI_SIZE_WIDTH   : integer := 3;  --! AXI Burst size width.
  constant AXI_BURST_WIDTH  : integer := 2;  --! AXI Burst type width.
  constant AXI_LOCK_WIDTH   : integer := 1;  --! AXI Lock type width.
  constant AXI_CACHE_WIDTH  : integer := 4;  --! AXI Memory type width.
  constant AXI_PROT_WIDTH   : integer := 3;  --! AXI Protection type width.
  constant AXI_QOS_WIDTH    : integer := 4;  --! AXI Quality of Service width.
  constant AXI_REGION_WIDTH : integer := 4;  --! AXI Region identifier width.
  constant AXI_RESP_WIDTH   : integer := 2;  --! AXI User signal width.
  
  --! Internal control register width and field definitions
  constant AXI_CTRL_REG_WIDTH : integer := 64;
  
  subtype AXI_CTRL_REGION           is natural range  3  downto  0;
  subtype AXI_CTRL_QOS              is natural range  7  downto  4;
  subtype AXI_CTRL_PROT             is natural range  11 downto  8;
  subtype AXI_CTRL_CACHE            is natural range  15 downto  12;
  subtype AXI_CTRL_LOCK             is natural range  19 downto  16;
  subtype AXI_CTRL_BURST            is natural range  23 downto  20;
  subtype AXI_CTRL_SIZE             is natural range  27 downto  24;
  subtype AXI_CTRL_LEN              is natural range  35 downto  28;


--  --! Control register
--  AXI_SIZE_WIDTH   --! Always full burst (no unused bytes)
--  AXI_ID_WIDTH     --! Always same id
--  AXI_LOCK_WIDTH   --! Always normal access
--  AXI_CACHE_WIDTH  --! Device Non-bufferable
--  AXI_PROT_WIDTH   --! Secured, non priviledged data access
--  AXI_QOS_WIDTH    --! not participating
--  AXI_REGION_WIDTH --! Always default region region  
--  AXI_USER_WIDTH   --! Not used data
--  
--  --! Values comming from SW
--  AXI_ADDR_WIDTH --! Start address
--  AXI_LEN_WIDTH  --! Number of access connected to address
  
 
 
 
  --! Memory type. Signal indicates how transactions are required to progress through a system
  constant AWCACHE_ALLOCATE_BIT       : integer := 3; --! When asserted, the transaction must be looked up in a cache because it could have been previously allocated.
  constant AWCACHE_OTHER_ALLOCATE_BIT : integer := 2; --! When asserted, the transaction must be looked up in a cache because it could have been previously allocated 
                                                      --! in the cache by another transaction, either a read transaction or a transaction from another master
  constant AWCACHE_MODIFIABLE_BIT     : integer := 1; --! When asserted, the characteristics of the transaction can be modified and writes can be merged.
  constant AWCACHE_BUFFERABLE_BIT     : integer := 0; --! When deasserted, if both of AWCACHE[3:2] are deasserted, the write response must be given from the final destination.
                                                      --! When asserted, if both of AWCACHE[3:2] are deasserted, the write response can be given
                                                      --! from an intermediate point, but the write transaction is required to be made visible at the final destination in a timely manner.
                                                      --! When deasserted, if either of AWCACHE[3:2] is asserted, the write response can be given
                                                      --! from an intermediate point, but the write transaction is required to be made visible at the final destination in a timely manner.
                                                      --! When asserted, if either of AWCACHE[3:2] is asserted, the write response can be given
                                                      --! from an intermediate point. The write transaction is not required to be made visible at the final destination.
  
  --! Protection type
  constant PRIVILEGED_ACCESS_BIT       : integer := 0; --! '1'- Privileged access;  '0'- Unprivileged access
  constant SECURE_ACCESS_BIT           : integer := 1; --! '1'- Non-secure access;  '0'- Secure access
  constant DATA_ACCESS_BIT             : integer := 2; --! '1'- Instruction access; '0'- Data access
  
  --! Quality of Service, The protocol does not specify the exact use of the QoS identifier. This specification recommends that AxQOS is
  --                      used as a priority indicator for the associated write or read transaction. A higher value indicates a higher priority transaction.
  constant QOS_NOT_PARTICIPATING       : integer := 0; --! A default value of 0b0000 indicates that the interface is not participating in any QoS scheme
  
  --! Region identifier.
  constant AWREGION_DEFAULT             : integer := 0; --! Default value for Region identifier
  
  
  
  --! Burst size (Bytes in one transfer)
  constant AXI4_BURST_SIZE_1    : integer := 0;
  constant AXI4_BURST_SIZE_2    : integer := 1;
  constant AXI4_BURST_SIZE_4    : integer := 2;
  constant AXI4_BURST_SIZE_8    : integer := 3;
  constant AXI4_BURST_SIZE_16   : integer := 4;
  constant AXI4_BURST_SIZE_32   : integer := 5;
  constant AXI4_BURST_SIZE_64   : integer := 6;
  constant AXI4_BURST_SIZE_128  : integer := 7;
  
  --! Burst type
  constant AXI4_BURST_FIXED    : integer := 0; --! Same addres for every transfer (FIFO access)
  constant AXI4_BURST_INCR     : integer := 1; --! Incrementing. In an incrementing burst, the address for each transfer in the burst is an increment of the address for the previous transfer. 
                                               --!  The increment value depends on the size of the transfer. For example, the address for each transfer in a burst with a size of four bytes is the previous address plus four.
  constant AXI4_BURST_WRAP     : integer := 2; --! A wrapping burst is similar to an incrementing burst, except that the address wraps around to a lower address if an upper address limit is reached.
  
  --! Response
  constant AXI4_RESP_OKAY      : integer := 0; --! Normal access success. Indicates that a normal access has been successful. Can also indicate an exclusive access has failed
  constant AXI4_RESP_EXOKAY    : integer := 1; --! Exclusive access okay. Indicates that either the read or write portion of an exclusive access has been successful
  constant AXI4_RESP_SLVERR    : integer := 2; --! Slave error. Used when the access has reached the slave successfully, but the slave wishes to return an error condition to the originating master
  constant AXI4_RESP_DECERR    : integer := 3; --! Decode error. Generated, typically by an interconnect component, to indicate that there is no slave at the transaction address
  
  

end axi_pkg;
