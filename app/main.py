import os
import time
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy import create_backend, create_engine, Column, Integer, String, Boolean
from sqlalchemy.orm import declarative_base, sessionmaker, Session

# Configuración de la Base de Datos (Se lee de variables de entorno, buena práctica Cloud/DevOps)
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@localhost:5432/todo_db")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Modelo de la Base de Datos
class TodoItem(Base):
    __tablename__ = "todos"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    completed = Column(Boolean, default=False)

# Crear las tablas si no existen (Para simplificar el inicio local)
try:
    Base.metadata.create_all(bind=engine)
except Exception as e:
    print(f"Esperando a la base de datos... Error temporal: {e}")

app = FastAPI(title="DevOps Portfolio API")

# Dependencia para obtener la sesión de BD
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- Endpoints ---

@app.get("/health", tags=["DevOps"])
def health_check():
    """Endpoint que usarán los balanceadores y Kubernetes para verificar la app"""
    return {"status": "healthy", "timestamp": time.time()}

@app.get("/todos", tags=["Items"])
def get_todos(db: Session = Depends(get_db)):
    return db.query(TodoItem).all()

@app.post("/todos", tags=["Items"])
def create_todo(title: str, completed: bool = False, db: Session = Depends(get_db)):
    db_item = TodoItem(title=title, completed=completed)
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item
