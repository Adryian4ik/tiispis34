from fastapi import FastAPI, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from typing import List
from database import SessionLocal, init_db
from models import User, Password
from security import (
    hash_password, authenticate_user, create_access_token, oauth2_scheme,
    encrypt_password, decrypt_password
)
from fastapi.security import OAuth2PasswordRequestForm

app = FastAPI()

# Подключение к базе данных
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Инициализация базы данных
init_db()

# Модель пользователя
class UserCreate(BaseModel):
    username: str
    password: str

@app.post("/users/", response_model=UserCreate)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == user.username).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    hashed_password = hash_password(user.password)
    new_user = User(username=user.username, password=hashed_password)
    db.add(new_user)
    db.commit()
    return new_user

# Вход и получение токена
@app.post("/token")
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}

# Модель пароля
class PasswordCreate(BaseModel):
    account: str
    password: str

class PasswordResponse(BaseModel):
    account: str
    password: str

# Добавление пароля
@app.post("/passwords/", response_model=PasswordCreate)
def create_password(password: PasswordCreate, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    encrypted_password = encrypt_password(password.password)
    new_password = Password(account=password.account, password=encrypted_password)
    db.add(new_password)
    db.commit()
    return password

# Получение паролей
@app.get("/passwords/", response_model=List[PasswordResponse])
def get_passwords(skip: int = 0, limit: int = 10, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    passwords = db.query(Password).offset(skip).limit(limit).all()
    decrypted_passwords = [
        PasswordResponse(account=p.account, password=decrypt_password(p.password))
        for p in passwords
    ]
    return decrypted_passwords

# Запуск сервера
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
