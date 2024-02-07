# Rounds Challenge Solution

## Infrastructure

Defined with Terraform, the infrastructure is composed of:
- Bucket to store the files
- Application Load Balancer with Cloud CDN to serve the files
- Code Deploy for the application deployment to two targets UAT and PROD which are run on Cloud Run
- Cloud Run templates are defined in the service directory

## CI/CD

The CI/CD is defined with GitHub Actions, the workflow is defined in the .github/workflows directory and is triggered on push to the main branch. Tests and service image build are defined in the workflow, the deployment is done with the Code Deploy.
Code Deploy deploys application to two targets UAT and PROD, the deployment UAT is done in a rolling fashion, the deployment PROD is done with a canary deployment.

## Monitoring

Service logs are tracked through Cloud Run logs.

## Appication

The application is a simple web server that accepts file uploads and serves the files. The application is written in Python and uses Flask. Files are served over Cloud CDN and Application Load Balancer.
