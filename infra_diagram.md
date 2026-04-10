# AWS Infrastructure Diagram for Spotify Serverless App

```mermaid
graph TB
    User[User] --> Frontend[CloudFront + S3<br/>React SPA]
    Frontend --> APIGW[API Gateway]
    APIGW --> Cognito[Cognito<br/>Authentication]
    APIGW --> API_Lambdas[API Lambdas<br/>Business Logic]
    
    API_Lambdas --> DynamoDB[(DynamoDB<br/>Tracks, Users, Events)]
    API_Lambdas --> OpenSearch[(OpenSearch<br/>Search Index)]
    API_Lambdas --> EventBridge[EventBridge<br/>Event Bus]
    
    EventBridge --> SQS[SQS Queues]
    SQS --> StepFunctions[Step Functions<br/>Orchestration]
    StepFunctions --> Orchestration_Lambdas[Orchestration Lambdas<br/>Analytics, Stats]
    Orchestration_Lambdas --> DynamoDB
    
    EventBridge --> Event_Lambdas[Event Lambdas<br/>Store Events, Update Stats,<br/>Process Uploads, Notifications]
    Event_Lambdas --> DynamoDB
    
    Media[CloudFront + S3<br/>Audio Tracks] --> User
    
    API_Lambdas --> Media
    Orchestration_Lambdas --> Media
    
    subgraph "Monitoring & Observability"
        CloudWatch[CloudWatch<br/>Logs, Metrics, Alarms]
    end
    
    API_Lambdas --> CloudWatch
    Orchestration_Lambdas --> CloudWatch
    Event_Lambdas --> CloudWatch
    
    subgraph "Security"
        KMS[KMS<br/>Encryption Keys]
        IAM[IAM<br/>Roles & Policies]
    end
    
    DynamoDB --> KMS
    Media --> KMS
    API_Lambdas --> IAM
    Orchestration_Lambdas --> IAM
    Event_Lambdas --> IAM
```</content>
<parameter name="filePath">/Users/ec2-user/spotify-app/infra_diagram.md