
package Getopt::Long {

	sub callback {
		has $option;
		has $value;
	}
}

GetOptions (
	"option" => sub :extends => &Getopt::Long::callback { say "$option => $value" },
);

my $foo = sub :extends => Getopt::Long::callback;

GetOptions (
	"option" => sub :extends => $foo { say "$option => $value" },
);

