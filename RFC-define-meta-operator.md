
# Preamble

Author: barney@cpan.org

Title: Assign meta operator

# Abstract

Provide dedicated syntax for declaring meta properties of misc entities.

# Motivation

Note:
This is part of larger set of RFCs (Context Oriented Programming)
which can be reused by other (unrelated) RFCs.

Note 2:
Few times I'll mention [Ovid's Cor proposal](https://github.com/Ovid/Cor/)
where this RFC may overlap (conflict) with it using different expressivity
(showing support to his effort).

Current perl ecosystem has many approaches how to specify meta properties
in different entities

- package
  - perl core - set package variables (`@ISA`, `@EXPORT`, ...)
  - Moo/Moose - functions like `extends`, `with`
  - Ovid's Cor proposal - keywords `isa`, `does`

- function / method
  - perl core - prototypes
  - perl core - signatures
  - perl core - attributes
  - perl core - `return bless` (that function is in fact constructor)
  - Export libraries - reference function in `@EXPORT`, ...
  - Moo/Moose - functions like `around`, `override`, ...
  - Ovid's Cor - method modifier like `abstract`, `private`, ...

- variable
  - perl core - attributes
  - perl core - magic (eg `Readonly`)
  - perl core - `bless`, `tie`
  - perl core - intention often implemented by using `//`, `//=`, ...
  - Moo/Moose - function `has`
  - `Moose::Util::apply_all_roles`
  - Ovid's Cor - keyword `has`

Definition of binary define-meta operator will provide unified way to express
intention (which leads to non negligible improvement to code readability)

# Specification

## General syntax

New chainable, left associative binary operator `LHS := meta property expression`

## Meta property expression

- `:meta-property-name => meta-property-value`
  - basic variant, set value to property
- `:meta-property-name`
  - set value of boolean property to true
- `not :meta-property-name`
  - set value of boolean property to false
- `meta-property-value`
  - when property name is omitted, `:default` is used

`when (condition) => value` expression can be used for conditional assignment.
Condition is stored and evaluated when given meta property is evaluated.

basic variant can contain any number of when expressions
```
	LHS := :property
		when (cond-1) => value
		when (cond-2) => value
		=> otherwise
```

short default version
```
	LHS :=
		when (cond-1) => value
		when (cond-2) => value
		=> otherwise
```

Short boolean variants can contain short when conditions. Those conditions
are evaluated as OR
```
	LHS := :required
		when (cond-1)
		when (cond-2)

	LHS := not :required
		when (cond-1)
		when (cond-2)
```

## Meta property name

Meta property name is an identifier.

When used in meta property expression meta property name should be prefixed
with colon (behaves like sigil - whitespaces allowed).

## Meta properties API

C-API v0 should provide:
- `is_meta_property_set (object, meta_property)`
- `list_meta_properties (object`
- `meta_property_value (object, meta_property, context)`

For purpose if this API meta property is represented by package literal
(package name).

Meta properties available in current perl code are available via `%{^Meta}`
- key is a meta property name used in code
- value is package literal

It should be possible to populate `%{^Meta}` from `sub import`

## Specify meta properties on package

Not every meta property used in examples is also specified in this RFC

Compile time
```
	package Foo v1.0.0
		:= : extends => Parent1
		:= : extends => Parent2
		:= : does => Role1
		:= : does => Role2
		:= : rest_archetype => Rest::Archetype::Collection::
		:= : rest_path => '/internal/foo/'
	{
	}
```

Runtime
```
	package Foo v1.0.0 {
		__PACKAGE__ := :does => Role3 (with => parameter)
			if $ENV{USE_ROLE3};
	}

	Foo:: := :does => Role4;
```

## Specify meta properties on subs

Compile time
```
	sub foo
		:= :lvalue
		:= :is => CORE::Array::
		:= :public # (Cor attribute)
		:= :shared # (Cor attribute)
```

Runtime
```
	sub foo {
		__SUB__ := :is => CORE::Hash::;
	}

	&foo := not :available;

	# Mimic Sub::Override
	local &foo := :bind => sub { logger->log (@_); goto &foo };
```

## Specify meta properties on variable

```
	my $bar := :is => CORE::Number:: = 10;
	$bar := :readonly;

	has $var
		:= :is => CORE::Number::
		:= :is => CORE::Defined::
		:= :default => -1
		:= :readonly
		:= :private
	;
```

## Standard meta properties

### :extends => parent

Package literal `CORE::Meta::Extends::`

When applied on package
```
	package Foo v1.0.0 := :extends => Bar {
	}

	package Foo v1.0.0 {
		__PACKAGE__ := :extends => Bar;
		__PACKAGE__ := :extends => Baz
			if $ENV{USE_BAZ};
	}
```

Currently: simply push its argument to @ISA

When applied on sub
```
	sub foo := :extends => &bar { }
```

Declares function `foo` with same prototype/signature as `bar`.
Can be used to implement callbacks (eg: Getopt::Long)

Although `:extends` looks similar to `:is`, purpose of `:extends` is
to reuse and extend parent context whereas purpose of`:is` is to
restrict context by imposing constraints.

### :does => Role

Package literal `CORE::Meta::Does::`

Similar to `:extends` but applies role on class or instance.

```
	package Foo
		:= :does => Role1
		:= :does => Parameterized::Role (...)
	{ }

	package Foo {
		__PACKAGE
			:= :does => Role1
			:= :does => Parameterized::Role (...)
	}

	$object := :does => Dynamic::Role;
```

### :is => Constraint

Package literal `CORE::Meta::Is::`

Assign constraint to LHS.

Validation throws an exception (dies) when validation fails.

When applied on variable
```
	$var := :is => Constraint;
```

Appends constraint to list of variable constraint and validates it.

When applied on variable declaration
```
	my $var := :is => Constraint;
	has var := :is => Constraint;
```

Appends constraint to list of variable constraint.
Constraints are evaluated when new value is assigned to variable.

When applied on sub
```
	sub foo := :is => Constraint {}
	sub foo {
		__SUB__ := :is => Constraint;
	}
```

appends constraint to function. Constraints are evaluated when function returns.

### :required

Package literal `CORE::Meta::Required::`

Boolean property, by default false.

Applicable to variables or class properties.

```
	package Foo {
		has foo := :required;
		has bar := not :required when ($foo % 2);
	}

	sub authenticate {
		has login := :required;
		has password := :required;
	}
```

When set on variable it throws an exception unless there already was
value assigned to it.

```
	GetOptions (...);

	$option_password := :required when (exists $option_login);
	# See extended behaviour of keyword exists
```

### :available

Package literal `CORE::Meta::Available::`

Boolean property, by default true.

When set to false, assignment to variable will cause runtime warning.
```
	sub authenticate {
		has login := not :available;
		has password := not :available;
		has oauth := :required;
	}
```

### :default => value

Package literal `CORE::Meta::Default::`

Specify default value of variable / property.
Value expression is treated as an block and is evaluated every time when needed.

```
	has protocol := :default => 'https';
	has protocol := 'https';
	$foo->protocol := 'https';
	$foo := 'https';
```

`:default` can be specified multiple time, last assignment will be used.

If last assignment cannot be used (eg it contains only `when` clauses),
its previous assignment is used.

Specifying `:default` on assigned value has no effect, it should produce warning.

Unlike defined-or operator default value accepts `undef` as valid value.

### :bind => another-object

Package literal `CORE::Meta::Bind::`

Binds object with another object (effectively creating alias)

When used on package literal it creates an alias for another package.
Alias can be used to call methods as well as class instance operator
```
	Local::Alias:: := :bind => Long::Package::Name::As::Usual::In::World::Like::XXX;

	# calls Long::Package::Name::As::Usual::In::World::Like::XXX->new
	my $foo = Local::Alias::->new ();

	# following is evaluated as true
	$foo isa Local::Alias::
	$foo isa Long::Package::Name::As::Usual::In::World::Like::XXX::
	Long::Package::Name::As::Usual::In::World::Like::XXX:: isa Local::Alias::
```

When used on subs, variables, data path it creates an variable alias
```
	my %foo = (baz => 1);
	my %bar := :bind => %foo;
	my $baz := :bind => $bar{baz};
	sub foo := :bind => &CORE::say;

	foo $baz;
	# acts like say, prints 1

	$baz++;

	foo $foo{baz};
	# acts like say, prints 2
```

When used on sub it also shares prototype
```
	sub foo (&) { ... }
	sub bar := :bind => &foo;

	foo { ... };
	bar { ... };
```

### :readonly

When specified on package, acts like Moose `__PACKAGE__->meta->make_immutable`
When specified on variable, makes variable readonly (or write once if has no value yet)
When specified on sub, signals that sub only reads arguments

# Alternative syntax

in package context when `:=` is detected as unary operator use `__PACKAGE__`
as an implicit LHS. Similarly when in sub block, use `__SUB__`

```
	package Foo {
		:= : extends => Bar::
		:= : does => Role
		;
	}

	sub foo {
		:= :is Baz::
		;
	}
```

# Related work

- java annotations
  - this RFC provides most of expressivity provided by java annotation
	- in java one annotates data-type
	- annotations cannot by specify dynamically

# Future work

## Trigger API

Specify callback what to do when property is set

## Perl API

## replace attributes

usage is dedicated operator is easier to read (and parse as well)

## named sub arguments, list sub arguments

```
	foo $bar := 1, @baz := 2 .. 3;
```

and more derived from https://github.com/happy-barney/perl-poc/tree/perl-features/COP
