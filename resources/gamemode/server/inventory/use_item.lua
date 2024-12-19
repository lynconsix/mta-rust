Inventory.block_reload = { };
Inventory.items_functions = { };

-- FUNCTIONS;

Inventory.items_functions[ 2 ] = function( player, item )

	if ( not isElement( player ) ) then return; end

	if ( not player:getData( "character > building" ) ) then

		if ( player:getData( "character > weapon" ) ) then

			Inventory.unequipWeapon( player );

		end

		player:setData( "character > building", true );
		triggerClientEvent( player, "building > toggle", player, true );
		createNotification( player, "Construcion mode on", 2 );

	else

		player:setData( "character > building", false );
		triggerClientEvent( player, "building > toggle", player, false );
		createNotification( player, "Construcion mode off", 2 );

	end

end

Inventory.items_functions[ 14 ] = function( player, item )

	if ( not player:getData( "character > tool" ) ) then

		if ( player:getData( "character > weapon" ) ) then

			Inventory.unequipWeapon( player );

		end

		player:setData( "character > tool", item );
		giveWeapon( player, ITEMS[ item ].weapon.mta_id, 100, true );

	else

		player:setData( "character > tool", false );
		takeAllWeapons( player );

	end

end

Inventory.items_functions[ 15 ] = Inventory.items_functions[ 14 ];
Inventory.items_functions[ 16 ] = Inventory.items_functions[ 14 ];

-- END FUNCTIONS;

function Inventory.useItem( player, slot )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return;

	end

	local item = Inventory.players[ player ].items[ slot ];
	if ( item ) then

		item = item.item;
		local item_weapon_data = ITEMS[ item ].weapon

		if ( item_weapon_data ) then

			if ( not player:getData( "character > weapon" ) ) then

				if ( Inventory.players[ player ].items[ slot ].ammo <= 0 ) then

					local ammo = Inventory.getAmmo( player, item_weapon_data.ammo_id );

					if ( ammo ) then

						if ( Inventory.players[ player ].items[ ammo ].ammount > item_weapon_data.max_ammo ) then

							Inventory.updateAmmo( player, slot, item_weapon_data.max_ammo );
							Inventory.updateAmmount( player, ammo, Inventory.players[ player ].items[ ammo ].ammount - item_weapon_data.max_ammo );

						else

							Inventory.updateAmmo( player, slot, Inventory.players[ player ].items[ ammo ].ammount );
							Inventory.takeItem( player, ammo );

						end

						Inventory.equipWeapon( player, slot, item );

						if ( player:getData( "character > building" ) ) then

							player:setData( "character > building", false );
							triggerClientEvent( player, "building > toggle", player, false );
							createNotification( player, "Construcion mode off", 2 );

						end

						if ( player:getData( "character > tool" ) ) then

							player:setData( "character > tool", false );

						end

					else

						createNotification( player, "Without ammo", 3 );

					end

				else

					Inventory.equipWeapon( player, slot, item );

					if ( player:getData( "character > building" ) ) then

						player:setData( "character > building", false );
						triggerClientEvent( player, "building > toggle", player, false );
						createNotification( player, "Construcion mode off", 2 );

					end

					if ( player:getData( "character > tool" ) ) then

						player:setData( "character > tool", false );

					end

				end

			else

				Inventory.unequipWeapon( player );

			end

		elseif ( ITEMS[ item ].food ) then

			local used = false;
			local attributes = { [ "hunger" ] = ITEMS[ item ].hunger, [ "thirst" ] = ITEMS[ item ].thirst };

			for k, v in pairs( attributes ) do

				if ( player:getData( "character > " .. k ) < 100 and player:getData( "character > " .. k ) >= 0 ) then

					player:setData( "character > " .. k, max( min( player:getData( "character > " .. k ) + v, 100 ), 0 ) );
					used = true;

				end

			end

			if ( used ) then

				Inventory.updateAmmount( player, slot, Inventory.players[ player ].items[ slot ].ammount - 1 );

			end

		else

			local item_function = Inventory.items_functions[ item ];

			if ( not item_function ) then return; end

			item_function( player, item );

		end

	end

end

function Inventory.weaponUpdateAttach( player, item, attached )

	local item_weapon = ITEMS[ item ].weapon;
	if ( not item_weapon ) then 

		return;

	end

	local model_id = Inventory.getPreviewModelId( player, item );
	local preview_element = Inventory.players[ player ].preview_objects[ model_id ];

	if ( preview_element and isElement( preview_element ) ) then

		local preview_object = ITEMS[ item ].preview_object;
		if ( attached ) then
	
			if ( item_weapon.custom_id ) then
	
				if ( not isElementVisibleTo( preview_element, root ) ) then
	
					setElementVisibleTo( preview_element, root, true );
	
				end
	
				exports[ "pAttach" ]:setDetails( preview_element, player, "weapon", 0, 0, 0, 0, 0, 0 );
	
			else
	
				if ( isElementVisibleTo( preview_element, root ) ) then
	
					setElementVisibleTo( preview_element, root, false );
	
				end
	
				exports[ "pAttach" ]:detach( preview_element );
				setElementPosition( preview_element, 0, 0, -50 );
	
			end
	
		else
	
			if ( item_weapon.custom_id ) then
	
				exports[ "pAttach" ]:setDetails( preview_element, player, preview_object.bone, preview_object.pos[ 1 ], preview_object.pos[ 2 ], preview_object.pos[ 3 ], preview_object.r[ 1 ], preview_object.r[ 2 ], preview_object.r[ 3 ] );
	
			else
	
				exports[ "pAttach" ]:attach( preview_element, player, preview_object.bone, preview_object.pos[ 1 ], preview_object.pos[ 2 ], preview_object.pos[ 3 ], preview_object.r[ 1 ], preview_object.r[ 2 ], preview_object.r[ 3 ] );
	
			end
	
		end
	
		if ( item_weapon.custom_id ) then
	
			setElementData( preview_element, "engine > custom_id", model_id );
	
		else
	
			setElementModel( preview_element, model_id );
	
		end

	end

	return item_weapon;

end

function Inventory.equipWeapon( player, slot, item )

	takeAllWeapons( player );

	local item_weapon = Inventory.weaponUpdateAttach( player, item, true );
	Inventory.players[ player ].items[ slot ].active = true;

	giveWeapon( player, item_weapon.mta_id, 100, true );
	player:setData( "character > weapon", slot );

	toggleControl( player, "fire", true );
	toggleControl( player, "aim_weapon", true );

	bindKey( player, "r", "down", Inventory.reloadWeapon );

end

function Inventory.unequipWeapon( player, unattach )

	local slot = player:getData( "character > weapon" );
	if ( slot ) then

		Inventory.players[ player ].items[ slot ].active = false;
		takeAllWeapons( player );
		player:removeData( "character > weapon" );

		if ( not unattach ) then

			Inventory.weaponUpdateAttach( player, Inventory.players[ player ].items[ slot ].item, false );

		end

	end

	unbindKey( player, "r", "down", Inventory.reloadWeapon, true );
	
	toggleControl( player, "fire", true );
	toggleControl( player, "aim_weapon", true );

end

function Inventory.reloadWeapon( player, k )

	if ( Inventory.block_reload[ player ] and ( getTickCount( ) - Inventory.block_reload[ player ] ) < 2500 ) then

		return;

	end

	if ( k ) then

		Inventory.block_reload[ player ] = getTickCount( );
		toggleControl( player, "fire", false );
		toggleControl( player, "aim_weapon", false );

	end

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return;

	end

	local weapon_data = player:getData( "character > weapon" );
	if ( weapon_data ) then

		local item = Inventory.players[ player ].items[ weapon_data ];
		local item_weapon_data = ITEMS[ item.item ].weapon;

		if ( item and item.ammo < item_weapon_data.max_ammo ) then

			item = item.item;
			local ammo = Inventory.getAmmo( player, item_weapon_data.ammo_id );

			if ( ammo ) then

				if ( Inventory.players[ player ].items[ weapon_data ].ammo > 0 ) then

					if ( Inventory.players[ player ].items[ ammo ].ammount > ( item_weapon_data.max_ammo - Inventory.players[ player ].items[ weapon_data ].ammo ) ) then

						Inventory.updateAmmount( player, ammo, Inventory.players[ player ].items[ ammo ].ammount - ( item_weapon_data.max_ammo - Inventory.players[ player ].items[ weapon_data ].ammo ) );
						Inventory.updateAmmo( player, weapon_data, item_weapon_data.max_ammo );

					else

						Inventory.updateAmmo( player, weapon_data, Inventory.players[ player ].items[ weapon_data ].ammo + Inventory.players[ player ].items[ ammo ].ammount );
						Inventory.takeItem( player, ammo );

					end

				else

					if ( Inventory.players[ player ].items[ ammo ].ammount > item_weapon_data.max_ammo ) then

						Inventory.updateAmmo( player, weapon_data, item_weapon_data.max_ammo );
						Inventory.updateAmmount( player, ammo, Inventory.players[ player ].items[ ammo ].ammount - item_weapon_data.max_ammo );

					else

						Inventory.updateAmmo( player, weapon_data, Inventory.players[ player ].items[ ammo ].ammount );
						Inventory.takeItem( player, ammo );

					end

				end

				setWeaponAmmo( player, item_weapon_data.mta_id, 100 );
				setTimer( reloadPedWeapon, 500, 1, player );

			elseif ( Inventory.players[ player ].items[ weapon_data ].ammo == 0 ) then

				Inventory.unequipWeapon( player );
				Inventory.updateAmmo( player, weapon_data, 0 );

			end

		end

	end

	setTimer( function( player )

		toggleControl( player, "fire", true );
		toggleControl( player, "aim_weapon", true );

	end, 2500, 1, player );

end

function Inventory.getAmmo( player, item )

	if ( ( not Inventory.players[ player ] ) or ( not Inventory.players[ player ].items ) ) then

		return;

	end

	for k, v in pairs( Inventory.players[ player ].items ) do

		if ( v.item == item ) then

			return k;

		end

	end

end