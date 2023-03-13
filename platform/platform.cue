package platform

import (
	"guku.io/devx/v2alpha1"
	"guku.io/devx/v2alpha1/environments"
	infra "devopzilla.com:main"
)

Builders: v2alpha1.#Environments & {
	prod: environments.#ECS & {
		drivers: terraform: output: dir: ["deploy"]
		config: {
			aws: {
				// Add your AWS region
				region: "us-west-1"

				// Add your AWS account id
				account: "540379201213"
			}
			vpc: name: infra.stack.components.network.vpc.name
			ecs: {
				name:       infra.stack.components.cluster.ecs.name
				launchType: "FARGATE"
			}
			secrets: service: "ParameterStore"
			gateway: infra.stack.components.gateway.gateway
		}

		// Add this component to configure the generated Terraform AWS providers
		components: tfprovider: infra.builders.prod.components.tfprovider
	}
}
