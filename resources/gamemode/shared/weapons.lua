--[[

	WEAPONS_PROPERTIES table{ 

		[ mta_id int ] table{ 

			sound table{ path table{ [ item_id ] soundpath string }, max_distance float }, 
			attachments { [ item_id ] table{ [ attachname string ] table{ x float, y float, z float, rx float, ry float, rz float } } }, 

			properties table{ https://wiki.multitheftauto.com/wiki/SetWeaponProperty }, 
			damage table{ [ item_id ] table{ headshot float, damage float } }, 
			recoilpattern table{ [ item_id ] table{ float x, float y, float z } }

			max_life_by_bullet float

		}

	}

]]--

WEAPONS_PROPERTIES = { 

	[ 30 ] = { 

		sound = { 

			path = { 

				[ 3 ] = "ak47.wav" 

			}, 

			max_distance = 200 

		}, 

		attachments = { 

			[ 3 ] = { 

				-- [ "Supressor" ] = { -0.115, -0.05, 0.763, 0, 0, -5 }, 

			} 

		}, 


		properties = { 
			weapon_range = 190, 
			target_range = 190, 
			damage = 5, 
			anim_loop_stop = 0.32, 
			maximum_clip_ammo = 1000 
		},

		damage = {

			[ 3 ] = { 

				headshot = 75, 
				damage = 18

			}

		}, 

		recoilpattern = { 

			[ 1 ] = { 0.5, 10, 80 }

		}, 

		max_life_by_bullet = 450

	}

}

function getWeaponProperties( mta_id )

	return WEAPONS_PROPERTIES[ mta_id ]

end