# Car Rental System - gRPC 

A distributed car rental system using **gRPC**. Supports real-time car management, user authentication, shopping carts, and reservations.

### Features
- CRUD operation for Car (add, update, remove, search)
- User management via client streaming  
- Real-time search for available cars  
- Shopping cart system  
- Reservation workflow  
- Support for real-time updates

### Architecture
- **Language:** Ballerina
- **Protocol:** gRPC (HTTP)  
- **Port:** 9090
- **Storage:** In-memory map
  
### gRPC Overview
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
