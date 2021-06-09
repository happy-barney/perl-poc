
# Well-known issue with File::Slurp is its utf8 support.
# Should it use proposed slot mechanics then fixing it will be easy even without
# modification of buggy module.

package File::Slurp {
	sub read_file {
		has ${: file_name } := ...;
		has ${: options } := ...;
		has ${: binmode } := :optional, :default => ${: options }->{binmode};
	}
}

# Inject default value for File::Slurp's read_file's binmode

local has ${: / File::Slurp / &read_file / binmode } := ':utf8';
