export CI_PROJECT_PATH_SLUG=springboot-example
export CI_IMAGE_VERSION=$(git log --pretty="%h" | head -n 1)
export CI_ENVIRONMENT_SLUG=review
export CI_REGISTRY=repository.dimas-maryanto.com:8087
export CI_REGISTRY_NAMESPACE=examples/k8s-gitlab-cicd
export CI_REGISTRY_IMAGE=springboot-example
export CI_IMAGE_EXPOSE_PORT=8080
