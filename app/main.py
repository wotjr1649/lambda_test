# app/main.py
from fastapi import FastAPI

app = FastAPI(openapi_prefix="/api/v1")

@app.get("/")
async def root():
    return {"message": "Hello, World!"}
@app.get("/test")
async def root():
    return {"message": "Hello, test!"}
