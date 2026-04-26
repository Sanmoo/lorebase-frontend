#!/usr/bin/env python3
"""Generate Cognito JWT tokens for API testing via USER_PASSWORD_AUTH.

Usage:
    python scripts/get_cognito_token.py <email> [password]

If password is omitted, prompts securely via getpass.
Outputs JSON with AccessToken, IdToken, RefreshToken, and ExpiresIn.

Dependencies: boto3
"""

import argparse
import getpass
import json
import sys

import boto3

_CLIENT_ID = "7fe09t6psk19bdc0n11gkmup14"
_REGION = "us-east-1"


def get_tokens(email: str, password: str) -> dict:
    client = boto3.client("cognito-idp", region_name=_REGION)

    resp = client.initiate_auth(
        ClientId=_CLIENT_ID,
        AuthFlow="USER_PASSWORD_AUTH",
        AuthParameters={"USERNAME": email, "PASSWORD": password},
    )

    return resp["AuthenticationResult"]


def main():
    parser = argparse.ArgumentParser(description="Get Cognito JWT tokens")
    parser.add_argument("email", help="Cognito user email")
    parser.add_argument("password", nargs="?", help="User password (omit for prompt)")
    parser.add_argument(
        "--raw", action="store_true", help="Output only the access token (for piping)"
    )
    args = parser.parse_args()

    password = args.password or getpass.getpass()

    try:
        auth_result = get_tokens(args.email, password)
    except Exception:
        import traceback

        traceback.print_exc()
        sys.exit(1)

    if args.raw:
        print(auth_result["AccessToken"])
    else:
        print(json.dumps(auth_result, indent=2))


if __name__ == "__main__":
    main()
