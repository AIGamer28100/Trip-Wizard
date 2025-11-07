from trip_wizards.main import app
from fastapi.testclient import TestClient

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert "Trip Wizards API" in response.json()["message"]

def test_ai_suggest():
    response = client.post("/ai/suggest", json={"prompt": "restaurant"})
    assert response.status_code == 200
    assert "suggestion" in response.json()