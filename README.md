# DSA Ballerina Projects

This repo contains two distributed systems projects built with **Ballerina** — a cloud-native programming language for integration and network services.  

---

## Repository Structure
question-1 # Asset Management System (REST API)
question-2 # Car Rental System (gRPC)


---

## Question 1: Asset Management System (REST API)
**Location:** `question-1/`  

A REST API for managing university assets, their components, maintenance schedules, and work orders. Uses in-memory storage with Ballerina’s HTTP module.

### Architecture
- **Protocol:** REST (HTTP/1.1)  
- **Ports:** 8080 (Service), 9090 (Client)  
- **Storage:** In-memory maps  
- **Communication:** Synchronous  

### Features
- CRUD operations for assets  
- Component tracking for each asset  
- Maintenance scheduling (weekly/monthly/yearly)  
- Work order management  
- Faculty-based filtering  

### API Endpoints
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

### Data Models
- **Asset:** Metadata about university assets  
- **Component:** Parts of an asset  
- **Maintenance:** Scheduled maintenance records  
- **WorkOrder:** Maintenance work orders  
- **Task:** Tasks within work orders  

---

## Question 2: Car Rental System (gRPC)
**Location:** `question-2/`  

A distributed car rental system using **gRPC**. Supports real-time car management, user authentication, shopping carts, and reservations.

### Architecture
- **Protocol:** gRPC (HTTP/2)  
- **Port:** 9090  
- **Communication:** Asynchronous, bidirectional streaming  
- **Data Format:** Protocol Buffers  

### Features
- Car management: add, update, remove, search  
- User management via client streaming  
- Real-time search for available cars  
- Shopping cart system  
- Reservation workflow  
- Streaming support for real-time updates  

### gRPC Methods
| Method | Type | Description |
|--------|------|-------------|
| add_car | Unary | Add a car to inventory |
| update_car | Unary | Update car info |
| remove_car | Unary | Delete a car |
| search_car | Unary | Find a specific car |
| list_available_cars | Server Streaming | Stream available cars |
| add_to_cart | Unary | Add car to cart |
| place_reservation | Unary | Make a reservation |
| create_users | Client Streaming | Batch user creation |

### Data Models
- **Car:** Vehicle details (plate, make, model, price)  
- **User:** Customer/Admin profiles  
- **CartItem:** Items in shopping cart  
- **Reservation:** Full booking record  

---

## Tech Stack

### Common
- **Language:** Ballerina (Swan Lake)  
- **Build Tool:** Ballerina CLI  
- **IDE:** VS Code + Ballerina extension  

### Question 1
- Ballerina HTTP module  
- JSON serialization  
- HTTP error handling  

### Question 2
- Ballerina gRPC module  
- Protocol Buffers (.proto)  
- Bidirectional streaming support  
