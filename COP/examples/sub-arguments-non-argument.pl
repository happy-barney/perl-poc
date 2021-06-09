
has $foo := 1;

sub foo {
	has $bar := :positional := :default => ${: foo };

	return $bar;
}

is 1, foo;
is 2, foo 2;
is 3, foo $bar := 3;
is 4, foo ${: foo } := 4;

