from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException, Depends, Request, Header
from fastapi.middleware.cors import CORSMiddleware
import json
from typing import Dict, List, Optional
from datetime import datetime
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, firestore
import os
import httpx
from .stripe_billing import (
    create_stripe_payment_intent,
    verify_payment_intent,
    verify_webhook_signature,
)

app = FastAPI(title="Trip Wizards API", version="0.1.0")

# Initialize Firebase
if not firebase_admin._apps:
    cred = credentials.Certificate(os.getenv('FIREBASE_CREDENTIALS', 'firebase_credentials.json'))
    firebase_admin.initialize_app(cred)

db = firestore.client()

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify allowed origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# WebSocket connections storage
active_connections: Dict[str, List[WebSocket]] = {}

class AISuggestRequest(BaseModel):
    prompt: str

class PublishTripRequest(BaseModel):
    trip_id: str

class SubscribeRequest(BaseModel):
    plan: str

class CreatePaymentIntentRequest(BaseModel):
    userId: str
    plan: str
    amount: int

class ConfirmPaymentRequest(BaseModel):
    userId: str
    plan: str
    paymentIntentId: str

@app.post("/ai/suggest")
async def ai_suggest(request: AISuggestRequest):
    # Mock AI response - in production, integrate with ADK
    prompt = request.prompt.lower()
    if 'restaurant' in prompt:
        return {"suggestion": 'I recommend trying local cuisine at "The Golden Fork" - a highly rated restaurant specializing in regional dishes.'}
    elif 'activity' in prompt:
        return {"suggestion": 'For outdoor activities, consider hiking in the nearby national park or visiting the local museum.'}
    else:
        return {"suggestion": 'Based on your trip details, I suggest planning your itinerary around the main attractions and local transportation options.'}

@app.post("/api/v1/community/publish")
async def publish_trip(request: PublishTripRequest):
    try:
        # Get the original trip
        trip_ref = db.collection('trips').document(request.trip_id)
        trip_doc = trip_ref.get()

        if not trip_doc.exists:
            raise HTTPException(status_code=404, detail="Trip not found")

        trip_data = trip_doc.to_dict()

        # Sanitize the trip data (remove PII)
        sanitized_data = {
            'originalTripId': request.trip_id,
            'authorId': trip_data.get('creatorId', ''),
            'authorName': 'Anonymous Traveler',  # Sanitized
            'title': trip_data.get('title', ''),
            'description': trip_data.get('description', ''),
            'destination': trip_data.get('destination', ''),
            'startDate': trip_data.get('startDate'),
            'endDate': trip_data.get('endDate'),
            'likes': 0,
            'likedBy': [],
            'comments': [],
            'publishedAt': datetime.utcnow()
        }

        # Create community trip
        community_ref = db.collection('community_trips').document()
        community_ref.set(sanitized_data)

        return {"message": "Trip published successfully", "community_trip_id": community_ref.id}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    # Mock AI response - in production, integrate with ADK
    prompt = request.prompt.lower()
    if 'restaurant' in prompt:
        return {"suggestion": 'I recommend trying local cuisine at "The Golden Fork" - a highly rated restaurant specializing in regional dishes.'}
    elif 'activity' in prompt:
        return {"suggestion": 'For outdoor activities, consider hiking in the nearby national park or visiting the local museum.'}
    else:
        return {"suggestion": 'Based on your trip details, I suggest planning your itinerary around the main attractions and local transportation options.'}

@app.websocket("/ws/chat/{trip_id}")
async def chat_websocket(websocket: WebSocket, trip_id: str):
    await websocket.accept()
    if trip_id not in active_connections:
        active_connections[trip_id] = []
    active_connections[trip_id].append(websocket)

    try:
        while True:
            data = await websocket.receive_text()
            message_data = json.loads(data)

            # Add timestamp and trip_id to the message
            message_data["timestamp"] = datetime.utcnow().isoformat()
            message_data["trip_id"] = trip_id

            # Store message in Firestore for persistence
            try:
                db.collection('chat_messages').add({
                    'tripId': trip_id,
                    'message': message_data.get('message', ''),
                    'sender': message_data.get('sender', 'unknown'),
                    'isAgent': message_data.get('isAgent', False),
                    'timestamp': message_data['timestamp']
                })
            except Exception as e:
                print(f"Failed to store message: {e}")

            # Broadcast to all connections in the trip
            for connection in active_connections[trip_id]:
                try:
                    await connection.send_text(json.dumps(message_data))
                except Exception as e:
                    print(f"Failed to send message to connection: {e}")
                    # Remove broken connections
                    if connection in active_connections[trip_id]:
                        active_connections[trip_id].remove(connection)

    except WebSocketDisconnect:
        if trip_id in active_connections and websocket in active_connections[trip_id]:
            active_connections[trip_id].remove(websocket)
            if not active_connections[trip_id]:
                del active_connections[trip_id]

@app.post("/api/v1/billing/subscribe")
async def subscribe(request: SubscribeRequest):
    # Mock subscription endpoint - in production, integrate with Stripe
    return {"message": f"Subscribed to {request.plan} plan successfully"}

@app.post("/api/v1/billing/create-payment-intent")
async def create_payment_intent(request: CreatePaymentIntentRequest):
    # Use real Stripe API for payment intent creation
    try:
        result = await create_stripe_payment_intent(
            request.userId,
            request.plan,
            request.amount
        )
        return result
    except HTTPException as e:
        raise e
    except Exception as e:
        # Fallback to mock for development
        return {
            "clientSecret": f"pi_mock_{request.userId}_{request.plan}",
            "amount": request.amount
        }

@app.post("/api/v1/billing/confirm-payment")
async def confirm_payment(request: ConfirmPaymentRequest):
    # Verify payment with Stripe before updating user data
    try:
        # Verify payment intent succeeded
        payment_verified = await verify_payment_intent(request.paymentIntentId)

        if not payment_verified:
            raise HTTPException(status_code=400, detail="Payment verification failed")

        # Update user subscription in Firestore
        user_ref = db.collection('users').document(request.userId)
        user_ref.update({
            'subscriptionPlan': request.plan,
            'updatedAt': datetime.utcnow()
        })

        # Update or initialize user credits
        credits_ref = db.collection('user_credits').document(request.userId)
        plan_credits = {'free': 10, 'pro': 100, 'enterprise': 1000}
        credits_ref.set({
            'remainingCredits': plan_credits.get(request.plan, 10),
            'totalCredits': plan_credits.get(request.plan, 10),
            'lastReset': datetime.utcnow(),
            'updatedAt': datetime.utcnow()
        })

        # Create billing record
        billing_ref = db.collection('billing').document()
        amount_map = {'pro': 9.99, 'enterprise': 49.99, 'free': 0.0}
        billing_ref.set({
            'userId': request.userId,
            'amount': amount_map.get(request.plan, 0.0),
            'currency': 'USD',
            'period': 'monthly',
            'status': 'paid',
            'stripePaymentId': request.paymentIntentId,
            'createdAt': datetime.utcnow(),
            'paidAt': datetime.utcnow()
        })

        return {"message": "Payment confirmed and subscription activated successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    userId: str
    plan: str
    paymentIntentId: str

class CreateOrganizationRequest(BaseModel):
    name: str
    adminId: str

class InviteUserRequest(BaseModel):
    email: str

# Organization endpoints
@app.post("/api/v1/orgs")
async def create_organization(request: CreateOrganizationRequest):
    try:
        # Check if user has enterprise plan
        user_ref = db.collection('users').document(request.adminId)
        user_doc = user_ref.get()
        if not user_doc.exists:
            raise HTTPException(status_code=404, detail="User not found")

        user_data = user_doc.to_dict()
        if user_data.get('subscriptionPlan') != 'enterprise':
            raise HTTPException(status_code=403, detail="Enterprise plan required to create organizations")

        # Create organization
        org_ref = db.collection('organizations').document()
        org_ref.set({
            'name': request.name,
            'adminId': request.adminId,
            'memberIds': [request.adminId],
            'pendingInvites': [],
            'createdAt': datetime.utcnow(),
            'updatedAt': datetime.utcnow()
        })

        return {"id": org_ref.id, "message": "Organization created successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/orgs/{org_id}")
async def get_organization(org_id: str):
    try:
        org_ref = db.collection('organizations').document(org_id)
        org_doc = org_ref.get()

        if not org_doc.exists:
            raise HTTPException(status_code=404, detail="Organization not found")

        return {"id": org_doc.id, **org_doc.to_dict()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/orgs")
async def get_user_organizations(user_id: str):
    try:
        orgs_ref = db.collection('organizations').where('memberIds', 'array_contains', user_id)
        orgs = orgs_ref.stream()

        result = []
        for org in orgs:
            result.append({"id": org.id, **org.to_dict()})

        return {"organizations": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v1/orgs/{org_id}/invite")
async def invite_user_to_org(org_id: str, request: InviteUserRequest):
    try:
        # Check if user is admin (for now, we'll assume the request comes from admin)
        org_ref = db.collection('organizations').document(org_id)
        org_doc = org_ref.get()

        if not org_doc.exists:
            raise HTTPException(status_code=404, detail="Organization not found")

        org_data = org_doc.to_dict()

        # Add to pending invites
        current_invites = org_data.get('pendingInvites', [])
        if request.email in current_invites:
            raise HTTPException(status_code=400, detail="Invite already sent")

        org_ref.update({
            'pendingInvites': current_invites + [request.email],
            'updatedAt': datetime.utcnow()
        })

        return {"message": f"Invite sent to {request.email}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/v1/orgs/{org_id}/invite")
async def cancel_invite(org_id: str, request: InviteUserRequest):
    try:
        # Check if user is admin (for now, we'll assume the request comes from admin)
        org_ref = db.collection('organizations').document(org_id)
        org_doc = org_ref.get()

        if not org_doc.exists:
            raise HTTPException(status_code=404, detail="Organization not found")

        org_data = org_doc.to_dict()

        # Remove from pending invites
        current_invites = org_data.get('pendingInvites', [])
        if request.email not in current_invites:
            raise HTTPException(status_code=404, detail="Invite not found")

        current_invites.remove(request.email)
        org_ref.update({
            'pendingInvites': current_invites,
            'updatedAt': datetime.utcnow()
        })

        return {"message": f"Invite cancelled for {request.email}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v1/orgs/{org_id}/members")
async def add_member_to_org(org_id: str, request: dict):
    try:
        # Check if user is admin (for now, we'll assume the request comes from admin)
        org_ref = db.collection('organizations').document(org_id)
        org_doc = org_ref.get()

        if not org_doc.exists:
            raise HTTPException(status_code=404, detail="Organization not found")

        org_data = org_doc.to_dict()

        member_id = request.get('userId')
        if not member_id:
            raise HTTPException(status_code=400, detail="userId required")

        # Check if user exists
        user_ref = db.collection('users').document(member_id)
        if not user_ref.get().exists:
            raise HTTPException(status_code=404, detail="User not found")

        # Add member
        current_members = org_data.get('memberIds', [])
        if member_id in current_members:
            raise HTTPException(status_code=400, detail="User is already a member")

        # Remove from pending invites if present
        current_invites = org_data.get('pendingInvites', [])
        email_to_remove = request.get('email')
        if email_to_remove and email_to_remove in current_invites:
            current_invites.remove(email_to_remove)

        org_ref.update({
            'memberIds': current_members + [member_id],
            'pendingInvites': current_invites,
            'updatedAt': datetime.utcnow()
        })

        return {"message": f"User {member_id} added to organization"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/billing/webhook")
async def stripe_webhook(request: Request, stripe_signature: str = Header(None)):
    """
    Handle Stripe webhook events for subscription lifecycle management.
    """
    try:
        payload = await request.body()

        # Verify webhook signature
        if not verify_webhook_signature(payload, stripe_signature):
            raise HTTPException(status_code=400, detail="Invalid webhook signature")

        event = json.loads(payload.decode('utf-8'))
        event_type = event.get('type')

        # Handle different event types
        if event_type == 'payment_intent.succeeded':
            payment_intent = event['data']['object']
            user_id = payment_intent['metadata'].get('user_id')
            plan = payment_intent['metadata'].get('plan')

            # Update user subscription
            if user_id and plan:
                user_ref = db.collection('users').document(user_id)
                user_ref.update({
                    'subscriptionPlan': plan,
                    'updatedAt': datetime.utcnow()
                })

        elif event_type == 'customer.subscription.deleted':
            subscription = event['data']['object']
            customer_id = subscription['customer']

            # Downgrade user to free plan
            # Find user by Stripe customer ID and update
            users_ref = db.collection('users').where('stripeCustomerId', '==', customer_id)
            for user_doc in users_ref.stream():
                user_doc.reference.update({
                    'subscriptionPlan': 'free',
                    'updatedAt': datetime.utcnow()
                })

        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/v1/orgs/{org_id}/members/{member_id}")
async def remove_member_from_org(org_id: str, member_id: str):
    try:
        # Check if user is admin (for now, we'll assume the request comes from admin)
        org_ref = db.collection('organizations').document(org_id)
        org_doc = org_ref.get()

        if not org_doc.exists:
            raise HTTPException(status_code=404, detail="Organization not found")

        org_data = org_doc.to_dict()

        # Remove member
        current_members = org_data.get('memberIds', [])
        if member_id not in current_members:
            raise HTTPException(status_code=404, detail="User is not a member")

        current_members.remove(member_id)
        org_ref.update({
            'memberIds': current_members,
            'updatedAt': datetime.utcnow()
        })

        return {"message": f"User {member_id} removed from organization"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/")
async def root():
    return {"message": "Trip Wizards API"}

@app.get("/health")
async def health():
    """
    Comprehensive health check endpoint for backend services and ADK connectivity.
    Returns: JSON with status of all services (firestore, adk, overall status)
    """
    health_status = {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "services": {}
    }

    # Check Firestore connectivity
    try:
        # Attempt a lightweight read operation
        db.collection('_health_check').limit(1).get()
        health_status["services"]["firestore"] = {
            "status": "healthy",
            "message": "Firestore connection successful"
        }
    except Exception as e:
        health_status["services"]["firestore"] = {
            "status": "unhealthy",
            "message": f"Firestore connection failed: {str(e)}"
        }
        health_status["status"] = "degraded"

    # Check ADK connectivity (via HTTP request to ADK service if available)
    try:
        adk_url = os.getenv('ADK_SERVICE_URL', 'http://localhost:8001/health')
        timeout = httpx.Timeout(5.0, connect=3.0)

        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.get(adk_url)
            if response.status_code == 200:
                health_status["services"]["adk"] = {
                    "status": "healthy",
                    "message": "ADK service reachable"
                }
            else:
                health_status["services"]["adk"] = {
                    "status": "unhealthy",
                    "message": f"ADK service returned status {response.status_code}"
                }
                health_status["status"] = "degraded"
    except httpx.TimeoutException:
        health_status["services"]["adk"] = {
            "status": "unhealthy",
            "message": "ADK service timeout"
        }
        health_status["status"] = "degraded"
    except Exception as e:
        health_status["services"]["adk"] = {
            "status": "unknown",
            "message": f"ADK connectivity check skipped: {str(e)}"
        }
        # Don't mark as degraded if ADK is optional/not configured

    # Check Firebase Auth (basic check)
    try:
        firebase_admin.get_app()
        health_status["services"]["firebase_auth"] = {
            "status": "healthy",
            "message": "Firebase Admin SDK initialized"
        }
    except Exception as e:
        health_status["services"]["firebase_auth"] = {
            "status": "unhealthy",
            "message": f"Firebase Admin SDK error: {str(e)}"
        }
        health_status["status"] = "degraded"

    return health_status
