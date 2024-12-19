local config_setting = {
	[ "minclientversion" ] = "1.5.6",
	[ "server_logic_fps_limit" ] = 0,
	[ "busy_sleep_time" ] = 0,
	[ "idle_sleep_time" ] = 0,
	[ "player_sync_interval" ] = 200,
	[ "lightweight_sync_interval" ] = 1500,
	[ "ped_sync_interval" ] = 400,
	[ "unoccupied_vehicle_sync_interval" ] = 1000,
	[ "camera_sync_interval" ] = 500,
	[ "keysync_mouse_sync_interval" ] = 100,
	[ "keysync_analog_sync_interval" ] = 100,
	[ "bullet_sync" ] = 0,
	[ "donkey_work_interval" ] = 1000,
	[ "vehext_percent" ] = 50,
	[ "fpslimit" ] = 61,
	[ "bandwidth_reduction" ] = "maximum"
};

addEventHandler( "onResourceStart", resourceRoot,
	function( )

		setMapName( "Los Santos" );
		setGameType( "RUST" );

		for setting, value in pairs( config_setting ) do

			-- setServerConfigSetting( setting, value, true );

		end

		Database.setup( )

		Loot.setup( );
		Accounts.setup( );
		Inventory.setup( );
		Building.setup( );
		Wasted.setup( );

		Building.load( );

	end
);

addEvent( "onUIGenerated", true );
addEventHandler( "onUIGenerated", root,
	function( player )
		
		Inventory.load( player );

	end
);