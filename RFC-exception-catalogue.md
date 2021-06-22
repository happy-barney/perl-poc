
# Motivation

Simplify identification of internal perl exceptions from user point
of view by assigning them a number.

Change allows
- deduplicate source code
- localize exception messages without breaking existing code
- fine-tune exception text without breaking existing code
- language independent exception match
- cross-language exception search

# Benefits

## Express intention with symbol

Identifying intention via symbol is always better than by free form text.

This RFC contains first part - assign error code and symbol.

## Deduplicate error literals

Many literals are duplicated in source code, for example string used
3 times in vutil.c
```
Invalid version format (dotted-decimal versions require at least three parts)
```

Implementation details:
- collect all exception literals in one exception catalogue source file
```
	#define PERLX_00400 400
	#define PERLX_FUNCTION_NOT_IMPLEMENTED PERLX_00400
	const char * exception_catalogue[] = {
		[PERLX_FUNCTION_NOT_IMPLEMENTED] = "Function %s() not implemented in this version of perl.",
	};
```
- raise exception by exception number (macro)
```
	PERLX_DIE (PERLX_FUNCTION_NOT_IMPLEMENTED, "telldir");
```

Output will be:
```
PERLX-00400: Function telldir() not implemented in this version of perl.
```

## Unify error literals

Just example, error messages for function not implemented

Example: multiple wording for function not implemented on platform (just some)
```
	ack --cc 'not implemented'
	Perl_croak(aTHX_ "The telldir() function is not implemented on NetWare\n")
	Perl_croak(aTHX_ "chown not implemented!\n");
	Perl_croak_nocontext("truncate not implemented");
	croak("Function \"recvmsg\" not implemented in this version of perl.");
	Perl_croak(aTHX_ "setruid() not implemented");
```

All of them will be replaced with something like:
```
	Perl_croak_catalogue (aTHX_ PERLX_00400, "telldir");
	Perl_croak_catalogue (aTHX_ PERLX_FUNCTION_NOT_IMPLEMENTED, "telldir");
```

## Match errors

Test may look like (although `~~` may be more appropriate)
```
	if ($@ == ${^PerlX_00400}) {
	}
	if ($@ == ${^PerlX_Function_Not_Implemented}) {
	}
```

## Localized exception messages

With language independent identification perl can provide localized exception
messages.

## Localized communities

With language independent identification one can find web pages referencing
given exception in many languages referencing its meaning (number).

## Fine-tune / evolve exception text

Proposal allows changes of exception texts without breaking old codes.

Once feature (bundle) is enabled, its should be an error to match `$@`
with regular expressions.

Due backward compatibility there should be two catalogues:
- compatible (messages will not be modified)
- evolvable (messages follows this proposal)

Grey area: raising exceptions added after implementing this rfc

# Other product example

For example, database error codes like `ORA-00904`

non-english error message may like (sk used):
```
SQL Error: ORA-00904: "PKG_CODE": neplatný identifikátor
```

# Related works

## Warnings catalogue

This proposal is applicable to warnings just with `s/X/W/`

## Exceptions as an object

Create internal package literals to allow exception match via `isa`

Usable by `catch`

```
	if ($@ isa CORE::X::X00400::)
	if ($@ isa CORE::X::Function::Not::Found::)
```
