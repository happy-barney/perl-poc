
# Preamble

Author: barney@cpan.org

Title: New programming paradigm for perl - context oriented programming

# Abstract

Context oriented programming (COP) described in this proposal is
data-driven programming technique where code is aware of its execution
environment (context) as well as it can enhance it.

# Table of Contents

1. [Motivation](#Motivation)
2. [Glossary](#Glossary)
    1. [Constraint](#Constraint)
    2. [Slot](#Slot)
    3. [Slot address](#Slot-address)
    4. [Data context frame](#Data-context-frame)
    5. [Data context stack](#Data-context-stack)
3. [New grammar](#New-grammar)
    1. [Meta assign operator](#Meta-assign-operator)
    2. [Keyword exists](#Keyword-exists)
    3. [Keyword has](#Keyword-has)
4. [Use cases](#Use-cases)
    1. [Use case - sub arguments](#Use-case---sub-arguments)
    2. [Use case - sub inheritance](#Use-case---sub-inheritance)
    3. [Use case - sub currying](#Use-case---sub-currying)
    4. [Use case - thunk](#Use-case---thunk)
    5. [Use case - multidispatch](#Use-case---multidispatch)
    6. [Use case - dependency injection](#Use-case---dependency-injection)
    7. [Use case - OOP](#Use-case---OOP)
5. [Data Context](#Data-Context)
6. [Slot meta parameters](#Slot-meta-parameters)
7. [Synergies](#Synergies)
8. [Follow ups](#Follow-ups)

# Motivation

COP (as described in this proposal) centers on data and data domains.

Some parts of it are already existing nowadays
- environment variables
- command line options
- thread local variables
- OOP class / instance properties
- `local`
- dependency injection
- multi-dispatch
- overlay filesystem
- Context::Singleton

## OOP vs COP

Basic difference between OOP and COP can be described using metaphore where
your code is your dog.
- OOP gives the dog a chain, the shorter the better
- COP gives the dog a yard to play

# Glossary
## Constraint

Term `constraint` used in this document represents named behaviour but is
not specified otherwise at the moment.

## Slot

Term slot used in this document represents named public constraint of given
context.

Slot is defined in a code context:
- package / class
- object / class instance
- subs / methods
- other blocks (eg: for, foreach, if, map, ...)

Slot value evaluation is always lazy.
Slot value is stored in best maching data context frame (see [Data Context](#Data-Context) below).
Unless specified explicitly slot value is considered write-once.

Some slot meta parameters (see [Slot Meta Parameters](#Slot-Meta-Parameters) below)
- :default => expression
  - default value of slot
- :required
  - slot value must be available in current block
- :is => Constraint
  - slot value must conform to specified constraint

Slot value can be addressed via standard variable accessor
- [tests/slot-variable-exists.pl](tests/slot-variable-exists.pl)
- [tests/slot-variable-access.pl](tests/slot-variable-access.pl)

Using buzzwords, slot can be considered as a microservice in your program.

## Slot address

- local name
  - `${: foo }`
- qualification (package name, sub name)
  - `${: / Package / foo `
    - slot `foo` defined on package level
  - `${: / Package & sub-name / foo }`
    - slot `foo` defined in function `Package::sub-name`
  - `${: / foo }`
    - slot `foo` defined in `main`
  - `${: & sub-name / foo }`
    - slot `foo` defined in `sub-name` in current package
  - `${: / & sub-name / foo }`
    - slot `foo` defined in `sub-name` in `main`
- context predicate (this context, parent context, context where ...)
  - `${: . / foo }`
    - slot in current context
    - when value should be resolved, it is resolved in current context only
  - `${: .. / foo }`
    - slot from parent context (closest parent where it exists)
  - `${: [ exists ${: / Package / bar } ] / foo }`
    - slot in parent context where another slot exists

## Data context frame

Place where slot values are stored when computed (see [Data Context](#Data-Context) below)

## Data context stack

Hierarchy of data context frames (see [Data Context](#Data-Context) below)

# New grammar
## Meta assign operator

New binary operator `:=` used to modify meta properties of its lhs.

Meta parameter can be assigned to
- slots
- packages / classes (aka class literal)
- objects
- list of above

```
	${: slot} := :is => Constraint;
	Foo::Bar  := :with => Role;
	$instance := :with => Role;

	(Foo::Bar, Foo::Baz) := :with => Role;
```

Meta properties is a non-empty list of`meta-parameter-name => value` pairs
connected by `:=`

- `=> value` can be omitted, boolean representation `=> 1` is implied
- `not name` is translated into `name => 0`
- when `name =>` is missing, `:default =>` is implied
- name can be followed by `:when (condition)` predicated
  - property specification will effective are used only if condition evaluates true

```
	has ${: slot }
		:= :is => Constraint
		:= not :required :when ($API::Relaxed)
		:= :with => Role
		:= :default => ...
	;
```

See [Slot Meta Parameters](#Slot-Meta-Parameters) below.

## Keyword exists

When called with `slot` address, returns true if
- its value is available in current data context frame
- it has a `:default` expression specified and it can be evaluated

## Keyword has

Similar to `my`/`our`/`state` but for slots.

- always followed by slot address, evaluates as slot's meta representation
- slot address must be simple slot address except when used with `local`
  - `local` allows qualified slot address

Examples (more with details in use cases):
- [specify class properties](examples/specify-class-properties.pl)
- [specify function parameters](examples/specify-function-parameters.pl)
- [specify multi-item block](examples/specify-multi-item-block.pl)

# Use cases

Asorted list of use cases

## Use case - sub arguments

Slot defined in sub block is describes its public interface - its parameter.

```
	sub foo {
		has $bar := :positional;
		has $baz := :positional;
	}
```

Unlike other approaches this one specifies parameters in same code block
as rest of code.

To recognize parameter as positional, `:positional` meta parameter must
be specified (default: false). Such parameters are collected in definition order
- first, all scalar slots without default value
- second, all scalar slots with defualt value
- third, one `:slurpy` list slot

Sub calling can use `:=` operator to use named parameter mechanism
```
	foo 1, $bar := 2;
```

Positional parameters with value specified via named parameter mechanism are
excluded from position mapping.

Named parameter syntax can be used to specify value of any known slot.

Examples
- [examples/sub-arguments-named.pl](examples/sub-arguments-named.pl)
- [examples/sub-arguments-multiple-lists.pl](examples/sub-arguments-multiple-lists.pl)
- [examples/sub-arguments-non-argument.pl](examples/sub-arguments-non-argument.pl)

Arguments assigned via named parameters are excluded from `@_`.

## Use case - sub inheritance

Sub can inherit from another sub to share its public interface (slots)
- callback implementation
- overriding / overloading

Examples
- [Getopt::Long callback](examples/sub-inheritance-getopt-long.pl)
- [method overload](examples/sub-inheritance-overload.pl)

## Use case - sub currying

Function currying is a programmign pattern when one provides function
which acts like another function with default argument.

Examples:
- [exponentiation](examples/sub-currying-exponentiation.pl)

## Use case - thunk

https://en.wikipedia.org/wiki/Thunk

When function returns slot address, its value is lazily evaluated, using
data context frame in which return was executed, first time when needed.

Examples:
- [thunk](examples/thunk.pl)

## Use case - multidispatch

Multidispatch is a pattern how use same named behaviour (method)
accepting different API.

Multidispatch provided by this proposal uses single method and
slot value using dependency resolution.

### Why single method ?

Sub name / method name represents contract - same name should return same
contract.

Bad examples (using java syntax):
```
	public String getStatus (HTTPRequest);
	public int    getStatus (Socket);
```

### Dependency resolution

### Private slot

Private slot allows to use slot mechanics for internal purposes.

```
	my has $foo := ...;
```

### Examples

- [REST API client](examples/multidispatch-rest-client.pl)

## Use case - dependency injection

Uses patterns defined in other use cases to provide alternative
default values.

Examples
- [File::Slurp utf8 problem](examples/dependency-injection-file-slurp.pl)
- [prevent login / password](examples/dependency-injection-prevent-login-password.pl)

## Use case - OOP

OOP capabilities will be achieved by:
- capability do define constructor as sub extending package
  - `sub constructor :extends => Package { }`
    - creates new context
    - provides slot `${: self }` containing properly blessed value
      bounded with current context
    - object instance is accessible as `$self` or `${: self }`
    - `:required` is checked when object is instantiated
    - return value is ignored and automatic `return $self` is used
- when method is called
  - object instance is accessible as `$self` or `${: self }`
  - method context is a composition of current context and context bounded
    with `${: self }`
  - unless overriden in method every lazy resolution is executed
    in constructor context (using context when constructor was called as parent)
- inheritance
  - inheritance is declared by applying `:extends` on \_\_PACKAGE\_\_
- role consumption
  - role consumption is declared by applying `:with` on \_\_PACKAGE\_\_

Example
  - [OOP inheritance](examples/oop-inheritance.pl)

# Data context

Data context stack combines capabilities of execution stack and symbol table.

It is similar to execution stack but data visibility is defined by data themself
not by structure of code.

Data context frame holds slot definitions and their instantiated values.

Every context (except of root context) has parent context link.

When value is resolved via dependency resolution, computed value is stored
(and cached) in frame which fultifies all dependencies.

Syntax `${: . / foo }` can be used to force computed value to be stored
in current frame.

# Slot meta parameters

## :default

Specifies expression used default value of slot.
Expression is always executed (ie anonymous hash always creates new instance)
See [default expression](examples/meta-parameter-default.pl)

Default expression can be computed expression.
This computed expression is bounded with current context (reason: thunk).

When specified multiple, last will be used

## :required

Boolean, default false.

When true, value must exist before executing first code line (apart of `has`)
using current frame context.

When specified multiple, last will be used

## :is

Specifies constraint on slot value.

When specified multiple times, every constraint will be used.

Value is either constraint reference or block, accepting candidate as `$_`
and returning true / false.

TODO: throwing exception extending X::Slot::Constraint::Validation

## :available

Boolean, default true;

## :extends

Specifies inheritance relation

When applied on class literal
- parameter is class literal
  - appends parameter to @ISA

When applied on sub
- parameter is class literal
  - sub is class constructor
  - sub shares slot specification with class literal
- parameter is sub reference `&qualified-name`
  - sub shares slot specification with parent sub
- parameter is variable holding sub reference
  - sub shares slot specification with parent sub

Can be speficied multiple times (multiple inheritance).

## :with

Applicable on class literal

Apply role on class literal or object instance

Can be specified multiple times

## :positional

Boolean, default false.

Used by sub dispatch to determine whether slot can be initialized
via positional arguments.

## :slurp

Boolean, default false.

Applicable on `@` or `%` slots

Used by sub dispatch to determine whether slot can be initialized
via positional arguments consuming all unassigned values.

## :bind

Use alternative name of parent slot.

Applicable on subs and class literals.

```
	sub foo :extends &bar {
		has $dx := :bind => ${: &bar / x };
	}
```

# Synergies

- slot address language can be reused in CATCH expression

# Follow ups

## Package (api) versioning

Slot dependency resolution mechanism provides vehicle to handle
multiple instances of package in single process

Example
```
package Foo @[ v1.0.0 ] { }
package Foo @[ v2.0.0 ] :extends @[ v1.0.0 ] { }

my $obj = Foo @[ v1.0.0 ]->new ();
my $obj = Foo @[ v2.0.0 ]->new ();

sub foo @[ v1.0.0 ] { }
sub foo @[ v2.0.0 ] { }

say foo @[ v1.0.0 ] (1, 2, 3);
say foo @[ v2.0.0 ] (1, 2, 3);
```

