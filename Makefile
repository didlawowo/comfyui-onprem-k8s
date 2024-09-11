MODEL_PATH ?= $(HOME)/models
COMFYUI_VERSION ?= 81778a7
COMFYUI_MANAGER_VERSION ?= 5a87326


# Cluster
cluster:
	@[ -d "$(MODEL_PATH)" ] || { echo "Please set MODEL_PATH"; exit 1; }
	# minikube v1.32.0-beta.0 or later (docker driver only).
	minikube start --driver docker --container-runtime docker \
		--memory=max --cpus=max \
		--gpus all \
		--mount \
		--mount-string $(MODEL_PATH):/minikube-host/models
	# we use custom nvidia-device-plugin helm chart to enable GPU sharing.
	minikube addons disable nvidia-device-plugin

cluster-removal:
	minikube delete


# Docker - Plain ComfyUI
docker-build:
	docker build -t fizzbuzz2/comfyui-onprem-k8s:comfyui-$(COMFYUI_VERSION) \
		--build-arg COMFYUI_VERSION=$(COMFYUI_VERSION) \
		--platform linux/amd64 \
		--push \
		--build-arg COMFYUI_MANAGER_VERSION=$(COMFYUI_MANAGER_VERSION) \
		-f docker/comfyui.Dockerfile .

docker-push:
	docker push fizzbuzz2/comfyui-onprem-k8s:comfyui-$(COMFYUI_VERSION)

docker-run:
	docker run -it --gpus all -p 50000:50000 \
		-v $(HOME)/models:/home/workspace/ComfyUI/models \
		fizzbuzz2/comfyui-onprem-k8s:comfyui-$(COMFYUI_VERSION)


# Docker - Jupyter ComfyUI
docker-build-jupyter:
	docker build -t fizzbuzz2/comfyui-onprem-k8s:comfyui-jupyter-$(COMFYUI_VERSION) \
		--build-arg BASE_IMAGE=fizzbuzz2/comfyui-onprem-k8s:comfyui-$(COMFYUI_VERSION) \
		--platform linux/amd64 \
		--push \
		-f docker/comfyui-jupyter.Dockerfile .

docker-push-jupyter:
	docker push fizzbuzz2/comfyui-onprem-k8s:comfyui-jupyter-$(COMFYUI_VERSION)

docker-run-jupyter:
	docker run -it --gpus all -p 8888:8888 \
		-v $(HOME)/models:/home/workspace/ComfyUI/models \
		fizzbuzz2/comfyui-onprem-k8s:comfyui-jupyter-$(COMFYUI_VERSION)


# Utils
tunnel:
	minikube tunnel --bind-address="0.0.0.0"
