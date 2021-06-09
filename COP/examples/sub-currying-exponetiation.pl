
sub exponentiation {
	has $base := positional;
	has $exponent := positional;
	$base ** $exponent
}

sub square :extends => &exponentiation {
   	local has ${: exponent } := not :available := 2;
	goto &SUPER;
}

sub radix :extends => &exponentiation {
   	local has ${: base } := not :available := 10;
	goto &SUPER;
}

ok 100, exponentiation $base := 10, $exponent := 2;
ok 100, square $base := 10;
ok 100, radix $exponent := 3;

# Not available curryied parameters are ignored
ok 100, square  $base := 10, $exponent := 3;
ok 100, decimal $base := 2, $exponent := 3;
