package main

import (
	"guku.io/devx/v2alpha1"
	tf "guku.io/devx/v1/transformers/terraform"
	"guku.io/devx/v1/transformers/terraform/aws"
)

builders: v2alpha1.#Environments & {
	prod: {
		// Set terraform output directory to "./deploy"
		drivers: terraform: output: dir: ["deploy"]

		components: {
			// Add this component to configure the generated Terraform AWS providers
			tfprovider: {
				// This reserved field contains all the low-level resources
				$resources: {
					// The name of the resource doesn't matter
					// We use the tf.#Terraform schema to make sure we define valid terraform resources
					terraform: tf.#Terraform & {
						// Set the aws region of the aws provider
						provider: aws: region: "us-west-1"
					}
				}
			}

			// The aws.#AddGateway transformer requires vpc data as input
			// We set the vpc here because we cannot reference external components from within a transformer
			network: _
			gateway: aws: vpc: network
		}

		flows: {
			// This flow expects a VPC trait and generates Terraform code to add an AWS VPC
			"terraform/add-vpc": pipeline: [aws.#AddVPC]

			// This flow expects an ECS trait and generates Terraform code to add an AWS ECS cluster
			"terraform/add-ec-cluster": pipeline: [aws.#AddECS]

			// This flow expects an Gateway trait and generates Terraform code to add an AWS ALB
			"terraform/add-gateway": pipeline: [aws.#AddGateway & {

				// Allow the transformer to create Route53 DNS records
				createDNS: true

				// Allow the transformer to create TLS certificates
				createTLS: true
			}]

		}
	}
}
