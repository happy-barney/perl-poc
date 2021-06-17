
# Understanding subs in COP

Mental model of subs is litte bit different in COP.

First approximation to understand it will be that there is no sub
but every sub is represented by its own class.

```
	package Foo {
		sub foo {
			has $arg1;
			has @arg2;
			has %arg3;
			...
		}
	}

	Foo::foo ($arg1 := 1, @arg2 := (2, 3), %arg3 := (4 => 5));
```

Is treated like
```
	package Foo::&foo {
		has $arg1;
		has @arg2;
		has %arg3;
		sub run () { ... }
	}

	Foo::&foo->new ($arg1 := 1, @arg2 := (2, 3), %arg3 := (4 => 5))->run();
```

## sub A :extends => &B

Similar to class inheritance sub `A` inherits all parameters of `B`.
It can alter their meta properties (including renaming and hinding),
yet still preserving proper binding so when calling `B` from `A`, it's
as simple as `goto &B`

## sub A :extends => Package

Syntax from constructors.

Example
```
	package Point::Plane {
		has $x;
		has $y;

		sub constructor := :extends Point::Plane { ... }
	}

	Point::Plane->constructor ($x := 1, $y := 2);
```

Can be expanded as
```
	package Point::Plane {
		has $x;
		has $y;

		package Point::Plane::&new := :extends Point::Plane {
			sub run () { my $self = bless current_context; ...; $self; }
		}
	}

	Point::Plane::&constructor->new ($x := 1, $y := 2)->run;
```

current_context in this example returns data structure (symbol map) which looks like
```
	{
		'*parent' => 'Point::Plane',
		'$Point::Plane::x' => 1,
		'$Point::Plane::y' => 2,
	}
```

From this expansion one can read that constructor sub inherits its parameters
from package - yet still be able to define its own and do some precomputing.

## Multi-method

From this approximation one can also see that multi-methods are not supported.
Multi-dispatch is done by evaluation dependencies and transformations between
parameters.
