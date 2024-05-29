from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from mangum import Mangum

app = FastAPI()

origins = [
    "*",  # 모든 도메인 허용 (보안상의 이유로 필요에 따라 제한)
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    # allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def read_root():
    return {"Hello": "World"}


# Mangum 핸들러 생성
handler = Mangum(app)
