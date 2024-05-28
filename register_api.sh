#!/bin/bash

API_ID="xhoazt7th9"
REGION="ap-northeast-2"
LAMBDA_ARN="arn:aws:lambda:ap-northeast-2:767397715593:function:lambda-test2"


# 기존 리소스 ID 가져오기 (리소스 경로를 알고 있다고 가정)
RESOURCE_PATH="https://xhoazt7th9.execute-api.ap-northeast-2.amazonaws.com"  # 기존 리소스 경로
RESOURCE_ID=$(aws apigateway get-resources --rest-api-id $API_ID --region $REGION --query "items[?path=='$RESOURCE_PATH'].id" --output text)

if [ -z "$RESOURCE_ID" ]; then
  echo "Resource not found: $RESOURCE_PATH"
  exit 1
fi

# 메서드 생성 또는 업데이트
aws apigateway put-method --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method ANY --authorization-type "NONE" || echo "Method already exists"

# 통합 생성 또는 업데이트
aws apigateway put-integration --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method ANY --type AWS_PROXY --integration-http-method POST --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations || echo "Integration already exists"

# API 배포
aws apigateway create-deployment --rest-api-id $API_ID --stage-name prod

# Lambda 함수에 API Gateway 권한 부여
aws lambda add-permission --function-name my-fastapi-function --statement-id apigateway-access --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn arn:aws:execute-api:$REGION:$(aws sts get-caller-identity --query Account --output text):$API_ID/*/* || echo "Permission already granted"

echo "API Gateway URL: https://$API_ID.execute-api.$REGION.amazonaws.com/prod/$RESOURCE_PATH"
