package platform

import (
	"guku.io/devx/v2alpha1"
	"guku.io/devx/v2alpha1/environments"
	"guku.io/devx/v1/transformers/terraform/aws"
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
		// We re-use the provider definition of our infra stack
		components: tfprovider: infra.builders.prod.components.tfprovider

		// Add an extra flow to auto-generate secrets in SSM parameter store
		// The aws.#AddSSMSecretParameter transformer use random_password to generate a 32-character string
		flows: "terraform/autogenerate-secrets": pipeline: [aws.#AddSSMSecretParameter]
	}
}
