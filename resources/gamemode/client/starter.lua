screen = { guiGetScreenSize( ) };

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )

		toggleControl( "next_weapon", false );
		toggleControl( "previous_weapon", false );

		setAmbientSoundEnabled( "general", false );
		setAmbientSoundEnabled( "gunfire", false );
		
		Loot.setup( );

		RequestsModel.setup( );
		Models.replace( );

		Building.setup( );
		Weapons.setup( );

		Framework.setup( );

		Login.setup( );

		setTimer( function( )

			if ( localPlayer:getData( "character > logged" ) ) then

				local attributes = { "hunger", "thirst" };

				for _, attribute in ipairs( attributes ) do

					local value = localPlayer:getData( "character > " .. attribute );

					if ( value ) then

						local loss = random( 10 ) / 10;

						if ( value - loss >= 0 ) then

							localPlayer:setData( "character > " .. attribute, value - loss );

						else

							if ( value > 0 ) then

								localPlayer:setData( "character > " .. attribute, 0 );

							end

							triggerServerEvent( "utils > set_health", localPlayer, localPlayer, localPlayer:getHealth( ) - 0.3 );

						end

					end

				end

			end

		end, 15 * 1000, 0 );

	end
);

_getCursorPosition = getCursorPosition;
function getCursorPosition( )

	local cursor = { -screen[ 1 ], -screen[ 2 ] };

	if ( isCursorShowing( ) ) then

		cursor = { _getCursorPosition( ) };
		cursor[ 1 ] = cursor[ 1 ] * screen[ 1 ];
		cursor[ 2 ] = cursor[ 2 ] * screen[ 2 ];

	end

	return cursor[ 1 ], cursor[ 2 ];

end