addEventHandler( "onClientResourceStop", root,
	function( stopper )

		if ( stopper == resourceRoot ) then

			RequestsModel.stop( );

		end

	end
);