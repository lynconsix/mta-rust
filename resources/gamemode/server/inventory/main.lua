addEvent( "inventory > trade_slot", true );
addEvent( "inventory > trade_usedin", true );
addEvent( "inventory > set_usedin", true );
addEvent( "inventory > remove_usedin", true );
addEvent( "inventory > update_ammount", true );
addEvent( "inventory > update_life", true );
addEvent( "inventory > update_ammo", true );
addEvent( "inventory > take_item", true );
addEvent( "inventory > give_item", true );
addEvent( "inventory > use_item", true );
addEvent( "inventory > reload_weapon", true );

Inventory = { };
Inventory.players = { };

function Inventory.setup( )

	exec( "CREATE TABLE IF NOT EXISTS items ( serial TEXT, items LONGTEXT )" );

	addEventHandler( "inventory > trade_slot", root, Inventory.tradeSlot );
	addEventHandler( "inventory > trade_usedin", root, Inventory.tradeUsedIn );
	addEventHandler( "inventory > set_usedin", root, Inventory.setUsedIn );
	addEventHandler( "inventory > remove_usedin", root, Inventory.removeUsedIn );
	addEventHandler( "inventory > update_ammount", root, Inventory.updateAmmount );
	addEventHandler( "inventory > update_life", root, Inventory.updateLife );
	addEventHandler( "inventory > update_ammo", root, Inventory.updateAmmo );
	addEventHandler( "inventory > take_item", root, Inventory.takeItem );
	addEventHandler( "inventory > give_item", root, Inventory.giveItem );
	addEventHandler( "inventory > use_item", root, Inventory.useItem );
	addEventHandler( "inventory > reload_weapon", root, Inventory.reloadWeapon );

end

function Inventory.load( player )

	local query = query( "SELECT items FROM items WHERE serial = ?", player.serial );
	if ( maxn( query ) == 0 ) then

		exec( "INSERT INTO items ( serial, items ) VALUES ( ?, ? )", player.serial, toJSON( { } ) );
		query = { { items = toJSON( { } ) } }; 

	end

	Inventory.players[ player ] = { };
	Inventory.players[ player ].items = Inventory.debugTable( fromJSON( query[ 1 ][ "items" ] ) );
	Inventory.players[ player ].preview_objects = { };

	for k, v in pairs( Inventory.players[ player ].items ) do

		Inventory.attachItem( player, k );

	end

	triggerClientEvent( player, "inventory > load_items", player, Inventory.players[ player ].items );

end

function Inventory.reset( player )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return;

	end

	Inventory.players[ player ].items = { };

	for k, v in pairs( Inventory.players[ player ].preview_objects ) do

		if ( isElement( v ) ) then

			exports[ "pAttach" ]:detach( v );
			destroyElement( v );

		end

	end

	for k, v in pairs( { { "player_torso", "torso", 0 }, { "player_face", "head", 0 }, { "player_legs", "legs", 0 }, { "foot", "feet", 0 } } ) do

		player:addClothes( unpack( v ) );

	end

	Inventory.unequipWeapon( player );

	if ( player:getData( "character > building" ) ) then

		player:setData( "character > building", false );
		triggerClientEvent( player, "building > toggle", player, false );

	end

	triggerClientEvent( player, "inventory > load_items", player, Inventory.players[ player ].items );
	triggerClientEvent( player, "inventory > reset_items", player );

end

function Inventory.save( player )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return player:removeData( "waiting_response" );

	end

	exec( "UPDATE items SET items = ? WHERE serial = ?", toJSON( Inventory.players[ player ].items ), player.serial );

end

function Inventory.updateItem( player, i, item, old_usedin )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return;

	end

	triggerClientEvent( player, "inventory > update_item", player, i, item, old_usedin );

end

function Inventory.attachItem( player, i )

	local item = Inventory.findItemFromSlot( player, i );
	if ( not item ) then

		return;

	end

	item = item.item

	local preview_object = ITEMS[ item ].preview_object;

	if ( preview_object ) then

		local model_id = Inventory.getPreviewModelId( player, item );

		if ( not isElement( Inventory.players[ player ].preview_objects[ model_id ] ) ) then

			Inventory.players[ player ].preview_objects[ model_id ] = createObject( 355, 0, 0, 0 );
			exports[ "pAttach" ]:attach( Inventory.players[ player ].preview_objects[ model_id ], player, preview_object.bone, preview_object.pos[ 1 ], preview_object.pos[ 2 ], preview_object.pos[ 3 ], preview_object.r[ 1 ], preview_object.r[ 2 ], preview_object.r[ 3 ] );

		end

		if ( preview_object.custom_id ) then

			setElementData( Inventory.players[ player ].preview_objects[ model_id ], "engine > custom_id", model_id );

		else

			setElementModel( Inventory.players[ player ].preview_objects[ model_id ], preview_object.model );

		end

	end

end

function Inventory.giveItem( player, item, ammount, life, slot, dont_show_notification )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return player:removeData( "waiting_response" );

	end

	ammount = ammount or 1
	life = life or 100

	local stackable = ITEMS[ item ].stackable;
	local free_sloot = Inventory.getFreeSlot( player );

	if ( stackable ) then

		if ( slot ) then

			Inventory.players[ player ].items[ slot ] = {

				item 		= item,
				ammount 	= ammount,
				life 		= life,
				used_in 	= false,
				ammo 		= 0,
				active 		= false

			};

			if ( ITEMS[ item ].preview_object ) then

				if ( not isElement( Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ] ) ) then

					Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ] = createObject( ITEMS[ item ].preview_object.model, 0, 0, 0 );
					exports[ "pAttach" ]:attach( Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ], player, ITEMS[ item ].preview_object.bone, ITEMS[ item ].preview_object.pos[ 1 ], ITEMS[ item ].preview_object.pos[ 2 ], ITEMS[ item ].preview_object.pos[ 3 ], ITEMS[ item ].preview_object.r[ 1 ], ITEMS[ item ].preview_object.r[ 2 ], ITEMS[ item ].preview_object.r[ 3 ] );

				end

			end

			Inventory.updateItem( player, slot, Inventory.players[ player ].items[ slot ] );

			if ( not dont_show_notification ) then

				createNotification( player, ITEMS[ item ].name .. " +" .. ammount, 1 );

			end

			return true;

		else

			local find_item = Inventory.findItem( player, item );
			if ( find_item ) then

				Inventory.players[ player ].items[ find_item ].ammount = Inventory.players[ player ].items[ find_item ].ammount + ammount;

				if ( not dont_show_notification ) then

					createNotification( player, ITEMS[ item ].name .. " +" .. ammount, 1 );

				end

				Inventory.updateItem( player, find_item, Inventory.players[ player ].items[ find_item ] );

				return true;

			else

				if ( free_sloot ) then

					Inventory.players[ player ].items[ free_sloot ] = {

						item 		= item,
						ammount 	= ammount,
						life 		= life,
						used_in 	= false,
						ammo 		= 0,
						active 		= false

					};

					if ( ITEMS[ item ].preview_object ) then

						if ( not isElement( Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ] ) ) then

							Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ] = createObject( ITEMS[ item ].preview_object.model, 0, 0, 0 );
							exports[ "pAttach" ]:attach( Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ], player, ITEMS[ item ].preview_object.bone, ITEMS[ item ].preview_object.pos[ 1 ], ITEMS[ item ].preview_object.pos[ 2 ], ITEMS[ item ].preview_object.pos[ 3 ], ITEMS[ item ].preview_object.r[ 1 ], ITEMS[ item ].preview_object.r[ 2 ], ITEMS[ item ].preview_object.r[ 3 ] );

						end

					end

					Inventory.updateItem( player, free_sloot, Inventory.players[ player ].items[ free_sloot ] );

					if ( not dont_show_notification ) then

						createNotification( player, ITEMS[ item ].name .. " +" .. ammount, 1 );

					end

					return true;

				end

			end

		end

	else

		if ( slot ) then

			Inventory.players[ player ].items[ slot ] = {

				item 		= item,
				ammount 	= ammount,
				life 		= life,
				used_in 	= false,
				ammo 		= 0,
				active 		= false

			};

			if ( ITEMS[ item ].preview_object ) then

				if ( not isElement( Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ] ) ) then

					Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ] = createObject( ITEMS[ item ].preview_object.model, 0, 0, 0 );
					exports[ "pAttach" ]:attach( Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ], player, ITEMS[ item ].preview_object.bone, ITEMS[ item ].preview_object.pos[ 1 ], ITEMS[ item ].preview_object.pos[ 2 ], ITEMS[ item ].preview_object.pos[ 3 ], ITEMS[ item ].preview_object.r[ 1 ], ITEMS[ item ].preview_object.r[ 2 ], ITEMS[ item ].preview_object.r[ 3 ] );

				end

			end

			Inventory.updateItem( player, slot, Inventory.players[ player ].items[ slot ] );

			if ( not dont_show_notification ) then

				createNotification( player, ITEMS[ item ].name .. " +" .. ammount, 1 );

			end

			return true;

		elseif ( free_sloot ) then

			Inventory.players[ player ].items[ free_sloot ] = {

				item 		= item,
				ammount 	= ammount,
				life 		= life,
				used_in 	= false,
				ammo 		= 0,
				active 		= false

			};

			if ( ITEMS[ item ].preview_object ) then

				if ( not isElement( Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ] ) ) then

					Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ] = createObject( ITEMS[ item ].preview_object.model, 0, 0, 0 );
					exports[ "pAttach" ]:attach( Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ], player, ITEMS[ item ].preview_object.bone, ITEMS[ item ].preview_object.pos[ 1 ], ITEMS[ item ].preview_object.pos[ 2 ], ITEMS[ item ].preview_object.pos[ 3 ], ITEMS[ item ].preview_object.r[ 1 ], ITEMS[ item ].preview_object.r[ 2 ], ITEMS[ item ].preview_object.r[ 3 ] );

				end

			end

			Inventory.updateItem( player, free_sloot, Inventory.players[ player ].items[ free_sloot ] );

			if ( not dont_show_notification ) then

				createNotification( player, ITEMS[ item ].name .. " +" .. ammount, 1 );

			end

			return true;

		end

	end

	player:removeData( "waiting_response" );

end

function Inventory.updateAmmount( player, i, ammount )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return player:removeData( "waiting_response" );

	end

	if ( ammount > 0 ) then

		Inventory.players[ player ].items[ i ].ammount = ammount;
		Inventory.updateItem( player, i, Inventory.players[ player ].items[ i ] );

	else

		Inventory.takeItem( player, i );

	end

	player:removeData( "waiting_response" );

end

function Inventory.updateLife( player, i, life )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return player:removeData( "waiting_response" );

	end

	if ( life > 0 ) then

		Inventory.players[ player ].items[ i ].life = life;
		Inventory.updateItem( player, i, Inventory.players[ player ].items[ i ] );

	else

		Inventory.takeItem( player, i );

	end

	player:removeData( "waiting_response" );

end

function Inventory.updateAmmo( player, i, ammo )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return player:removeData( "waiting_response" );

	end

	if ( ammo >= 0 ) then

		Inventory.players[ player ].items[ i ].ammo = ammo;
		Inventory.updateItem( player, i, Inventory.players[ player ].items[ i ] );

	end

	player:removeData( "waiting_response" );

end

function Inventory.takeItem( player, i )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return player:removeData( "waiting_response" );

	end

	local item = Inventory.players[ player ].items[ i ].item;

	local weapon_data = player:getData( "character > weapon" );

	if ( weapon_data and weapon_data == i ) then

		Inventory.unequipWeapon( player, true );

	end

	if ( ITEMS[ item ].preview_object ) then

		if ( isElement( Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ] ) and Inventory.isSinglePreviewModel( player, item ) ) then

			exports[ "pAttach" ]:detach( Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ] );
			destroyElement( Inventory.players[ player ].preview_objects[ ITEMS[ item ].preview_object.model ] );

		end

	end

	Inventory.players[ player ].items[ i ] = nil;
	Inventory.updateItem( player, i, false );

	player:removeData( "waiting_response" );

end

function Inventory.tradeSlot( player, moving, on )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return player:removeData( "waiting_response" );

	end

	local weapon_data = player:getData( "character > weapon" );

	if ( weapon_data ) then

		if ( weapon_data == on ) then

			player:setData( "character > weapon", moving );

		elseif ( weapon_data == moving ) then

			player:setData( "character > weapon", on );

		end

	end

	local backup = { Inventory.players[ player ].items[ on ], Inventory.players[ player ].items[ moving ] };
	Inventory.players[ player ].items[ moving ], Inventory.players[ player ].items[ on ] = backup[ 1 ], backup[ 2 ];
	Inventory.updateItem( player, moving, Inventory.players[ player ].items[ moving ] );
	Inventory.updateItem( player, on, Inventory.players[ player ].items[ on ] );

	player:removeData( "waiting_response" );

end

function Inventory.tradeUsedIn( player, moving, on, type, s )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return player:removeData( "waiting_response" );

	end

	if ( Inventory.players[ player ].items[ on ] ) then

		local backup = { Inventory.players[ player ].items[ on ].used_in, Inventory.players[ player ].items[ moving ].used_in };
		Inventory.players[ player ].items[ moving ].used_in, Inventory.players[ player ].items[ on ].used_in = backup[ 1 ], backup[ 2 ];
		Inventory.updateItem( player, on, Inventory.players[ player ].items[ on ] );
		Inventory.updateItem( player, moving, Inventory.players[ player ].items[ moving ] );

	else

		local backup = Inventory.players[ player ].items[ moving ].used_in;
		Inventory.players[ player ].items[ moving ].used_in = { type, s };
		Inventory.updateItem( player, moving, Inventory.players[ player ].items[ moving ], backup );

	end

	player:removeData( "waiting_response" );

end

function Inventory.usedInResponse( player, ready, i, usein )

	local item = Inventory.findItemFromSlot( player, i );
	if ( not item ) then

		return;

	end

	if ( ready == "use" ) then

		if ( usein == "clothes" ) then

			local clothe = ITEMS[ item.item ].clothes;
			if ( clothe.clothe ) then

				clothe = clothe.clothe;
				player:addClothes( unpack( clothe ) );

			end

		end

	elseif ( ready == "remove" ) then

		if ( usein == "clothes" ) then

			local clothe = ITEMS[ item.item ].clothes;
			if ( clothe.clothe ) then

				clothe = clothe.clothe;
				player:removeClothes( clothe[ 3 ], clothe[ 1 ], clothe[ 2 ] );

			end

		end

	end

end

function Inventory.setUsedIn( player, usein, moving, on )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return player:removeData( "waiting_response" );

	end

	local backup = Inventory.players[ player ].items[ moving ].used_in;
	Inventory.players[ player ].items[ moving ].used_in = { usein, on };

	Inventory.updateItem( player, moving, Inventory.players[ player ].items[ moving ], backup );
	Inventory.usedInResponse( player, "use", moving, usein );

	player:removeData( "waiting_response" );

end

function Inventory.removeUsedIn( player, i, usein )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return player:removeData( "waiting_response" );

	end

	local backup = Inventory.players[ player ].items[ i ].used_in;
	Inventory.players[ player ].items[ i ].used_in = false;

	Inventory.updateItem( player, i, Inventory.players[ player ].items[ i ], backup );
	Inventory.usedInResponse( player, "remove", i, usein );

	player:removeData( "waiting_response" );

end

function Inventory.getFreeSlot( player )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return;

	end

	for i=1, ( INVENTORY_SLOTS.INVENTORY.c * INVENTORY_SLOTS.INVENTORY.r ) do

		if ( not Inventory.players[ player ].items[ i ] ) then

			return i;

		end

	end

	return;

end

function Inventory.getPreviewModelId( player, item )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return;

	end

	local preview_object = ITEMS[ item ].preview_object;
	if ( preview_object ) then

		local model = preview_object.model

		if ( preview_object.custom_id ) then

			model = preview_object.custom_id;
		end

		return model;

	end

end
	
function Inventory.findItemFromSlot( player, slot )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return;

	end

	if ( Inventory.players[ player ].items[ slot ] ) then

		return Inventory.players[ player ].items[ slot ];

	end

	return false;

end

function Inventory.findItem( player, item )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return;

	end

	for k, v in pairs( Inventory.players[ player ].items ) do

		if ( v.item == item ) then

			return k;

		end

	end

end

function Inventory.isSinglePreviewModel( player, item )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return;

	end

	if ( ITEMS[ item ].preview_object ) then

		local preview = ITEMS[ item ].preview_object.model;

		for k, v in pairs( Inventory.players[ player ].items ) do

			if ( ITEMS[ v.item ].preview_object and ITEMS[ v.item ].preview_object.model == ITEMS[ item ].preview_object.model ) then

				return false;

			end

		end

	end

	return true;

end

function Inventory.debugTable( debuggingtable )

	local returntable = { };

	for k, v in pairs( debuggingtable ) do

		if ( tonumber( k ) ) then

			returntable[ tonumber( k ) ] = v;
			returntable[ tonumber( k ) ].active = false;

		end

	end

	return returntable;

end

addCommandHandler( "i",
	function( player, cmd, id, ammount )

		Inventory.giveItem( player, tonumber( id ), tonumber( ammount ), 100 );

	end
);