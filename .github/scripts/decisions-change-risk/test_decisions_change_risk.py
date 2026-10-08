import json
import sys
import unittest
from pathlib import Path
from unittest.mock import patch

ACTION_DIR = Path(__file__).parent
sys.path.insert(0, str(ACTION_DIR))

from decisions_change_risk import (  # noqa: E402
    DecisionRefusal,
    DecisionResponseError,
    ApiRequestError,
    GITHUB_CAPI_MODEL,
    GITHUB_CAPI_PROVIDER,
    OPENAI_MODEL,
    OPENAI_PROVIDER,
    build_decisions_request,
    build_diff_input,
    build_request_payload,
    parse_decision_response,
    resolve_capi_origin,
    validate_capi_origin,
    validate_response_model,
)

FIXTURES = ACTION_DIR / "fixtures"
THRESHOLDS = {
    "security_sensitive": 0.65,
    "needs_full_test_suite": 0.55,
    "needs_manual_deploy_approval": 0.60,
    "docs_only": 0.80,
}


def load_fixture(name):
    return json.loads((FIXTURES / name).read_text(encoding="utf-8"))


class DecisionResponseTests(unittest.TestCase):
    def test_high_risk_fixture_routes_extra_work(self):
        result = parse_decision_response(load_fixture("high-risk.json"), THRESHOLDS)

        self.assertEqual(result["model"], "gpt-6-luna")
        self.assertEqual(result["input_tokens"], 1420)
        self.assertIsNone(result["output_tokens"])
        self.assertTrue(result["decisions"]["security_sensitive"])
        self.assertTrue(result["decisions"]["needs_full_test_suite"])
        self.assertTrue(result["decisions"]["needs_manual_deploy_approval"])
        self.assertFalse(result["decisions"]["docs_only"])

    def test_docs_only_fixture_is_signal_not_inverted_routing(self):
        result = parse_decision_response(load_fixture("docs-only.json"), THRESHOLDS)

        self.assertFalse(result["decisions"]["security_sensitive"])
        self.assertFalse(result["decisions"]["needs_full_test_suite"])
        self.assertFalse(result["decisions"]["needs_manual_deploy_approval"])
        self.assertTrue(result["decisions"]["docs_only"])

    def test_probability_equal_to_threshold_routes(self):
        response = load_fixture("docs-only.json")
        response["answers"][1]["probability"] = THRESHOLDS["needs_full_test_suite"]

        result = parse_decision_response(response, THRESHOLDS)

        self.assertTrue(result["decisions"]["needs_full_test_suite"])

    def test_refusal_is_explicit(self):
        with self.assertRaisesRegex(DecisionRefusal, "security_sensitive"):
            parse_decision_response(load_fixture("refusal.json"), THRESHOLDS)

    def test_missing_answer_is_rejected(self):
        with self.assertRaisesRegex(DecisionResponseError, "docs_only"):
            parse_decision_response(load_fixture("missing-answer.json"), THRESHOLDS)

    def test_staff_fixture_reports_provider_model_and_usage(self):
        result = parse_decision_response(load_fixture("staff-docs-only.json"), THRESHOLDS)

        self.assertEqual(result["model"], GITHUB_CAPI_MODEL)
        self.assertEqual(result["input_tokens"], 355)
        self.assertEqual(result["output_tokens"], 0)
        self.assertTrue(result["decisions"]["docs_only"])

    def test_response_model_must_match_selected_provider(self):
        with self.assertRaisesRegex(DecisionResponseError, "not valid"):
            validate_response_model(
                OPENAI_PROVIDER,
                GITHUB_CAPI_MODEL,
                OPENAI_MODEL,
            )

    def test_staff_provider_accepts_canonical_response_model(self):
        validate_response_model(
            GITHUB_CAPI_PROVIDER,
            OPENAI_MODEL,
            GITHUB_CAPI_MODEL,
        )


class ProviderTests(unittest.TestCase):
    def test_capi_origin_accepts_only_https_githubcopilot_hosts(self):
        self.assertEqual(
            validate_capi_origin("https://api.enterprise.githubcopilot.com/"),
            "https://api.enterprise.githubcopilot.com",
        )
        for origin in (
            "http://api.enterprise.githubcopilot.com",
            "https://example.com",
            "https://api.enterprise.githubcopilot.com/path",
            "https://api.enterprise.githubcopilot.com?redirect=example.com",
        ):
            with self.subTest(origin=origin):
                with self.assertRaises(ApiRequestError):
                    validate_capi_origin(origin)

    def test_capi_request_uses_discovered_origin_and_required_headers(self):
        payload = build_request_payload("diff", GITHUB_CAPI_MODEL)
        request = build_decisions_request(
            GITHUB_CAPI_PROVIDER,
            "test-token",
            payload,
            "https://api.enterprise.githubcopilot.com",
        )
        headers = {name.lower(): value for name, value in request.header_items()}

        self.assertEqual(
            request.full_url,
            "https://api.enterprise.githubcopilot.com/v1/decisions",
        )
        self.assertEqual(headers["authorization"], "Bearer test-token")
        self.assertEqual(headers["copilot-integration-id"], "copilot-developer-app")
        self.assertEqual(headers["editor-version"], "CopilotCLI/1.0")
        self.assertEqual(headers["accept"], "application/json")
        self.assertEqual(headers["content-type"], "application/json")
        self.assertEqual(json.loads(request.data)["model"], GITHUB_CAPI_MODEL)

    def test_openai_request_does_not_include_capi_headers(self):
        request = build_decisions_request(
            OPENAI_PROVIDER,
            "test-token",
            build_request_payload("diff", OPENAI_MODEL),
        )
        headers = {name.lower(): value for name, value in request.header_items()}

        self.assertEqual(request.full_url, "https://api.openai.com/v1/decisions")
        self.assertNotIn("copilot-integration-id", headers)
        self.assertNotIn("editor-version", headers)

    @patch("decisions_change_risk.request_json")
    def test_capi_origin_is_resolved_from_copilot_user_endpoint(self, request_json):
        request_json.return_value = {
            "endpoints": {"api": "https://api.enterprise.githubcopilot.com"}
        }

        origin = resolve_capi_origin("test-token")

        self.assertEqual(origin, "https://api.enterprise.githubcopilot.com")
        request = request_json.call_args.args[0]
        headers = {name.lower(): value for name, value in request.header_items()}
        self.assertEqual(
            request.full_url,
            "https://api.github.com/copilot_internal/user",
        )
        self.assertEqual(headers["authorization"], "Bearer test-token")


class DiffInputTests(unittest.TestCase):
    def test_diff_is_bounded_and_marked_truncated(self):
        files = [
            {
                "filename": "src/example.py",
                "status": "modified",
                "additions": 20,
                "deletions": 2,
                "patch": "+" + ("x" * 500),
            },
            {
                "filename": "docs/readme.md",
                "status": "modified",
                "additions": 1,
                "deletions": 0,
                "patch": "+docs",
            },
        ]

        result = build_diff_input(files, max_characters=300, max_files=100)

        self.assertEqual(len(result["input"]), 300)
        self.assertTrue(result["truncated"])
        self.assertEqual(result["files_considered"], 1)
        self.assertIn("[DIFF TRUNCATED", result["input"])

    def test_file_limit_marks_input_truncated(self):
        files = [
            {"filename": "one.txt", "status": "added", "patch": "+one"},
            {"filename": "two.txt", "status": "added", "patch": "+two"},
        ]

        result = build_diff_input(files, max_characters=1000, max_files=1)

        self.assertTrue(result["truncated"])
        self.assertEqual(result["files_considered"], 1)
        self.assertNotIn("two.txt", result["input"])

    def test_tiny_character_limit_is_still_respected(self):
        result = build_diff_input(
            [{"filename": "one.txt", "status": "added", "patch": "+one"}],
            max_characters=20,
            max_files=1,
        )

        self.assertEqual(len(result["input"]), 20)
        self.assertTrue(result["truncated"])
        self.assertEqual(result["files_considered"], 0)


if __name__ == "__main__":
    unittest.main()
