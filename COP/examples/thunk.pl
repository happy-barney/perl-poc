
my $foo = 0;

sub connect {
	has ${: dsn };
	my $x = $foo;
	has ${: dbh } := not :available := :default { $foo += 10; $x };

	$foo++;

	return ${: dbh };
}

my $rv = connect;

is $foo, 1;
is $rv, 0;
is $foo, 11;

$rv = connect;
is $foo, 12;

$rv = connect;
is $foo, 13;
is $rv, 12;
is $foo, 23;


