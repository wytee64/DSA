# Asset Management System – Ballerina REST API

A REST API for managing university assets, their components, maintenance schedules, and work orders. Uses in-memory storage with Ballerina’s HTTP module.

## Features
- CRUD operations for assets (add, update, delete, view)
- Component tracking for each asset  
- Maintenance scheduling (weekly, monthly, yearly)
- Handle work orders and tasks  
- Faculty-based filtering  
- In-memory storage

### Architecture
- **Language:** Ballerina
- **Protocol:** REST (HTTP)
- **Port:** 8080 **(Service)**
- **Storage:** In-memory map 

## API Overview
| Method | Endpoint | Description |
|--------|---------|-------------|
| POST | /assets/addAsset | Add a new asset |
| GET | /assets/getAsset/{assetTag} | Get asset by tag |
| PUT | /assets/updateAsset/{assetTag} | Update asset |
| DELETE | /assets/removeAsset/{assetTag} | Delete asset |
| GET | /assets/faculty/{faculty} | List assets by faculty |
| POST | /assets/{tag}/components | Add a component |
| GET | /assets/{tag}/components | List components |
| PUT | /assets/{tag}/components/{componentId} | Update component |
| DELETE | /assets/{tag}/components/{componentId} | Delete component |
| POST | /assets/{tag}/workorders | Add a work order |
| GET | /assets/{tag}/workorders | Get all work orders |
| PUT | /assets/{tag}/workorders/{woID} | Update work order |
| POST | /assets/{tag}/workorders/{woID}/tasks | Add a task |
| GET | /assets/{tag}/workorders/{woID}/tasks | Get all tasks |
| DELETE | /assets/{tag}/workorders/{woID}/tasks | Delete task |

