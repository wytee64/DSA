import ballerina/io;
import ballerina/grpc;
import ballerina/lang.regexp;

public function main() returns error? {
    // Initialize the gRPC client
    CarRentalClient carRentalClient = check new ("http://localhost:9090");

    // Prompt for user role
    io:println("\n=== Welcome to The AuraDrive Rental System ===");
    io:print("Are you a customer or admin? (Enter 'customer' or 'admin'): ");
    string role = io:readln().toLowerAscii();
    if role != "customer" && role != "admin" {
        io:println("Invalid role. Exiting...");
        return;
    }

    // Prompt for user ID
    io:print("Enter your user ID: ");
    string userId = io:readln();
    if role == "customer" && userId.trim().length() == 0 {
        io:println("Customer ID is required. Exiting...");
        return;
    }

    // Main menu loop
    while true {
        io:println("\n=== Car Rental System ===");
        if role == "customer" {
            io:println("1. List Available Cars");
            io:println("2. Search Car by Plate Number");
            io:println("3. Add Car to Cart");
            io:println("4. Place Reservation");
            io:println("5. Exit");
        } else {
            io:println("1. List Available Cars");
            io:println("2. Search Car by Plate Number");
            io:println("3. Add New Car");
            io:println("4. Update Car");
            io:println("5. Remove Car");
            io:println("6. Create Users");
            io:println("7. Exit");
        }
        io:print("Select an option: ");

        string choice = io:readln();
        match choice {
            "1" => {
                check listAvailableCars(carRentalClient);
            }
            "2" => {
                check searchCar(carRentalClient);
            }
            "3" => {
                if role == "customer" {
                    check addToCart(carRentalClient, userId);
                } else {
                    check addCar(carRentalClient);
                }
            }
            "4" => {
                if role == "customer" {
                    check placeReservation(carRentalClient, userId);
                } else {
                    check updateCar(carRentalClient);
                }
            }
            "5" => {
                if role == "customer" {
                    io:println("Exiting...");
                    break;
                } else {
                    check removeCar(carRentalClient);
                }
            }
            "6" => {
                if role == "admin" {
                    check createUsers(carRentalClient);
                }
            }
            "7" => {
                if role == "admin" {
                    io:println("Exiting...");
                    break;
                }
            }
            _ => {
                io:println("Invalid option. Please try again.");
            }
        }
    }
}

function listAvailableCars(CarRentalClient carRentalClient) returns error? {
    io:print("Enter filter (e.g., make like 'Toyota' or year like '2020', leave empty for all): ");
    string filter = io:readln();
    ListAvailableCarsRequest request = { filter: filter };

    // Call listAvailableCars (server streaming)
    stream<Car, grpc:Error?> carStream = check carRentalClient->listAvailableCars(request);
    io:println("\nAvailable Cars:");
    int count = 0;
    check carStream.forEach(function(Car car) {
        io:println(string `Plate: ${car.plateNumber}, Make: ${car.make}, Model: ${car.model}, Year: ${car.year}, Price: ${car.dailyPrice}, Mileage: ${car.mileage}, Status: ${car.status}`);
        count += 1;
    });
    if count == 0 {
        io:println("No cars found matching the filter.");
    }
}

function searchCar(CarRentalClient carRentalClient) returns error? {
    io:print("Enter plate number to search: ");
    string plate = io:readln().trim();
    if plate.length() == 0 {
        io:println("Plate number cannot be empty.");
        return;
    }
    SearchCarRequest request = { plate: plate };

    // Call searchCar
    SearchCarResponse response = check carRentalClient->searchCar(request);
    if response.found {
        Car car = response.car;
        io:println(string `Car found: Plate: ${car.plateNumber}, Make: ${car.make}, Model: ${car.model}, Year: ${car.year}, Price: ${car.dailyPrice}, Mileage: ${car.mileage}, Status: ${car.status}`);
    } else {
        io:println("Car not found.");
    }
}

function addToCart(CarRentalClient carRentalClient, string customerId) returns error? {
    if customerId.trim().length() == 0 {
        io:println("Customer ID is required.");
        return;
    }
    io:print("Enter car plate number: ");
    string plate = io:readln().trim();
    io:print("Enter start date (YYYY-MM-DD): ");
    string startDate = io:readln().trim();
    io:print("Enter end date (YYYY-MM-DD): ");
    string endDate = io:readln().trim();

    // Basic date format validation
    regexp:RegExp datePattern = re `^\d{4}-\d{2}-\d{2}$`;
    if !datePattern.isFullMatch(startDate) || !datePattern.isFullMatch(endDate) {
        io:println("Invalid date format. Use YYYY-MM-DD.");
        return;
    }

    AddToCartRequest request = {
        customerId: customerId,
        plate: plate,
        startDate: startDate,
        endDate: endDate
    };

    // Call addToCart
    AddToCartResponse response = check carRentalClient->addToCart(request);
    if response.success {
        io:println(string `Added to cart: Plate: ${response.item.plateNumber}, Start: ${response.item.startDate}, End: ${response.item.endDate}`);
    } else {
        io:println("Failed to add to cart. Check customer ID, car availability, or input values.");
    }
}

function placeReservation(CarRentalClient carRentalClient, string customerId) returns error? {
    if customerId.trim().length() == 0 {
        io:println("Customer ID is required.");
        return;
    }
    PlaceReservationRequest request = { customerId: customerId };

    // Call placeReservation
    PlaceReservationResponse response = check carRentalClient->placeReservation(request);
    if response.success {
        Reservation res = response.reservation;
        io:println(string `Reservation successful! ID: ${res.reservationId}, Total Price: ${res.totalPrice}`);
        io:println("Items:");
        foreach CartItem item in res.items {
            io:println(string ` - Plate: ${item.plateNumber}, Start: ${item.startDate}, End: ${item.endDate}`);
        }
    } else {
        io:println("Reservation failed: ", response.message);
    }
}

function addCar(CarRentalClient carRentalClient) returns error? {
    io:print("Enter plate number: ");
    string plate = io:readln().trim();
    io:print("Enter make (e.g., Toyota): ");
    string make = io:readln().trim();
    io:print("Enter model (e.g., Camry): ");
    string model = io:readln().trim();
    io:print("Enter year (e.g., 2020): ");
    string yearStr = io:readln().trim();
    io:print("Enter daily price (e.g., 50.0): ");
    string priceStr = io:readln().trim();
    io:print("Enter mileage (e.g., 10000): ");
    string mileageStr = io:readln().trim();
    io:print("Enter status (available/unavailable): ");
    string status = io:readln().trim().toLowerAscii();

    // Validate inputs
    if plate.length() == 0 || make.length() == 0 || model.length() == 0 {
        io:println("Plate, make, and model cannot be empty.");
        return;
    }
    int|error year = int:fromString(yearStr);
    float|error dailyPrice = float:fromString(priceStr);
    int|error mileage = int:fromString(mileageStr);
    if year is error || dailyPrice is error || mileage is error {
        io:println("Invalid year, price, or mileage. Please enter valid numbers.");
        return;
    }
    if status != "available" && status != "unavailable" {
        io:println("Status must be 'available' or 'unavailable'.");
        return;
    }

    AddCarRequest request = {
        plate: plate,
        make: make,
        model: model,
        year: year,
        dailyPrice: dailyPrice,
        mileage: mileage,
        status: status
    };

    // Call addCar
    AddCarResponse response = check carRentalClient->addCar(request);
    if response.car.plateNumber != "" {
        io:println(string `Car added: Plate: ${response.car.plateNumber}, Make: ${response.car.make}, Model: ${response.car.model}`);
    } else {
        io:println("Failed to add car. It may already exist.");
    }
}

function updateCar(CarRentalClient carRentalClient) returns error? {
    io:print("Enter plate number to update: ");
    string plate = io:readln().trim();
    io:print("Enter new daily price (leave empty to keep unchanged): ");
    string priceStr = io:readln().trim();
    io:print("Enter new status (available/unavailable, leave empty to keep unchanged): ");
    string status = io:readln().trim().toLowerAscii();

    // Validate inputs
    float dailyPrice = 0.0;
    if priceStr.length() > 0 {
        float|error price = float:fromString(priceStr);
        if price is error {
            io:println("Invalid price format.");
            return;
        }
        dailyPrice = price;
    }
    if status.length() > 0 && status != "available" && status != "unavailable" {
        io:println("Status must be 'available' or 'unavailable'.");
        return;
    }

    UpdateCarRequest request = {
        plate: plate,
        dailyPrice: dailyPrice,
        status: status
    };

    // Call updateCar
    UpdateCarResponse response = check carRentalClient->updateCar(request);
    if response.car.plateNumber != "" {
        io:println(string `Car updated: Plate: ${response.car.plateNumber}, Price: ${response.car.dailyPrice}, Status: ${response.car.status}`);
    } else {
        io:println("Failed to update car. Car not found.");
    }
}

function removeCar(CarRentalClient carRentalClient) returns error? {
    io:print("Enter plate number to remove: ");
    string plate = io:readln().trim();
    if plate.length() == 0 {
        io:println("Plate number cannot be empty.");
        return;
    }

    RemoveCarRequest request = { plate: plate };

    // Call removeCar
    RemoveCarResponse response = check carRentalClient->removeCar(request);
    io:println("Car removed successfully.");
    io:println("Remaining cars:");
    if response.cars.length() == 0 {
        io:println(" - No cars remaining.");
    } else {
        foreach Car car in response.cars {
            io:println(string ` - Plate: ${car.plateNumber}, Make: ${car.make}, Model: ${car.model}`);
        }
    }
}

function createUsers(CarRentalClient carRentalClient) returns error? {
    CreateUsersStreamingClient streamingClient = check carRentalClient->createUsers();
    io:println("Enter users (one per line, format: userId,name,role). Enter empty line to finish:");
    
    while true {
        io:print("User (e.g., U001,John Doe,customer): ");
        string input = io:readln().trim();
        if input.length() == 0 {
            break;
        }
        string[] parts = regexp:split(re `,`, input);
        if parts.length() != 3 {
            io:println("Invalid format. Use: userId,name,role");
            continue;
        }
        string userId = parts[0].trim();
        string name = parts[1].trim();
        string role = parts[2].trim().toLowerAscii();
        if role != "customer" && role != "admin" {
            io:println("Role must be 'customer' or 'admin'.");
            continue;
        }

        User user = { userId: userId, name: name, role: role };
        check streamingClient->sendUser(user);
    }

    // Complete the stream and get response
    check streamingClient->complete();
    CreateUsersResponse? response = check streamingClient->receiveCreateUsersResponse();
    if response is CreateUsersResponse {
        io:println("Users created:");
        foreach User user in response.users {
            io:println(string ` - ID: ${user.userId}, Name: ${user.name}, Role: ${user.role}`);
        }
    } else {
        io:println("No response received.");
    }
}
