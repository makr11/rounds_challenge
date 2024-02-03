# Deployment Instructions

## Prerequisites
- Create bucket for terraform state with the name "rounds-challenge-terraform-state".

## Steps

1. Clone the repository:
    ```bash
    git clone <repository_url>
    ```

2. Navigate to the project directory:
    ```bash
    cd <project_directory>
    ```

3. Install dependencies:
    ```bash
    npm install
    ```

4. Build the application:
    ```bash
    npm run build
    ```

5. Configure the environment variables:
    - Open the `.env` file.
    - Update the necessary variables with the appropriate values.

6. Start the application:
    ```bash
    npm start
    ```

7. Verify the deployment:
    - Open a web browser.
    - Enter the URL: `http://<server_address>:<port>`.
    - Ensure that the application is running correctly.

## Troubleshooting

If you encounter any issues during the deployment process, refer to the following troubleshooting steps:

- [ ] Check the application logs for any error messages.
- [ ] Verify that all the required dependencies are installed.
- [ ] Ensure that the environment variables are correctly configured.
- [ ] Restart the application and check if the issue persists.

If the issue still persists, please contact the support team for further assistance.