
sub foo {
	has $bar := :positional;
	has $baz := :positional := :default => 2;

	return $bar . $baz;
}

# All calls returns 12

foo 1;
foo $bar := 1;

# All calls returns 13
foo 1, 3;

foo 1, $baz := 3;
foo $baz := 3, 1;

foo 3, $bar := 1;
foo $bar := 1, 3;

foo $bar := 1, $baz := 3;
foo $baz := 3, $bar := 1;

foo $baz := 10, $bar := 10, $baz := 3, $bar := 1;
