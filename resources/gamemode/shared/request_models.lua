--[[

	REQUEST_MODELS table{ 

		type string, 
		parent_id int,
		custom_id int,

		file_path table{ 
			dff string,
			txd string,
			col string
		}

	}

]]--

REQUEST_MODELS = { };

-- weapons;
REQUEST_MODELS[ "ak-47" ] = { 

	type 		= "object", 
	custom_id 	= 20001, 

	file_path 	= { 

		txd = "assets/models/weapons/ak.txd",
		dff = "assets/models/weapons/ak.dff"

	}

}