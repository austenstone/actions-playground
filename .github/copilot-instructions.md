# GitHub Copilot Instructions

## Preferred Tools for GitHub Actions

When working with GitHub Actions in this repository, **always prefer using MCP tools over `gh` CLI commands**. The MCP tools provide better integration, structured responses, and more reliable automation.

### Available GitHub Actions MCP Tools

#### Workflow Management
- `mcp_github-action_list_workflows` - List all workflows
- `mcp_github-action_list_workflow_runs` - List runs for a workflow
- `mcp_github-action_list_workflow_jobs` - List jobs in a run
- `mcp_github-action_run_workflow` - Trigger a workflow
- `mcp_github-action_get_workflow_run` - Get run details
- `mcp_github-action_rerun_failed_jobs` - Re-run failed jobs

#### Artifact Management
- `mcp_github-action_list_workflow_run_artifacts` - List artifacts
- `mcp_github-action_download_workflow_run_artifact` - Download artifacts

#### Extended Capabilities
- `activate_workflow_management_tools` - Unlock workflow cancellation and metrics
- `activate_log_management_tools` - Unlock log retrieval and deletion

### Examples

❌ **Don't do this:**
```bash
gh workflow list
gh run list --workflow=ci.yml
gh run view 12345
```

✅ **Do this instead:**
```
Use mcp_github-action_list_workflows
Use mcp_github-action_list_workflow_runs
Use mcp_github-action_get_workflow_run
```

### Benefits of MCP Tools
- 🎯 Structured, programmatic responses
- 🔄 Better error handling and pagination
- 🚀 Faster execution in automation
- 📊 Consistent data format
- 🔧 More reliable for scripting

### When to Use CLI
Only fall back to `gh` CLI when:
- The required functionality isn't available in MCP tools
- You need interactive prompts or human-friendly output
- Working outside of automated workflows
