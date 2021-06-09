
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

		return $connection;
	}

}

# We can prevent usage of login/password authentication in whole program
# without touching any line of (3rd party) code
local has ${: / REST::API / &connect / login } := not :available;
local has ${: / REST::API / &connect / password } := not :available;

