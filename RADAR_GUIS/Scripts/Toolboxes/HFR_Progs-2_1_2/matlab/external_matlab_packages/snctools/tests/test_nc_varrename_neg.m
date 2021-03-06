function test_nc_varrename_neg()

if nargin == 0
	ncfile = 'foo.nc';
end


test_no_arguments;
test_only_one_input ( ncfile );
test_only_two_inputs ( ncfile );
test_too_many_inputs ( ncfile );

% specific to format
run_nc3_tests(ncfile);
run_nc4_tests(ncfile);

return

%--------------------------------------------------------------------------
function run_nc3_tests(ncfile)

mode = nc_clobber_mode;
test_inputs_not_all_char ( ncfile, mode );
test_empty_file ( ncfile,mode );
test_variable_not_present ( ncfile,mode );
test_variable_with_same_name (ncfile,mode);
return


%--------------------------------------------------------------------------
function run_nc4_tests(ncfile)

if ~netcdf4_capable
	fprintf('\tmexnc (netcdf-4) backend testing filtered out on configurations where the library version < 4.\n');
	return
end

mode = bitor(nc_clobber_mode,nc_netcdf4_classic);
test_inputs_not_all_char ( ncfile, mode );
test_empty_file ( ncfile,mode );
test_variable_not_present ( ncfile,mode );
test_variable_with_same_name (ncfile,mode);

return








%--------------------------------------------------------------------------
function test_variable_with_same_name ( ncfile,mode )

global ignore_eids;

create_empty_file ( ncfile,mode );
nc_add_dimension ( ncfile, 't', 0 );
clear varstruct;
varstruct.Name = 't';
varstruct.Nctype = 'double';
varstruct.Dimension = { 't' };
nc_addvar ( ncfile, varstruct );
varstruct.Name = 't2';
varstruct.Nctype = 'double';
varstruct.Dimension = { 't' };
nc_addvar ( ncfile, varstruct );

try
	nc_varrename ( ncfile, 't', 't2' );
catch me
    
    if ignore_eids
        return
    end
    switch(me.identifier)
        case {'MATLAB:netcdf:renameVar:nameIsAlreadyInUse', ...
                'SNCTOOLS:NC_VARGET:MEXNC:RENAME_VAR' }
            return
        otherwise
            rethrow(me);
    end    
end



v = nc_getvarinfo ( ncfile, 't2' );
if ~strcmp ( v.Name, 't2' )
	error('rename did not seem to work.');
end


return


%--------------------------------------------------------------------------
function test_empty_file ( ncfile,mode )
global ignore_eids;

create_empty_file ( ncfile,mode );
try
	nc_varrename ( ncfile, 'x', 'y' );
catch me
    if ignore_eids
        return
    end
    switch(me.identifier)
        case {'MATLAB:netcdf:inqVarID:variableNotFound', ...
                'SNCTOOLS:NC_VARGET:MEXNC:INQ_VARID' }
            return
        otherwise
            rethrow(me);
    end
end
error('succeeded when it should have failed');








%--------------------------------------------------------------------------
function test_variable_not_present ( ncfile,mode )

global ignore_eids;

create_empty_file ( ncfile,mode );
nc_add_dimension ( ncfile, 't', 0 );
clear varstruct;
varstruct.Name = 't';
varstruct.Nctype = 'double';
varstruct.Dimension = { 't' };
nc_addvar ( ncfile, varstruct );

try
	nc_varrename ( ncfile, 't2', 't3' );
catch me
    if ignore_eids
        return
    end
    switch(me.identifier)
        case {'MATLAB:netcdf:inqVarID:variableNotFound', ...
                'SNCTOOLS:NC_VARGET:MEXNC:INQ_VARID' }
            return
        otherwise
            rethrow(me);
    end
end
error('succeeded when it should have failed.');










%--------------------------------------------------------------------------
function test_inputs_not_all_char(ncfile,mode)

global ignore_eids;

% Ok, now we'll create the test file
create_empty_file ( ncfile,mode );
nc_add_dimension ( ncfile, 't', 0 );
clear varstruct;
varstruct.Name = 't';
varstruct.Nctype = 'double';
varstruct.Dimension = {'t'};
nc_addvar ( ncfile, varstruct );


try
	nc_varrename ( ncfile, 'x', 1 );
catch me
    if ignore_eids
        return
    end
    switch(me.identifier)
        case {'MATLAB:netcdf:inqVarID:variableNotFound', ...
                'SNCTOOLS:NC_VARGET:MEXNC:INQ_VARID' }
            return
        otherwise
            rethrow(me);
    end
end
error('succeeded when it should have failed');



%--------------------------------------------------------------------------
function test_no_arguments ( )
global ignore_eids;
try
	nc_varrename;
catch me
    if ignore_eids
        return
    end
    switch(me.identifier)
        case 'MATLAB:inputArgUndefined'
            return
        otherwise
            rethrow(me);
    end
end
error('failed');












%--------------------------------------------------------------------------
function test_only_one_input ( ncfile )
global ignore_eids;
try
	nc_varrename ( ncfile );
catch me
    if ignore_eids
        return
    end
    switch(me.identifier)
        case 'MATLAB:inputArgUndefined'
            return
        otherwise
            rethrow(me);
    end
end

error('failed');







%--------------------------------------------------------------------------
function test_only_two_inputs ( ncfile )

global ignore_eids;

try
	nc_varrename ( ncfile, 'x' );
catch me
    if ignore_eids
        return
    end
    switch(me.identifier)
        case 'MATLAB:inputArgUndefined'
            return
        otherwise
            rethrow(me);
    end
end

error('failed');









%--------------------------------------------------------------------------
function test_too_many_inputs ( ncfile )
global ignore_eids;
try
	nc_varrename ( ncfile, 'blah', 'blah2', 'blah3' );
catch me
    if ignore_eids
        return
    end
    switch(me.identifier)
        case 'MATLAB:TooManyInputs'
            return
        otherwise
            rethrow(me);
    end
end
error('failed');









