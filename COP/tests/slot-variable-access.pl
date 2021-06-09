
has ${: foo } := 'foo';

is $foo, 'foo';

{
	local ${: foo} := 'bar';

	is $foo, 'bar';
}

is $foo, 'foo';

