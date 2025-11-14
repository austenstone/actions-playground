import json
import os
import urllib.request
import jwt
from jwt import PyJWKClient

# Configuration
GITHUB_OIDC_ISSUER = "https://token.actions.githubusercontent.com"
JWKS_URL = f"{GITHUB_OIDC_ISSUER}/.well-known/jwks"
GITHUB_ORG = os.environ.get("GITHUB_ORG", "octodemo")
GITHUB_REPO = os.environ.get("GITHUB_REPO", "actions-playground")
OIDC_AUDIENCE = os.environ.get("OIDC_AUDIENCE", "api://ActionsOIDCGateway")

def lambda_handler(event, context):
    """
    AWS Lambda authorizer for GitHub Actions OIDC tokens.
    Returns a simple boolean response for API Gateway v2.
    """
    print(f"Received event: {json.dumps(event)}")
    
    try:
        # Extract Authorization header
        headers = event.get("headers", {})
        auth_header = headers.get("authorization") or headers.get("Authorization")
        
        if not auth_header:
            print("No Authorization header found")
            return {"isAuthorized": False}
        
        # Extract Bearer token
        parts = auth_header.split()
        if len(parts) != 2 or parts[0].lower() != "bearer":
            print("Invalid Authorization header format")
            return {"isAuthorized": False}
        
        token = parts[1]
        
        # Validate JWT
        jwks_client = PyJWKClient(JWKS_URL)
        signing_key = jwks_client.get_signing_key_from_jwt(token)
        
        # Decode and validate token
        decoded = jwt.decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            audience=OIDC_AUDIENCE,
            issuer=GITHUB_OIDC_ISSUER
        )
        
        print(f"Token decoded successfully: {json.dumps(decoded)}")
        
        # Validate repository claim
        expected_repo = f"{GITHUB_ORG}/{GITHUB_REPO}"
        actual_repo = decoded.get("repository", "")
        
        if actual_repo != expected_repo:
            print(f"Repository mismatch: expected {expected_repo}, got {actual_repo}")
            return {"isAuthorized": False}
        
        # Success - add claims to context
        print(f"Authorization successful for repository: {actual_repo}")
        return {
            "isAuthorized": True,
            "context": {
                "repository": actual_repo,
                "workflow": decoded.get("workflow", "unknown"),
                "ref": decoded.get("ref", "unknown"),
                "actor": decoded.get("actor", "unknown")
            }
        }
        
    except jwt.ExpiredSignatureError:
        print("Token has expired")
        return {"isAuthorized": False}
    except jwt.InvalidTokenError as e:
        print(f"Invalid token: {str(e)}")
        return {"isAuthorized": False}
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        return {"isAuthorized": False}
