INVENTORY_SLOTS = { INVENTORY = { r = 5, c = 6 }, CLOTHES = 6, SIZE = 60 };

--[[

	ITEMS table{ 

		name string, 
		description string, 
		stackable boolean, 
		weapon table{ mta_id, ammo_id int, show_ammo boolean, max_ammo int }, 
		food boolean, 
		hunger int, 
		thrist int, 
		wear boolean, 
		clothes { slot_id int, clothe table{ texture string, model string, type int } }, 
		preview_object table{ model int, pos table{ float, float, float }, r table{ float, float, float }, bone int },

	}

]]--

ITEMS = {

	[ 1 ] = {

		name 		= "Apple",
		description = "Food",
		stackable 	= true,
		food 		= true,
		hunger 		= 3,
		thirst 		= 2

	},

	[ 2 ] = {

		name 		= "Construction Plan",
		description = "Construction",
		stackable 	= true

	},

	[ 3 ] = {

		name 			= "AK-47",
		description 	= "Weapon",
		weapon 			= { mta_id = 30, ammo_id = 4, show_ammo = true, max_ammo = 30, custom_id = 20001 },
		wear	 		= true,
		preview_object 	= { model = 355, pos = { -0.2, -0.15, 0 }, r = { 0, 0, 0 }, bone = 3, custom_id = 20001 },

	},

	[ 4 ] = {

		name 		= "5.56 Ammo",
		description = "Ammo",
		is_ammo 	= true,
		stackable 	= true

	},

	[ 5 ] = {

		name 		= "Blue Shirt",
		description = "Roupa",
		clothes 	= { slot_id = 4, clothe = { "sixtyniners", "tshirt", 17 } }

	},

	[ 6 ] = {

		name 		= "Green Shirt",
		description = "Clothe",
		clothes 	= { slot_id = 4, clothe = { "sixtyniners", "tshirt", 16 } }

	},

	[ 7 ] = {

		name 		= "Boot",
		description = "Clothe",
		clothes 	= { slot_id = 6, clothe = { "sixtyniners", "tshirt", 16 } }

	},

	[ 8 ] = {

		name 		= "Balaclava",
		description = "Clothe",
		clothes 	= { slot_id = 2, clothe = { "sixtyniners", "tshirt", 16 } }

	},

	[ 9 ] = {

		name 		= "Armor",
		description = "Protection",
		wear 		= true,
		clothes 	= { slot_id = 3, clothe = { "sixtyniners", "tshirt", 16 } }

	},

	[ 10 ] = {

		name 		= "Jeans Legs",
		description = "Clothe",
		clothes 	= { slot_id = 5, clothe = { "sixtyniners", "tshirt", 16 } }

	},

	[ 11 ] = {

		name 		= "Helmet",
		description = "Protection",
		wear 		= true,
		clothes 	= { slot_id = 1, clothe = { "sixtyniners", "tshirt", 16 } }

	},

	[ 12 ] = {

		name 			= "Pistol",
		description 	= "Weapon",
		weapon 			= { mta_id = 22, ammo_id = 13, show_ammo = true, max_ammo = 7 },
		wear	 		= true,
		preview_object 	= { model = 348, pos = { 0, 0.2, 0.1 }, r = { 235, 90, 0 }, bone = 4 },

	},

	[ 13 ] = {

		name 		= "Pistol Ammo",
		description = "Ammo",
		stackable 	= true

	},

	[ 14 ] = {

		name 		= "Hammer",
		description = "Up/remove constructions",
		-- mta_id 		= 11,
		stackable 	= true

	},

	[ 15 ] = {

		name 		= "Pickaxe",
		description = "Pickaxe",
		wear 		= true,
		-- mta_id 		= 10

	},

	[ 16 ] = {

		name 		= "Axe",
		description = "Axe",
		wear 		= true,
		-- mta_id 		= 12

	},

	[ 17 ] = {

		name 		= "Wood",
		description = "Wood",
		stackable 	= true

	},

	[ 18 ] = {

		name 		= "Rock",
		description = "Rock",
		stackable 	= true

	},

	[ 19 ] = {

		name 		= "Scrap",
		description = "Scrap",
		stackable 	= true

	},

};