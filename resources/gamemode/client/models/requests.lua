RequestsModel = { };
RequestsModel.allocated_cache = { };

function RequestsModel.setup( )

	for k, v in pairs( REQUEST_MODELS ) do

		local allocated = engineRequestModel( v.type, v.parent_id );

		if ( not allocated ) then

			print( "Failed to allocate model: " .. k );

		end

		RequestsModel.allocated_cache[ v.custom_id ] = allocated;

		if ( v.file_path ) then

			for type, file in pairs( v.file_path ) do

				for k, c in pairs( Models.handlers ) do

					if ( type == k and fileExists( file ) ) then

						local instance = c.handler( file, v.filter );
						if ( not instance ) then

							print( "Failed to load model: " .. file );

						else

							instance[ c.method ]( instance, allocated );

						end

					end

				end

			end

		end

	end

	addEventHandler( "onClientElementDataChange", root, RequestsModel.elementDataChange );

end

function RequestsModel.stop( )

	for k, v in pairs( RequestsModel.allocated_cache ) do

		engineFreeModel( v );
		RequestsModel.allocated_cache[ v.custom_id ] = nil;

	end

	collectgarbage( "collect" );

end

function RequestsModel.elementDataChange( key, old, new )

	if ( not isElement( source ) and getElementType( source ) ~= "object" ) then

		return;

	end

	if ( key == "engine > custom_id" ) then

		local allocated = RequestsModel.allocated_cache[ new ];
		if ( allocated ) then

			setElementModel( source, allocated );

		end

	end

end

function RequestsModel.getAllocated( custom_id )

	return RequestsModel.allocated_cache[ custom_id ];

end