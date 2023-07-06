package main

import future.keywords

test_bob_allowed if {
	allow with input as {"name": "bob"}
}

test_anonymous_denied if {
	not allow with input as {"name": "anonymous"}
}
