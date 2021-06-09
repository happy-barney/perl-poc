
package REST::API {

	sub connect {
		has ${: login }
			:= :required :when (  exists ${: password})
			:= :required :when (! exists ${: oauth})
			:= not :available :when (exists ${: oauth })
		;

		has ${: password }
			:= :required :when (  exists ${: login})
			:= :required :when (! exists ${: oauth})
			:= not :available :when (exists ${: oauth })
		;

		has ${: oauth }
			:= not :available :when (exists ${: login })
			:= not :available :when (exists ${: password })
		;

		has ${: authentication }
			:= :required
			:= not :available
			:= :default :when (  exists ${: oauth}) => { REST::API::Authentication::Oauth->new ($oauth) }
			:= :default :when (! exists ${: oauth}) => { REST::API::Authentication::Basic->new ($login, $password) }
		;

		return ...;
	}
}

package REST::API::Config {
	__PACKAGE__ := :extends => REST::API;

	sub connect :extends => &REST::API::connect {
		has ${: another_method };

		has ${: authentication }
			:= :default :when (exists ${: another_method}) => { REST::API::Authentication::Another::Method ($another_method) }
		;
	}
}
