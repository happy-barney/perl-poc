
sub foo {
	has @list := not :positional;
	has %hash := not :positional;
}

foo
	@list := (1, 2, 3),
	%list := (a => 2),
	;

