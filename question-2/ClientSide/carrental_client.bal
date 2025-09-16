import ballerina/io;

CarRentalClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    AddCarRequest add_carRequest = {make: "ballerina", model: "ballerina", year: 1, dailyPrice: 1, mileage: 1, plate: "ballerina", status: "ballerina"};
    AddCarResponse add_carResponse = check ep->add_car(add_carRequest);
    io:println(add_carResponse);

    UpdateCarRequest update_carRequest = {plate: "ballerina", dailyPrice: 1, status: "ballerina"};
    UpdateCarResponse update_carResponse = check ep->update_car(update_carRequest);
    io:println(update_carResponse);

    RemoveCarRequest remove_carRequest = {plate: "ballerina"};
    RemoveCarResponse remove_carResponse = check ep->remove_car(remove_carRequest);
    io:println(remove_carResponse);

    SearchCarRequest search_carRequest = {plate: "ballerina"};
    SearchCarResponse search_carResponse = check ep->search_car(search_carRequest);
    io:println(search_carResponse);

    AddToCartRequest add_to_cartRequest = {customerId: "ballerina", plate: "ballerina", startDate: "ballerina", endDate: "ballerina"};
    AddToCartResponse add_to_cartResponse = check ep->add_to_cart(add_to_cartRequest);
    io:println(add_to_cartResponse);

    PlaceReservationRequest place_reservationRequest = {customerId: "ballerina"};
    PlaceReservationResponse place_reservationResponse = check ep->place_reservation(place_reservationRequest);
    io:println(place_reservationResponse);

    ListAvailableCarsRequest list_available_carsRequest = {filter: "ballerina"};
    stream<Car, error?> list_available_carsResponse = check ep->list_available_cars(list_available_carsRequest);
    check list_available_carsResponse.forEach(function(Car value) {
        io:println(value);
    });

    User create_usersRequest = {userId: "ballerina", name: "ballerina", role: "ballerina"};
    Create_usersStreamingClient create_usersStreamingClient = check ep->create_users();
    check create_usersStreamingClient->sendUser(create_usersRequest);
    check create_usersStreamingClient->complete();
    CreateUsersResponse? create_usersResponse = check create_usersStreamingClient->receiveCreateUsersResponse();
    io:println(create_usersResponse);
}
