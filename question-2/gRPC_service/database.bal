map<Car> cars = {};
map<User> users = {};
map<CartItem[]> carts = {};
map<Reservation> reservations = {};

function addCar(Car newCar) returns boolean {
    if (newCar.plateNumber.trim().length() == 0){return false;}
    if (newCar.make.trim().length() == 0){return false;}
    if (newCar.model.trim().length() == 0){return false;}
    if (newCar.year.toBalString().length() == 0){return false;}
    if (newCar.dailyPrice.toBalString().length() == 0){return false;}
    if (newCar.mileage.toBalString().length() == 0){return false;}
    if (newCar.status.trim().length() == 0){return false;}
    if (newCar.status != "available" && newCar.status != "unavailable") {return false;}

    if (cars.hasKey(newCar.plateNumber)) {return false;}
    cars[newCar.plateNumber] = newCar;
    return true;
}

function updateCar(string plate, float newDailyPrice, string newStatus) returns boolean {
    if (!cars.hasKey(plate)) {
        return false;
    }

    Car update = <Car>cars[plate];
    if (newDailyPrice > 0.0) {
        update.dailyPrice = newDailyPrice;
    }
    if (newStatus.trim().length() != 0 && (newStatus == "available" || newStatus == "unavailable")) {
        update.status = newStatus;
    }
    cars[plate] = update;
    return true;
}

function removeCar(string plate) returns boolean {
    if (cars.hasKey(plate)) {
        _ = cars.remove(plate);
        return true;
    }
    return false;
}

function listAvailableCars() returns Car[] {
    Car[] listOfAvailableCars = []; 
    foreach var [_, car] in cars.entries() {
        if car.status == "available" {
            listOfAvailableCars.push(car);
        }
    }
    return listOfAvailableCars;
}

function getCarByPlate(string plate) returns Car? {
    return cars.get(plate);
}

function addUser(User newUser) returns boolean {
    if (newUser.userId.trim().length() == 0) {return false;}
    if (newUser.name.trim().length() == 0) {return false;}
    if (newUser.role != "admin" && newUser.role != "customer") {return false;}
    
    if (users.hasKey(newUser.userId)) {return false;}
    users[newUser.userId] = newUser;
    return true;
}

function getUser(string userId) returns User? {
    return users.get(userId);
}

function listUsers() returns User[] {
    User[] listOfUsers = []; 
    foreach var [_, user] in users.entries() {
        listOfUsers.push(user);
    }
    return listOfUsers;
}

function addToCart(string customerId, CartItem item) returns boolean {
    // Validate user exists and is a customer
    User? user = users.get(customerId);
    if (user is ()) {
        return false;
    }
    if (user.role != "customer") {
        return false;
    }

    // Validate car exists and is available
    Car? car = cars.get(item.plateNumber);
    if (car is ()) {
        return false;
    }
    if (car.status != "available") {
        return false;
    }

    // Validate dates
    if (item.startDate.trim().length() == 0 || item.endDate.trim().length() == 0) {
        return false;
    }

    CartItem[] cart = [];
    if (carts.hasKey(customerId)) {
        cart = <CartItem[]>carts[customerId];
    }
    cart.push(item);
    carts[customerId] = cart;
    return true;
}

function getCart(string customerId) returns CartItem[] {
    if (carts.hasKey(customerId)) {
        return <CartItem[]>carts[customerId];
    }
    return [];
}

function clearCart(string customerId) {
    if (carts.hasKey(customerId)) {
        _ = carts.remove(customerId);
    }
}


function checkCarAvailability(string plateNumber, string startD, string endD) returns boolean {
    // Validate car exists
    Car? car = cars.get(plateNumber);
    if (car is ()) {
        return false;
    }
    
    // Check if car is marked as available
    if (car.status != "available") {
        return false;
    }
    
    // Check if car is not in any active reservations for the given dates
    foreach var [_, reservation] in reservations.entries() {
        foreach var item in reservation.items {
            if (item.plateNumber == plateNumber) {
                // Simple date overlap check
                // If requested period overlaps with any existing reservation, car is not available
                if ((startD >= item.startDate && startD <= item.endDate) ||
                    (endD >= item.startDate && endD <= item.endDate) ||
                    (startD <= item.startDate && endD >= item.endDate)) {
                    return false;
                }
            }
        }
    }
    
    return true;
}

function createReservation(string customerId, CartItem[] items) returns Reservation? {
    // Validate customer exists and is a customer
    User? user = users.get(customerId);
    if (user is () || user.role != "customer") {
        return ();
    }
    
    // Validate all cars in items are available for the requested dates
    foreach var item in items {
        if (!checkCarAvailability(item.plateNumber, item.startDate, item.endDate)) {
            return ();
        }
    }
    
    // Calculate total price
    float totalPrice = 0.0;
    foreach var item in items {
        Car? car = cars.get(item.plateNumber);
        if (car is Car) {
            // Simple calculation: assuming dates are in format YYYY-MM-DD
            string[] startParts = re`-`.split(item.startDate);
            string[] endParts = re`-`.split(item.endDate);
            if (startParts.length() == 3 && endParts.length() == 3) {
                int startDay = checkpanic int:fromString(startParts[2]);
                int endDay = checkpanic int:fromString(endParts[2]);
                int days = endDay - startDay + 1;  // Including both start and end days
                totalPrice += car.dailyPrice * days;
            }
        }
    }
    
    // Create new reservation
    string reservationId = string `RES-${reservations.length() + 1}`;
    Reservation newReservation = {
        reservationId: reservationId,
        customerId: customerId,
        items: items,
        totalPrice: totalPrice
    };
    
    // Add to reservations map
    reservations[reservationId] = newReservation;
    
    // Mark cars as unavailable
    foreach var item in items {
        Car? car = cars.get(item.plateNumber);
        if (car is Car) {
            car.status = "unavailable";
            cars[item.plateNumber] = car;
        }
    }
    
    // Clear customer's cart after successful reservation
    clearCart(customerId);
    
    return newReservation;
}

function listReservations() returns Reservation[] {
    Reservation[] allReservations = [];
    foreach var [_, reservation] in reservations.entries() {
        allReservations.push(reservation);
    }
    return allReservations;
}



