import ballerina/grpc;


listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: RENTAL_DESC}
service "CarRental" on ep {

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

    // -------------------- (left as stubs for later) --------------------
    remote function searchCar(SearchCarRequest value) returns SearchCarResponse|error {
        return error("searchCar: not implemented yet");
    }

    remote function addToCart(AddToCartRequest value) returns AddToCartResponse|error {
        return error("addToCart: not implemented yet");
    }

    remote function placeReservation(PlaceReservationRequest value) returns PlaceReservationResponse|error {
        return error("placeReservation: not implemented yet");
    }

    remote function createUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        return error("createUsers: not implemented yet");
    }

    remote function listAvailableCars(ListAvailableCarsRequest value) returns stream<Car, error?>|error {
        return error("listAvailableCars: not implemented yet");
    }
}
