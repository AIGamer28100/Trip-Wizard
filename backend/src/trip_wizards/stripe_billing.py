# Stripe integration for Trip Wizards billing
# This module handles payment intent creation, subscription management,
# and webhook processing for Stripe payments.

import os
import stripe
from fastapi import HTTPException
from typing import Optional

# Initialize Stripe with secret key
stripe.api_key = os.getenv('STRIPE_SECRET_KEY', 'sk_test_mock_key')

PLAN_PRICES = {
    'free': 0,
    'pro': 999,  # $9.99 in cents
    'enterprise': 4999  # $49.99 in cents
}

PLAN_CREDITS = {
    'free': 10,
    'pro': 100,
    'enterprise': 1000
}


async def create_stripe_payment_intent(user_id: str, plan: str, amount: int) -> Optional[dict]:
    """
    Create a Stripe Payment Intent for subscription payment.

    Args:
        user_id: The user ID making the purchase
        plan: The subscription plan (free, pro, enterprise)
        amount: The amount in cents

    Returns:
        Dictionary with clientSecret and paymentIntentId
    """
    try:
        # Create payment intent
        intent = stripe.PaymentIntent.create(
            amount=amount,
            currency='usd',
            metadata={
                'user_id': user_id,
                'plan': plan,
            },
            description=f'Trip Wizards {plan.capitalize()} Subscription',
        )

        return {
            'clientSecret': intent.client_secret,
            'paymentIntentId': intent.id,
            'amount': amount
        }
    except stripe.error.StripeError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Failed to create payment intent: {str(e)}')


async def verify_payment_intent(payment_intent_id: str) -> bool:
    """
    Verify that a payment intent was successful.

    Args:
        payment_intent_id: The Stripe payment intent ID

    Returns:
        True if payment was successful, False otherwise
    """
    try:
        intent = stripe.PaymentIntent.retrieve(payment_intent_id)
        return intent.status == 'succeeded'
    except stripe.error.StripeError:
        return False


async def create_stripe_customer(user_id: str, email: str) -> str:
    """
    Create a Stripe customer for recurring subscriptions.

    Args:
        user_id: The user ID
        email: User's email address

    Returns:
        Stripe customer ID
    """
    try:
        customer = stripe.Customer.create(
            email=email,
            metadata={'user_id': user_id}
        )
        return customer.id
    except stripe.error.StripeError as e:
        raise HTTPException(status_code=400, detail=str(e))


async def create_subscription(customer_id: str, price_id: str) -> dict:
    """
    Create a recurring subscription for a customer.

    Args:
        customer_id: The Stripe customer ID
        price_id: The Stripe price ID for the plan

    Returns:
        Subscription details
    """
    try:
        subscription = stripe.Subscription.create(
            customer=customer_id,
            items=[{'price': price_id}],
        )

        return {
            'subscription_id': subscription.id,
            'status': subscription.status,
            'current_period_end': subscription.current_period_end
        }
    except stripe.error.StripeError as e:
        raise HTTPException(status_code=400, detail=str(e))


async def cancel_subscription(subscription_id: str) -> bool:
    """
    Cancel a subscription.

    Args:
        subscription_id: The Stripe subscription ID

    Returns:
        True if cancellation successful
    """
    try:
        stripe.Subscription.delete(subscription_id)
        return True
    except stripe.error.StripeError:
        return False


def verify_webhook_signature(payload: bytes, signature: str) -> bool:
    """
    Verify Stripe webhook signature.

    Args:
        payload: The raw request payload
        signature: The Stripe signature header

    Returns:
        True if signature is valid
    """
    webhook_secret = os.getenv('STRIPE_WEBHOOK_SECRET', 'whsec_mock_secret')

    try:
        stripe.Webhook.construct_event(
            payload, signature, webhook_secret
        )
        return True
    except (ValueError, stripe.error.SignatureVerificationError):
        return False
