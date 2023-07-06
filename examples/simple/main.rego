# METADATA
# scope: subpackages
# schemas:
#   - input: schema.input
package main

import future.keywords

allow if {
	input.name in data.admins
}
