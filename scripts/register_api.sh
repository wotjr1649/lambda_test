#!/bin/bash

API_ID="xhoazt7th9"
REGION="ap-northeast-2"
LAMBDA_ARN="arn:aws:lambda:ap-northeast-2:767397715593:function:lambda-test2"

# Get the root resource id
PARENT_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id $API_ID --region $REGION --query 'items[0].id' --output text)

# Create or update a resource
RESOURCE_ID=$(aws apigateway create-resource --rest-api-id $API_ID --parent-id $PARENT_RESOURCE_ID --path-part '{proxy+}' --query 'id' --output text || aws apigateway get-resources --rest-api-id $API_ID --region $REGION --query 'items[?path==`/{proxy+}`].id' --output text)

# Create or update a method
aws apigateway put-method --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method ANY --authorization-type "NONE" || echo "Method already exists"

# Create or update an integration
aws apigateway put-integration --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method ANY --type AWS_PROXY --integration-http-method POST --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations || echo "Integration already exists"

# Deploy the API
aws apigateway create-deployment --rest-api-id $API_ID --stage-name prod

# Grant API Gateway permission to invoke the Lambda function
aws lambda add-permission --function-name my-fastapi-function --statement-id apigateway-access --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn arn:aws:execute-api:$REGION:$(aws sts get-caller-identity --query Account --output text):$API_ID/*/* || echo "Permission already granted"

echo "API Gateway URL: https://$API_ID.execute-api.$REGION.amazonaws.com/prod/{proxy+}"