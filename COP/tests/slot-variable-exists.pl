
has ${: foo };

ok ! exists ${: foo }, "slot's foo value is not defined in current context";
ok ! exists $foo,      "exists can be applied on scalar accessor as well";

{
	local ${: foo } := 'bar';

	ok exists ${: foo };
	ok ! exists ${: .. / foo };
}

ok ! exists ${: foo };

{
	local ${: foo };

	ok ! exists ${: foo };

	$foo = 'bar';

	ok exists ${: foo };
}

ok ! exists ${: foo };

