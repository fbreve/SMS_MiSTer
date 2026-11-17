--
-- FeedbackMemory.vhd
--
-- Copyright (c) 2006 Mitsutaka Okazaki (brezza@pokipoki.org)
-- All rights reserved.
--
-- Redistribution and use of this source code or any derivative works, are
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial
--    product or activity without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.VM2413.ALL;

--
-- This module represents a store for feedback data of all OPLL channels. The feedback
-- data is written by the OutputGenerator module. Then the value written is
-- read from the Operator module.
--
entity FeedbackMemory is port (
  clk    : in std_logic;
  reset  : in std_logic;
  wr     : in std_logic;
  waddr  : in CH_TYPE;
  wdata  : in SIGNED_LI_TYPE;
  raddr  : in CH_TYPE;
  rdata  : out SIGNED_LI_TYPE
);
end FeedbackMemory;

library ieee;use ieee.numeric_std.all;
architecture mapped of FeedbackMemory is
component FeedbackMemory_gate is port(clk,reset,wr:in std_logic;waddr:in std_logic_vector(3 downto 0);wdata:in std_logic_vector(9 downto 0);raddr:in std_logic_vector(3 downto 0);rdata:out std_logic_vector(9 downto 0));end component;
signal wa,ra:std_logic_vector(3 downto 0);signal wd,rd:std_logic_vector(9 downto 0);
begin wa<=std_logic_vector(to_unsigned(waddr,4));ra<=std_logic_vector(to_unsigned(raddr,4));wd<=CONV_SIGNED_LI_VECTOR(wdata);rdata<=CONV_SIGNED_LI(rd);u:FeedbackMemory_gate port map(clk,reset,wr,wa,wd,ra,rd);end;
