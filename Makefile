setup-vms:
	multipass launch -n dockerswarm-manager-1  -c 2 -m 2G -d 10G && multipass launch -n dockerswarm-worker-1 -c 2 -m 2G -d 10G && multipass launch -n dockerswarm-worker-2  -c 2 -m 2G -d 10G
	cat ~/.ssh/id_rsa.pub | multipass exec dockerswarm-manager-1 -- tee -a .ssh/authorized_keys
	cat ~/.ssh/id_rsa.pub | multipass exec dockerswarm-worker-1 -- tee -a .ssh/authorized_keys
	cat ~/.ssh/id_rsa.pub | multipass exec dockerswarm-worker-2 -- tee -a .ssh/authorized_keys

setup-cluster:
	ansible-playbook -i inventory.yml init.yml

create-app:
	docker build -t alphaegen/swarm-demo . && docker push alphaegen/swarm-demo

destroy:
	multipass delete dockerswarm-manager-1 dockerswarm-worker-1 dockerswarm-worker-2

deploy:
	ansible-playbook -i inventory.yml iac.yml

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "-  setup-vms			Initialises the virtual machines and SSH access"
	@echo "-  setup-cluster		Initialises cluster and dependencies"
	@echo "-  create-app			Builds and publishes docker app image"
	@echo "-  destroy			Destroys the virtual machines and with it all environments"
	@echo "-  deploy			Deploys the staging environment"

.DEFAULT_GOAL := help
