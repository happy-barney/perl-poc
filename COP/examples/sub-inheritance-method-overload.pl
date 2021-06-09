
package Parent {
	sub foo {
		has $bar;
	}
}

package Child {
	extend Parent::;

	sub foo : extends &Parent::foo {
		say $bar;

		goto SUPER;
	}
}

