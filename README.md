# Serverless Event-Driven Survey API

A fully decoupled, full-stack serverless application deployed on AWS using Terraform. This platform processes user survey submissions, securely handles asynchronous reward fulfillment via SQS, and exposes a vanilla web frontend with dynamic status polling. 

---

## Architecture Overview

The application utilizes an event-driven microservices architecture to ensure high availability and responsiveness. The frontend receives millisecond-latency responses while heavy processing is deferred to background workers.

```text
[ Web Frontend (Vanilla JS/HTML) ]
             │
             ▼  (REST API - CORS Enabled)
      [ AWS API Gateway ]
        /              \
    (POST)            (GET)
      /                  \
[Validation Lambda]  [Status Checker Lambda]
      │                      │
      ├── (Writes) ──▼       │ (Reads)
      │         [ DynamoDB ] ◄───
      ▼                      
[ Amazon SQS ]
      │
      ▼ (Event Source Mapping)
[Fulfillment Worker Lambda] ──► (Processes Reward Asynchronously)
```

---

## Tech Stack

* **Application:** Python 3.11, Vanilla HTML/JS/CSS (Fetch API)
* **Compute:** AWS Lambda 
* **API Routing:** AWS API Gateway v2 (HTTP API)
* **Messaging & Database:** Amazon SQS, Amazon DynamoDB
* **Infrastructure as Code (IaC):** Terraform

---

## Key Cloud Engineering Features

* **Event-Driven Decoupling:** API Gateway traffic is immediately processed and offloaded to an SQS queue, allowing the frontend to remain highly responsive while backend workers handle fulfillment asynchronously.
* **CORS & Network Routing:** Explicit API Gateway integration configuring `Access-Control-Allow-Origin` headers, unblocking cross-origin resource sharing for `POST`, `GET`, and `OPTIONS` methods.
* **Infrastructure as Code:** Complete AWS environment—including IAM roles, event source mappings, Lambda deployments, and API Gateway stages—managed deterministically via Terraform.
* **Asynchronous UX:** The frontend implements a "Rewards Wallet" polling mechanism, dynamically querying the `/survey/{transaction_id}` route to update the UI when background workers finish processing.

---

## Repository Structure

```text
.
├── config.example.js            # Template for local environment variables
├── index.html                   # Web client with survey form and polling UI
├── README.md                    # Project documentation
├── infrastructure/              # Terraform IaC definitions
│   ├── api_gateway.tf           # API Gateway configuration and CORS
│   ├── dynamodb.tf              # Database table for transaction state
│   ├── event_making.tf          # SQS to Lambda event source mapping
│   ├── fulfillment_worker.tf    # Backend worker Lambda provisioning
│   ├── iam_github.tf            # GitHub Actions CI/CD role definitions
│   ├── lambda.tf                # Validation Lambda provisioning
│   ├── providers.tf             # AWS provider configuration
│   ├── sqs.tf                   # Asynchronous message queue
│   └── status_api.tf            # GET route and Status Checker Lambda
└── src/                         # Python Lambda deployment packages
    ├── fulfillment/main.py      # Consumes SQS messages in the background
    ├── status/main.py           # Exposes transaction status to the frontend
    └── validation/main.py       # Validates input and publishes to SQS
```
*(Note: Generated state files, `config.js`, test payloads, and Lambda `.zip` artifacts are excluded from version control).*

---

## API Endpoints

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/survey` | Accepts submissions, routes payload to SQS, and returns a transaction ID. |
| `GET` | `/survey/{transaction_id}` | Polls DynamoDB for asynchronous reward processing status. |

#### Sample POST Response:
```json
{
  "message": "Survey Processed Successfully",
  "points": 50,
  "transaction_id": "9a39aa73-5cc7-49b9-9147-90dffce4889a"
}
```

---

## Setup & Deployment Instructions

### 1. Provision Infrastructure via Terraform
Navigate to the `infrastructure` directory and apply the Terraform configuration to provision the AWS resources.
```bash
cd infrastructure
terraform init
terraform apply -auto-approve
```

### 2. Configure Environment Variables
Copy the configuration template to create your local config file:
```bash
cp config.example.js config.js
```
Open `config.js` and paste your newly deployed API Gateway endpoint URL (e.g., `https://<your-api-id>.execute-api.<region>.amazonaws.com`).

### 3. Run the Frontend Locally
Due to strict CORS policies regarding `file:///` origins, the frontend must be served via a local web server.
```bash
# From the root directory containing index.html
python3 -m http.server 8000
```
Open a web browser and navigate to `http://localhost:8000`.

---

## Contact

**Sujal Surani** - [https://www.linkedin.com/in/sujal-surani/]

## Maintainer

Created and maintained by **Sujal Surani**.
