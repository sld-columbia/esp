-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2011-2013, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--  Project       : ProDesign generic HDL components
--  Module/Entity : RTL Template library
--  Author        : Sebastian Flügel
--  Contact       : sebastian.fluegel@prodesign-europe.com
--  Description   :
--                  synthesizable functions
-- =============================================================================


package rtl_templates is
  function Log2(constant W : integer) return integer;
end package rtl_templates;

package body rtl_templates is
  function Log2(constant W : integer) return integer is
  begin
    for i in 0 to 31 loop
      if 2**i>=W then return i; end if;
    end loop;
    return 32;
  end function Log2;
end package body rtl_templates;
