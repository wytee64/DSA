import ballerina/grpc;
type User record {
    string user_id;
    string name;
    string role; //admin or customer
};

type Car record {
    string plate;
    string make;
    string model;
    int year;
    float dailyPrice;
    int mileage;
    string status; // available or unavailable
};

type Reservation record {
    string reservationId;
    string customerId;
    CartItem[] items;
    float totalPrice;
};

type CartItem record {
    string plate;
    string startDate;
    string endDate;
};


map<Car> cars = {};
map<User> users = {};
map<CartItem[]> carts = {};
map<Reservation> reservations = {};

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
