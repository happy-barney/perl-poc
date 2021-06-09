
package Parent {
	has ${: limit }
		:= :is Number
		:= :is { $_ > 0 }
		:= :required
	;

	
}

package Child {
}
