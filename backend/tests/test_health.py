"""
Tests for health check endpoint
"""
import sys
import os

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
from trip_wizards.main import app

client = TestClient(app)


def test_health_endpoint_exists():
    """Test that /health endpoint is accessible"""
    response = client.get("/health")
    assert response.status_code == 200


def test_health_response_structure():
    """Test that health response has correct structure"""
    response = client.get("/health")
    data = response.json()

    assert "status" in data
    assert "timestamp" in data
    assert "services" in data
    assert isinstance(data["services"], dict)


@patch('trip_wizards.main.db')
def test_health_firestore_healthy(mock_db):
    """Test health check when Firestore is healthy"""
    # Mock successful Firestore query
    mock_collection = MagicMock()
    mock_db.collection.return_value = mock_collection
    mock_collection.limit.return_value.get.return_value = []

    response = client.get("/health")
    data = response.json()

    assert "firestore" in data["services"]
    assert data["services"]["firestore"]["status"] == "healthy"


@patch('trip_wizards.main.db')
def test_health_firestore_unhealthy(mock_db):
    """Test health check when Firestore connection fails"""
    # Mock Firestore connection failure
    mock_db.collection.side_effect = Exception("Connection failed")

    response = client.get("/health")
    data = response.json()

    assert "firestore" in data["services"]
    assert data["services"]["firestore"]["status"] == "unhealthy"
    assert data["status"] == "degraded"


@patch('trip_wizards.main.httpx.AsyncClient')
@patch('trip_wizards.main.db')
def test_health_adk_reachable(mock_db, mock_httpx_client):
    """Test health check when ADK service is reachable"""
    # Mock successful Firestore
    mock_collection = MagicMock()
    mock_db.collection.return_value = mock_collection
    mock_collection.limit.return_value.get.return_value = []

    # Mock successful ADK response
    mock_response = MagicMock()
    mock_response.status_code = 200

    mock_client_instance = MagicMock()
    mock_client_instance.__aenter__.return_value = mock_client_instance
    mock_client_instance.__aexit__.return_value = None
    mock_client_instance.get.return_value = mock_response
    mock_httpx_client.return_value = mock_client_instance

    response = client.get("/health")
    data = response.json()

    assert "adk" in data["services"]
    assert data["services"]["adk"]["status"] == "healthy"


@patch('trip_wizards.main.firebase_admin.get_app')
@patch('trip_wizards.main.db')
def test_health_firebase_auth_healthy(mock_db, mock_get_app):
    """Test health check when Firebase Auth is initialized"""
    # Mock successful Firestore
    mock_collection = MagicMock()
    mock_db.collection.return_value = mock_collection
    mock_collection.limit.return_value.get.return_value = []

    # Mock Firebase app initialized
    mock_get_app.return_value = MagicMock()

    response = client.get("/health")
    data = response.json()

    assert "firebase_auth" in data["services"]
    assert data["services"]["firebase_auth"]["status"] == "healthy"
