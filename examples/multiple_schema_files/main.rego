# METADATA
# scope: subpackages
# schemas:
#   - input: schema.input
#   - data.admins: schema.admins
package main

import future.keywords

allow if {
	input.name in data.admins
}

#
