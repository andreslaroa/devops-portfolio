import os
import time
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

# 1. Database Configuration via Environment Variables
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:password@localhost:5432/portfolio_db")

# Wait for DB to be ready (retry loop for robust Docker startup)
engine = None
for _ in range(5):
    try:
        engine = create_engine(DATABASE_URL)
        break
    except Exception:
        time.sleep(2)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# 2. Database Model
class Item(Base):
    __tablename__ = "items"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String)

# Create tables if they don't exist
if engine:
    Base.metadata.create_all(bind=engine)

# 3. FastAPI Initialization
app = FastAPI(title="DevOps Portfolio Enterprise API", version="2.0.0")

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 4. Endpoints
@app.get("/health", tags=["Monitoring"])
def health_check(db: Session = Depends(get_db)):
    try:
        # Test DB connection health
        db.execute("SELECT 1")
        return {"status": "healthy", "database": "connected", "environment": os.getenv("ENV", "production")}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database unhealthy: {str(e)}")

@app.post("/items", tags=["Business Logic"])
def create_item(title: str, description: str, db: Session = Depends(get_db)):
    db_item = Item(title=title, description=description)
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item

@app.get("/items", tags=["Business Logic"])
def read_items(db: Session = Depends(get_db)):
    return db.query(Item).all()
