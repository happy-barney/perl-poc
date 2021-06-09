
package REST::API {

	sub connect {
		has ${: login }
			:= :when (  exists ${: password }) { :required }
			:= :when (! exists ${: oauth })    { :required }
			:= :when (  exists ${: oauth })    { not :available }
		;

		has ${: password }
			:= :when (  exists ${: login })    { :required }
			:= :when (! exists ${: oauth })    { :required }
			:= :when (  exists ${: oauth })    { not :available }
		;

		has ${: oauth }
			:= :when (  exists ${: password }) { not :available }
			:= :when (  exists ${: login })    { not :available }
		;

		my has ${: connection }
			:= :required
			:= :when (  exists ${: oauth}) { :default { REST::API::Connection->new ($oauth) } }
			:= :when (! exists ${: oauth}) { :default { REST::API::Connection->new ($login, $password) } }
		;

		return $connection;
	}

}

# We can prevent usage of login/password authentication in whole program
# without touching any line of (3rd party) code
local has ${: / REST::API / &connect / login } := not :available;
local has ${: / REST::API / &connect / password } := not :available;

