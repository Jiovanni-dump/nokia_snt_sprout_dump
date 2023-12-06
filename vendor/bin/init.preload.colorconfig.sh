#!/vendor/bin/sh
# wangxuguang add for preload color config xml

#if [ ! -f "/data/vendor/display/exist" ]; then
    echo "preloading color config ..." 

	PP_CALIB_DATA0=cablconfig
    PP_CALIB_DATA1=qdcm_calib_data_nt36672c_tcl_fhd_plus_video_mode_dsi_panel

    cp /vendor/etc/$PP_CALIB_DATA0 /data/vendor/display/$PP_CALIB_DATA0.xml
	cp /vendor/etc/$PP_CALIB_DATA1 /data/vendor/display/$PP_CALIB_DATA1.xml

    chmod 660 /data/vendor/display/$PP_CALIB_DATA0.xml
	chmod 660 /data/vendor/display/$PP_CALIB_DATA1.xml

    chown system.graphics /data/vendor/display/$PP_CALIB_DATA0.xml
	chown system.graphics /data/vendor/display/$PP_CALIB_DATA1.xml

    echo "done" > /data/vendor/display/exist
    chmod 777 /data/vendor/display/exist
    sync
    echo "preloading color config done"

#fi
