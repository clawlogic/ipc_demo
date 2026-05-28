# Azure Pipelines for Fabric Deployment

## deploy-fabric.yml

Triggers Fabric Deployment Pipeline via REST API after code is merged.

### Flow
1. Developer merges PR to `develop` branch
2. Pipeline triggers automatically
3. Gets a Fabric API token using the service connection
4. Calls the Fabric Deployment Pipeline REST API to promote Dev → Test
5. If branch is `main`, also promotes Test → Prod (with separate approval gate)

### Prerequisites
- ADO Variable Group `Fabric-Variables` with:
  - `FABRIC_PIPELINE_ID`: ID of the Fabric Deployment Pipeline
  - `DEV_STAGE_ID`: ID of the Dev stage in the pipeline
  - `TEST_STAGE_ID`: ID of the Test stage
  - `PROD_STAGE_ID`: ID of the Prod stage
- ADO Environments `Test` and `Production` with approval gates configured
- Service connections with permissions to get Fabric API tokens
- Self-hosted agent pool `DataServices`

### POC Values (Logic sandbox)
```
FABRIC_PIPELINE_ID = b43480f0-861f-4059-8dfc-b5571616c2fe
DEV_STAGE_ID = c10d4bdd-c9f7-4c99-9ee1-e6f965b4e984
TEST_STAGE_ID = b22cd4ea-e4dc-4fb0-967d-8148a388976c
PROD_STAGE_ID = 26c5562e-9d8e-46b4-957a-0f7404ad64fe
```

### Alternative: Using Fabric CLI
Instead of raw REST API calls, you can use the Fabric CLI (`fab`):

```yaml
- script: |
    pip install ms-fabric-cli
    fab auth login -u $(CLIENT_ID) -p $(CLIENT_SECRET) --tenant $(TENANT_ID)
    fab run "IPC-POC-Dev.Workspace/sample_pipeline.DataPipeline"
  displayName: 'Run Fabric pipeline via CLI'
```
