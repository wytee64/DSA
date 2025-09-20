import ballerina/io;

CarRentalClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    AddCarRequest addCarRequest = {plate: "ballerina", make: "ballerina", model: "ballerina", year: 1, dailyPrice: 1, mileage: 1, status: "ballerina"};
    AddCarResponse addCarResponse = check ep->addCar(addCarRequest);
    io:println(addCarResponse);

    UpdateCarRequest updateCarRequest = {plate: "ballerina", dailyPrice: 1, status: "ballerina"};
    UpdateCarResponse updateCarResponse = check ep->updateCar(updateCarRequest);
    io:println(updateCarResponse);

    RemoveCarRequest removeCarRequest = {plate: "ballerina"};
    RemoveCarResponse removeCarResponse = check ep->removeCar(removeCarRequest);
    io:println(removeCarResponse);

    SearchCarRequest searchCarRequest = {plate: "ballerina"};
    SearchCarResponse searchCarResponse = check ep->searchCar(searchCarRequest);
    io:println(searchCarResponse);

    AddToCartRequest addToCartRequest = {customerId: "ballerina", plate: "ballerina", startDate: "ballerina", endDate: "ballerina"};
    AddToCartResponse addToCartResponse = check ep->addToCart(addToCartRequest);
    io:println(addToCartResponse);

    PlaceReservationRequest placeReservationRequest = {customerId: "ballerina"};
    PlaceReservationResponse placeReservationResponse = check ep->placeReservation(placeReservationRequest);
    io:println(placeReservationResponse);

    ListAvailableCarsRequest listAvailableCarsRequest = {filter: "ballerina"};
    stream<Car, error?> listAvailableCarsResponse = check ep->listAvailableCars(listAvailableCarsRequest);
    check listAvailableCarsResponse.forEach(function(Car value) {
        io:println(value);
    });

    User createUsersRequest = {userId: "ballerina", name: "ballerina", role: "ballerina"};
    CreateUsersStreamingClient createUsersStreamingClient = check ep->createUsers();
    check createUsersStreamingClient->sendUser(createUsersRequest);
    check createUsersStreamingClient->complete();
    CreateUsersResponse? createUsersResponse = check createUsersStreamingClient->receiveCreateUsersResponse();
    io:println(createUsersResponse);
}
