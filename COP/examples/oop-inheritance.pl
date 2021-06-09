
package Parent {
	has ${: limit }
		:= :is => Number
		:= :is => { $_ > 0 }
		:= :accessor => 'limit',
		:= :required
	;

	sub new :extends => Parent:: {
	}
}

package Child {
	__PACKAGE__ := :extends => Parent::;

	has ${: limit }
		:= :is => { $_ < 1_000 }
		# this constraint is useless as far as Parent's { > 0 } is applied as well
		:= :is => { $_ > -1_000 }
		:= :default => 10
		;
}

Parent->new ($limit := 999_999);
Child->new  ($limit := 1_000);
