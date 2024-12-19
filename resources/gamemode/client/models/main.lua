Models = { };
Models.handlers = { 

	txd = { handler = EngineTXD, method = "import" },
	dff = { handler = EngineDFF, method = "replace" },
	col = { handler = EngineCOL, method = "replace" }

};

function Models.replace( )

	for _, v in pairs( REPLACE_MODELS ) do

		for k, c in pairs( Models.handlers ) do

			if ( v[ k ] and fileExists( v[ k ] ) ) then

				local instance = c.handler( v[ k ], v.filter );
				if ( not instance ) then

					print( "Failed to load model: " .. v[ k ] );

				else

					instance[ c.method ]( instance, v.model );

				end

			end

		end

	end

end