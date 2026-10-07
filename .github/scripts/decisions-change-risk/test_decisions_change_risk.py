import json
import sys
import unittest
from pathlib import Path

ACTION_DIR = Path(__file__).parent
sys.path.insert(0, str(ACTION_DIR))

from decisions_change_risk import (  # noqa: E402
    DecisionRefusal,
    DecisionResponseError,
    build_diff_input,
    parse_decision_response,
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
