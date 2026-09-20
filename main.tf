name: Terraform CI

on:
  pull_request:
    branches:
      - main

permissions:
  id-token: write
  contents: read

jobs:
  terraform-check:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: 1f0f603a-e0ed-4e19-9b4d-c9e4f83427a1
          tenant-id: 4c532d92-1011-4c5b-9eab-cc4e4c69ebea
          subscription-id: cb41360b-21e3-4b57-b297-f8974cb9adf8

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan