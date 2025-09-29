# PlayWithMe Infrastructure Management Makefile
# Multi-environment Terraform automation for Firebase

.PHONY: help init plan apply destroy firebase-setup clean all-envs

# Default environment (can be overridden with ENV=prod make command)
ENV ?= dev

# Environment validation
VALID_ENVS := dev stg prod
ifeq ($(filter $(ENV),$(VALID_ENVS)),)
    $(error Invalid environment: $(ENV). Valid environments are: $(VALID_ENVS))
endif

# Terraform working directory
TF_DIR := infrastructure/environments/$(ENV)

# Colors for output
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
BLUE := \033[34m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)PlayWithMe Infrastructure Management$(NC)"
	@echo ""
	@echo "$(GREEN)Usage:$(NC)"
	@echo "  make [target] [ENV=<env>]"
	@echo ""
	@echo "$(GREEN)Environments:$(NC)"
	@echo "  dev  - Development environment (default)"
	@echo "  stg  - Staging environment"
	@echo "  prod - Production environment"
	@echo ""
	@echo "$(GREEN)Targets:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform for specified environment
	@echo "$(GREEN)Initializing Terraform for $(ENV) environment...$(NC)"
	@cd $(TF_DIR) && terraform init

plan: init ## Plan Terraform changes for specified environment
	@echo "$(GREEN)Planning Terraform changes for $(ENV) environment...$(NC)"
	@cd $(TF_DIR) && terraform plan

apply: init ## Apply Terraform changes for specified environment
	@echo "$(GREEN)Applying Terraform changes for $(ENV) environment...$(NC)"
	@cd $(TF_DIR) && terraform apply

auto-apply: init ## Apply Terraform changes automatically (no confirmation)
	@echo "$(GREEN)Auto-applying Terraform changes for $(ENV) environment...$(NC)"
	@cd $(TF_DIR) && terraform apply -auto-approve

destroy: init ## Destroy Terraform infrastructure for specified environment
	@echo "$(RED)Destroying Terraform infrastructure for $(ENV) environment...$(NC)"
	@echo "$(YELLOW)This action is destructive and cannot be undone!$(NC)"
	@cd $(TF_DIR) && terraform destroy

firebase-setup: apply ## Apply Terraform and set up Firebase components
	@echo "$(GREEN)Setting up Firebase components for $(ENV) environment...$(NC)"
	@echo "$(YELLOW)Deploying Firestore security rules...$(NC)"
	@firebase deploy --only firestore:rules --project $(shell cd $(TF_DIR) && terraform output -raw project_id)
	@echo "$(YELLOW)Running collection setup script...$(NC)"
	@cd scripts && PROJECT_ID=$(shell cd $(TF_DIR) && terraform output -raw project_id) node setup-collections.js

output: init ## Show Terraform outputs for specified environment
	@echo "$(GREEN)Terraform outputs for $(ENV) environment:$(NC)"
	@cd $(TF_DIR) && terraform output

validate: init ## Validate Terraform configuration for specified environment
	@echo "$(GREEN)Validating Terraform configuration for $(ENV) environment...$(NC)"
	@cd $(TF_DIR) && terraform validate

format: ## Format all Terraform files
	@echo "$(GREEN)Formatting Terraform files...$(NC)"
	@terraform fmt -recursive infrastructure/

clean: ## Clean Terraform temporary files for specified environment
	@echo "$(GREEN)Cleaning Terraform temporary files for $(ENV) environment...$(NC)"
	@cd $(TF_DIR) && rm -rf .terraform terraform.tfstate.backup

# Multi-environment targets
all-envs-plan: ## Plan all environments (dev, stg, prod)
	@echo "$(BLUE)Planning all environments...$(NC)"
	@$(MAKE) plan ENV=dev
	@$(MAKE) plan ENV=stg
	@$(MAKE) plan ENV=prod

all-envs-apply: ## Apply all environments (dev, stg, prod)
	@echo "$(BLUE)Applying all environments...$(NC)"
	@$(MAKE) apply ENV=dev
	@$(MAKE) apply ENV=stg
	@$(MAKE) apply ENV=prod

all-envs-firebase-setup: ## Set up Firebase for all environments
	@echo "$(BLUE)Setting up Firebase for all environments...$(NC)"
	@$(MAKE) firebase-setup ENV=dev
	@$(MAKE) firebase-setup ENV=stg
	@$(MAKE) firebase-setup ENV=prod

all-envs-output: ## Show outputs for all environments
	@echo "$(BLUE)Outputs for all environments:$(NC)"
	@echo ""
	@echo "$(GREEN)=== DEV Environment ===$(NC)"
	@$(MAKE) output ENV=dev
	@echo ""
	@echo "$(GREEN)=== STG Environment ===$(NC)"
	@$(MAKE) output ENV=stg
	@echo ""
	@echo "$(GREEN)=== PROD Environment ===$(NC)"
	@$(MAKE) output ENV=prod

# Safety checks
check-env: ## Check if required tools are installed
	@echo "$(GREEN)Checking required tools...$(NC)"
	@which terraform > /dev/null || (echo "$(RED)Error: terraform not found$(NC)" && exit 1)
	@which firebase > /dev/null || (echo "$(RED)Error: firebase CLI not found$(NC)" && exit 1)
	@which gcloud > /dev/null || (echo "$(RED)Error: gcloud CLI not found$(NC)" && exit 1)
	@echo "$(GREEN)All required tools found!$(NC)"

check-auth: ## Check if authenticated with Google Cloud
	@echo "$(GREEN)Checking Google Cloud authentication...$(NC)"
	@gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1 || (echo "$(RED)Error: Not authenticated with gcloud$(NC)" && exit 1)
	@echo "$(GREEN)Authenticated with Google Cloud!$(NC)"

# Prerequisites check
prerequisites: check-env check-auth ## Check all prerequisites
	@echo "$(GREEN)All prerequisites satisfied!$(NC)"

# Quick setup targets
setup-dev: ## Quick setup for dev environment
	@$(MAKE) firebase-setup ENV=dev

setup-stg: ## Quick setup for stg environment
	@$(MAKE) firebase-setup ENV=stg

setup-prod: ## Quick setup for prod environment
	@$(MAKE) firebase-setup ENV=prod