addEventHandler( "onPlayerQuit", root,
	function( )

		Accounts.logout( source, "Logout" );
		source:removeData( "waiting_response" );
		unbindKey( source, "r", "down", Inventory.reloadWeapon );

	end
);