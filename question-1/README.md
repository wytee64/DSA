# Asset Management System – Ballerina REST API

A system built with **Ballerina** that provides REST APIs to manage university assets, their components, maintenance schedules, and work orders.

---

## Features
- CRUD for assets (add, update, delete, view)
- Manage components inside assets
- Track maintenance schedules (weekly, monthly, yearly)
- Handle work orders and tasks
- View assets by faculty
- In-memory storage with thread-safe operations

---

## Tech Stack
- **Language:** Ballerina
- **Protocol:** REST (HTTP)
- **Port:** 8080 for **service**
- **Storage:** In-memory map

---

## API Overview
- `POST /assets/addAsset` → Add new asset
- `GET /assets/getAsset/{assetTag}` → Get asset by tag
- `PUT /assets/updateAsset/{assetTag}` → Update asset
- `DELETE /assets/removeAsset/{assetTag}` → Delete asset
- `GET /assets/faculty?faculty=SCIENCE` → Filter by faculty
- `POST /assets/{tag}/components` → Add component
- `GET /assets/{tag}/components` → List components

