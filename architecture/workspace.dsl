workspace "Spotify Serverless Architecture" "C4 Model for Spotify-like AWS system" {

    model {

        user = person "User" "End user of the Spotify application"

        system = softwareSystem "Spotify System" {
            description "Serverless Spotify-like streaming platform on AWS"
        }

        cognito = softwareSystem "Amazon Cognito" "Authentication provider"
        eventbridge = softwareSystem "Amazon EventBridge" "Event bus"
        sqs = softwareSystem "Amazon SQS" "Message queue"
        opensearch = softwareSystem "Amazon OpenSearch" "Search engine"

        user -> system "Uses"
        system -> cognito "Authenticates users via JWT"
        system -> eventbridge "Publishes domain events"
        eventbridge -> sqs "Fan-out events"
        system -> opensearch "Searches tracks"

    }

    views {

        systemContext system {
            include *
            autolayout lr
        }

        theme default
    }
}