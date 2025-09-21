import ballerina/io;
import ballerina/time;

CarRentalClient ep = check new ("http://localhost:9090");

final User[] users = [
    {userId: "1", name: "Tangi", role: "ADMIN"},
    {userId: "2", name: "Etuwete", role: "ADMIN"},
    {userId: "3", name: "Jason", role: "ADMIN"},
    {userId: "4", name: "Silas", role: "ADMIN"},
    {userId: "5", name: "Zeek", role: "ADMIN"},
    {userId: "6", name: "Leane", role: "ADMIN"}
];

public function main() returns error? {
    string userId = "";
    string role = "";
    boolean loggedIn = false;

    while (!loggedIn) {
        io:println("\ncar Rental System Login");
        userId = io:readln("your user ID: ");
        
        foreach User user in users {
            if (user.userId == userId) {
                role = user.role;
                loggedIn = true;
                io:println("welcome, ", user.name);
                break;
            }
        }

        if (!loggedIn) {
            io:println("id doesnt exist,try again still");
        }
    }
    while (true) {
        if (role == "ADMIN") {
            io:println("\nadmin Menu");
            io:println("1. Add new car");
            io:println("2. Update car");
            io:println("3. Remove car");
            io:println("4. Search car");
            io:println("5. List all available cars");
            io:println("6. Add new users");
            io:println("7. List all users");
            io:println("8. Exit");
            
            string choice =io:readln("choice (1-8): ");
            
            match choice {
                "1" => {
                    io:println("\nadd New Car");
                    AddCarRequest newCar = {
                        plate: io:readln("plate number: "),
                        make:  io:readln("make: "),
                        model:  io:readln("model: "),
                        year: check int:fromString(io:readln("year: ")),
                        dailyPrice: check float:fromString(io:readln("daily price: ")),
                        mileage: check int:fromString(io:readln("mileage: ")),
                        status: "AVAILABLE"
                    };
                    AddCarResponse response = check ep->addCar(newCar);
                    io:println("Car added: ", response);
                }
                "2" => {
                    io:println("\nUpdate Car");
                    UpdateCarRequest updateReq = {
                        plate: io:readln("plate number: "),
                        dailyPrice: check float:fromString(io:readln("new daily price: ")),
                        status: io:readln("new status (AVAILABLE/RESERVED): ")
                    };
                    UpdateCarResponse response = check ep->updateCar(updateReq);
                    io:println("Car updated: ", response);
                }
                "3" => {
                    io:println("\nRemove Car");
                    string plate =io:readln("plate number to remove: ");
                    RemoveCarResponse response = check ep->removeCar({plate});
                    io:println("Car removed, Remaining cars are: ", response);
                }
                "4" => {
                    io:println("\nSearch Car");
                    string plate = io:readln("plate number to search: ");
                    SearchCarResponse response = check ep->searchCar({plate});
                    io:println("Search result: ", response);
                }
                "5" => {
                    io:println("\navailable Cars");
                    stream<Car, error?> cars = check ep->listAvailableCars({filter: ""});
                    check cars.forEach(function(Car car) {
                        io:println(car);
                    });
                }
                "6" => {
                    io:println("\nAdd New Users");
                    CreateUsersStreamingClient createUsersStreamingClient = check ep->createUsers();
                    
                    while (true) {
                        io:println("\nnew user details (or type done to finish):");
                        string input = io:readln("user ID (or 'done'): ");
                        if (input.toLowerAscii() == "done") {
                            break;
                        }
                        
                        User newUser = {
                            userId: input,
                            name: io:readln("user name: "),
                            role: io:readln("role (ADMIN/CUSTOMER): ")
                        };
                        check createUsersStreamingClient->sendUser(newUser);
                        io:println("User added to stream.");
                    }
                    
                    check createUsersStreamingClient->complete();
                    CreateUsersResponse? response = check createUsersStreamingClient->receiveCreateUsersResponse();
                    io:println("Users created: ", response);
                }
                "7" => {
                    io:println("\nall users");
                    CreateUsersStreamingClient createUsersStreamingClient = check ep->createUsers();
                    foreach User user in users {
                        check createUsersStreamingClient->sendUser(user);
                    }
                    check createUsersStreamingClient->complete();
                    CreateUsersResponse? response = check createUsersStreamingClient->receiveCreateUsersResponse();
                    io:println("users list: ", response);
                }
                "8" => {
                    io:println("peace");
                    return;
                }
                _ => {
                    io:println("choice invalid ,try again still");
                }
            }
        } 
        else {
            io:println("\ncustomer Menu");
            io:println("1. List available cars");
            io:println("2. Search car");
            io:println("3. Add car to cart");
            io:println("4. Place reservation");
            io:println("5. Exit");
            
            string choice = io:readln("choice (1-5): ");
            
            match choice {
                "1" => {
                    io:println("\navailable Cars");
                    stream<Car, error?> cars = check ep->listAvailableCars({filter: ""});
                    check cars.forEach(function(Car car) {
                        io:println(car);
                    });
                }
                "2" => {
                    io:println("\nsearch car");
                    string plate = io:readln("plate number to search: ");
                    SearchCarResponse response = check ep->searchCar({plate});
                    io:println("Search result: ", response);
                }
                "3" => {
                    io:println("\nAdd to Cart");
                    time:Utc now = time:utcNow();
                    AddToCartRequest cartReq = {
                        customerId: userId,
                        plate: io:readln("car plate number: "),
                        startDate:io:readln("start date (YYYY-MM-DD): "),
                        endDate: io:readln("end date (YYYY-MM-DD): ")
                    };
                    AddToCartResponse response = check ep->addToCart(cartReq);
                    io:println("add to cart: ", response);
                }
                "4" => {
                    io:println("\nPlace Reservation");
                    PlaceReservationResponse response = check ep->placeReservation({customerId: userId});
                    io:println("Reservation placed: ", response);
                }
                "5" => {
                    io:println("peace");
                    return;
                }
                _ => {
                    io:println("choice invalid ,try again still");
                }
            }
        }
    }
}
