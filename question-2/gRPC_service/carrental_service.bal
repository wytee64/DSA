import ballerina/grpc;


listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: RENTAL_DESC}
service "CarRental" on ep {

    remote function addCar(AddCarRequest value) returns AddCarResponse|error {
        Car newCar = {
            plateNumber: value.plate,
            make: value.make,
            model: value.model,
            year: value.year,
            dailyPrice: value.dailyPrice,
            mileage: value.mileage,
            status: value.status
        };

         if cars.hasKey(newCar.plateNumber) {
        return { car: {} };
    }

        cars[newCar.plateNumber] = newCar;
        return { car: newCar };
    }

    remote function updateCar(UpdateCarRequest value) returns UpdateCarResponse|error {
         if !cars.hasKey(value.plate) {
        // no car found → return empty Car
        return { car: {} };
    }

    Car existing = <Car>cars[value.plate];
    if value.dailyPrice > 0.0 {existing.dailyPrice = value.dailyPrice;}
    if value.status != "" { existing.status = value.status; }

    cars[value.plate] = existing;
    return { car: existing };
    }

    remote function removeCar(RemoveCarRequest value) returns RemoveCarResponse|error {
         if !cars.hasKey(value.plate) {
            return { cars: [] };
        }

        _ = cars.remove(value.plate);

        Car[] carList = [];
        foreach var [_, car] in cars.entries() {
            carList.push(car);
        }

        return { cars: carList };
    }

    remote function searchCar(SearchCarRequest req) returns SearchCarResponse {
        Car? car= getCarByPlate(req.plate);
        if !(car is ()) {
            return { found: true, car: car};
        }
        return { found: false, car: {} };
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

    remote function createUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        User[] users = [];
        check from User user in clientStream
            do {
                users.push(user);
            };
        return {users: users};
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
    stream<Car, grpc:Error?> carStream = stream from Car car in carsToSend
        select car;
    return carStream;
}
}
