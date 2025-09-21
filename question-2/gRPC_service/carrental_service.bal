import ballerina/grpc;

map<Car> cars = {};
map<User> users = {};
map<CartItem[]> carts = {};
map<Reservation> reservations = {};

function addCar(Car newCar) returns boolean {
    if (newCar.plateNumber.trim().length() == 0){return false;}
    else if (newCar.make.trim().length() == 0){return false;}
    else if (newCar.model.trim().length() == 0){return false;}
    else if (newCar.year.toBalString().length() == 0){return false;}
    else if (newCar.dailyPrice.toBalString().length() == 0){return false;}
    else if (newCar.mileage.toBalString().length() == 0){return false;}
    else if (newCar.status.trim().length() == 0){return false;}

    if (newCar.hasKey(newCar.plateNumber)) {return false;}
    cars[newCar.plateNumber] = newCar;
    return true;
}


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

    remote function searchCar(SearchCarRequest value) returns SearchCarResponse|error {
    }

    remote function addToCart(AddToCartRequest value) returns AddToCartResponse|error {
    }

    remote function placeReservation(PlaceReservationRequest value) returns PlaceReservationResponse|error {
    }

    remote function createUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
    }

    remote function listAvailableCars(ListAvailableCarsRequest value) returns stream<Car, error?>|error {
    }
}
