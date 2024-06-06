QUIET_MAKE          = @echo '   ' MAKE $@;
QUIET_CP            = @echo '   ' CP $@;
QUIET_RM            = @echo '   ' RM $@;

HLS_PATH = divider_hls/virtex7
SRCNAME = divider_hls_Div_13Ux7U_6U_4
OUTNAME = token_pm_divider_hls

divider_hls:
	$(QUIET_MAKE)make -C $(HLS_PATH) hls_all
	$(QUIET_CP)cp $(HLS_PATH)/bdw_work/modules/divider_hls/BASIC/v_rtl/$(SRCNAME).v $(OUTNAME).v
	@sed -i 's/$(SRCNAME)/$(OUTNAME)/g' $(OUTNAME).v

clean:
	$(QUIET_MAKE)make -C $(HLS_PATH) clean
	$(QUIET_RM)rm -f $(OUTNAME).v

all: divider_hls

.PHONY: divider_hls clean
