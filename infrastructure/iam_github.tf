# infrastructure/iam_github.tf

provider "aws" {
  region = "ap-south-1" # Change if deploying elsewhere
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

# 2. Create the IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "github-actions-serverless-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        # STRICT SECURITY: Only allow your specific repo to assume this role
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:sujal-surani/serverless-survey-api:*"
        }
      }
    }]
  })
}

# 3. Attach Administrator permissions (for CI/CD bootstrapping)
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 4. Output the Role ARN so we can use it in GitHub Actions
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}