import ballerina/grpc;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: RENTAL_DESC}
service "CarRental" on ep {


 remote function searchCar(SearchCarRequest req) returns SearchCarResponse {
    Car? car = getCarByPlate(req.plate);
    if car is () {
        return { found: false, car: {} };
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


    remote function createUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
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