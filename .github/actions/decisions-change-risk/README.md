# Decisions change-risk router

This local composite action classifies a bounded pull request diff with GitHub's staff Decisions API and exposes predicate probabilities plus thresholded routing outputs.

```yaml
- name: Classify pull request risk
  id: classify
  uses: ./.github/actions/decisions-change-risk
  with:
    pr-number: ${{ inputs.pr_number }}
    github-token: ${{ github.token }}
    capi-token: ${{ secrets.COPILOT_CAPI_TOKEN }}
```

Use it only from trusted default-branch workflows. The action sends bounded pull request patch data to the resolved Copilot API endpoint and treats the diff as untrusted evidence, never as instructions.
