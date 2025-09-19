import ballerina/grpc;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: RENTAL_DESC}
service "CarRental" on ep {

    remote function addCar(AddCarRequest value) returns AddCarResponse|error {
    }

    remote function updateCar(UpdateCarRequest value) returns UpdateCarResponse|error {
    }

    remote function removeCar(RemoveCarRequest value) returns RemoveCarResponse|error {
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
