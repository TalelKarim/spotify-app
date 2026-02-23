workspace "Spotify Serverless Architecture" "C4 Model for Spotify-like AWS system" {

    model {

        user = person "User" "End user of the Spotify application"

        cognito = softwareSystem "Amazon Cognito" "Authentication provider"

        spotify = softwareSystem "Spotify System" {

            frontend = container "Web Application" "React SPA hosted on S3 + CloudFront" "JavaScript"

            api = container "API Gateway" "Exposes REST endpoints" "AWS API Gateway"

            apiLambdas = container "API Lambda Layer" "Handles REST business logic (play, search, analytics, etc.)" "AWS Lambda"

            eventbridge = container "EventBridge" "Event bus for domain events" "AWS EventBridge"

            sqs = container "SQS Queue" "Queues domain events for async processing" "AWS SQS"

            stepFunctions = container "Step Functions" "Orchestrates async workflows" "AWS Step Functions"

            orchestrationLambdas = container "Orchestration Lambdas" "Update track stats, user stats, analytics" "AWS Lambda"

            dynamo = container "DynamoDB" "Primary data store (single-table design)" "AWS DynamoDB"

            opensearch = container "OpenSearch" "Search index for tracks" "AWS OpenSearch"
        }

        user -> frontend "Uses via browser"
        frontend -> api "Calls REST API"
        api -> cognito "Validates JWT"
        api -> apiLambdas "Triggers"
        apiLambdas -> eventbridge "Publishes domain events"
        eventbridge -> sqs "Routes events"
        sqs -> stepFunctions "Triggers workflow"
        stepFunctions -> orchestrationLambdas "Executes steps"
        orchestrationLambdas -> dynamo "Reads/Writes data"
        apiLambdas -> dynamo "Reads/Writes data"
        apiLambdas -> opensearch "Indexes / Searches tracks"

    }

    views {

        container spotify {
            include *
            autolayout lr
        }

        theme default
    }
}