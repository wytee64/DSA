import ballerina/grpc;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: RENTAL_DESC}
service "CarRental" on ep {

 remote function searchCar(SearchCarRequest req) returns SearchCarResponse {
    Car? car = getCarByPlate(req.plate);
    if car is () {
        return { found: false, car: {} };
    // -------------------- ADMIN: add_car --------------------
    remote function addCar(AddCarRequest value) returns AddCarResponse|error {
        // Normalize & validate
        string plate = value.plate.trim();
        string make = value.make.trim();
        string model = value.model.trim();
        int year = value.year;
        float dailyPrice = value.dailyPrice;
        int mileage = value.mileage;
        string status = value.status.toLowerAscii().trim(); // "available" | "unavailable", this will helps us determine what is going on

        if plate.length() == 0 || make.length() == 0 || model.length() == 0 {
            return error("addCar: plate, make, and model are required");
        }
        if year <= 0 {
            return error("addCar: year must be > 0");
        }
        if dailyPrice <= 0.0 {
            return error("addCar: dailyPrice must be > 0");
        }
        if !(status == "available" || status == "unavailable") {
            return error("addCar: status must be 'available' or 'unavailable'");
        }

        // Check duplicates
        if cars.hasKey(plate) {
            return error(string `addCar: car with plate ${plate} already exists`);
        }

        // Build Car (note: proto uses plate in request, but Car has 'plateNumber')
        Car newCar = {
            plateNumber: plate,
            make,
            model,
            year,
            dailyPrice,
            mileage,
            status
        };

        // Persist
        cars[plate] = newCar;

        // Reply with created car
        return { car: newCar };
    }

    // -------------------- ADMIN: update_car --------------------
    remote function updateCar(UpdateCarRequest value) returns UpdateCarResponse|error {
        string plate = value.plate.trim();
        if plate.length() == 0 {
            return error("updateCar: plate is required");
        }
        if !cars.hasKey(plate) {
            return error(string `updateCar: car with plate ${plate} not found`);
        }

        Car current = <Car>cars[plate];

        // Update fields if provided/valid
        float newPrice = value.dailyPrice;
        if newPrice > 0.0 {
            current.dailyPrice = newPrice;
        }

        string newStatus = value.status.toLowerAscii().trim();
        if newStatus.length() > 0 {
            if !(newStatus == "available" || newStatus == "unavailable") {
                return error("updateCar: status must be 'available' or 'unavailable'");
            }
            current.status = newStatus;
        }

        // Save back
        cars[plate] = current;

        return { car: current };
    }
    return { found: true, car: car };
}

remote function addToCart(AddToCartRequest req) returns AddToCartResponse {
    CartItem item = {
        plateNumber: req.plate,
        startDate: req.startDate,
        endDate: req.endDate
    };
    boolean success = addToCart(req.customerId, item);
    return { success: success, item: item };
}

remote function placeReservation(PlaceReservationRequest req) returns PlaceReservationResponse {
    CartItem[] items = getCart(req.customerId);
    if items.length() == 0 {
        return { success: false, reservation: {}, message: "Cart is empty" };
    }

    Reservation? reservation = createReservation(req.customerId, items);
    if reservation is () {
        return { success: false, reservation: {}, message: "Some cars not available or invalid dates" };
    }

    return { success: true, reservation: reservation, message: "Reservation successful" };
}

    // -------------------- ADMIN: remove_car --------------------
    remote function removeCar(RemoveCarRequest value) returns RemoveCarResponse|error {
        string plate = value.plate.trim();
        if plate.length() == 0 {
            return error("removeCar: plate is required");
        }
        if !cars.hasKey(plate) {
            return error(string `removeCar: car with plate ${plate} not found`);
        }

        // Remove the car
        _ = cars.remove(plate);

        // Return the *full updated list* of cars (as per spec)
        Car[] remaining = [];
        foreach var [_, c] in cars.entries() {
            remaining.push(c);
        }
        return { cars: remaining };
    }


remote function listAvailableCars(ListAvailableCarsRequest req) returns stream<Car, grpc:Error?> {
    Car[] carsToSend = [];
    foreach var car in listAvailableCars() {
        if (req.filter.trim().length() > 0) {
            if (car.make.toLowerAscii() == req.filter.toLowerAscii() ||
                car.year.toBalString() == req.filter) {
                carsToSend.push(car);
            }
        } else {
            carsToSend.push(car);
        }
    }
    stream<Car, grpc:Error?> carStream = new stream<Car, grpc:Error?>(carsToSend);
    return carStream;
}
}