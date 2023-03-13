package main

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

stack: v1.#Stack & {
	$metadata: stack: "infra"
	components: {
		// Virtual private network
		network: {
			traits.#VPC
			vpc: {
				name: "tutorial"
				cidr: "10.0.0.0/16"
				subnets: {
					private: ["10.0.1.0/24", "10.0.2.0/24"]
					public: ["10.0.101.0/24", "10.0.102.0/24"]
				}
			}
		}

		// ECS cluster
		cluster: {
			traits.#ECS
			ecs: {
				name: "tutorial"
				capacityProviders: fargateSpot: enabled: true
			}
		}

		// Application load balancer
		gateway: {
			traits.#Gateway
			gateway: {
				name:   "tutorial"
				public: true

				// Replace this with you own domains
				// You have to move your domain name servers to Route53 for this to work
				addresses: [
					"tutorial-aws-ecs.guku.io",
				]

				// We want our gateway to listen on port 80 and 443
				listeners: {
					http: {
						port:     80
						protocol: "HTTP"
					}
					https: {
						port:     443
						protocol: "HTTPS"
					}
				}
			}
		}
	}
}
