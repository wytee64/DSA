import ballerina/io;
import ballerina/time;

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


// type Car record {
//     string plate;
//     string make;
//     string model;
//     int year;
//     float daily_price;
//     int mileage;
//     string status; // available or unavailable
// };
function addCar(Car newCar) returns boolean {
    if (newCar.plate.trim().length() == 0){return false;}
    else if (newCar.make.trim().length() == 0){return false;}
    else if (newCar.model.trim().length() == 0){return false;}
    else if (newCar.year.toBalString().length() == 0){return false;}
    else if (newCar.dailyPrice.toBalString().length() == 0){return false;}
    else if (newCar.mileage.toBalString().length() == 0){return false;}
    else if (newCar.status.trim().length() == 0){return false;}

    if (newCar.hasKey(newCar.plate)) {return false;}
    cars[newCar.plate] = newCar;
    return true;
}

function updateCar(string newPlate, float newDailyPrice, string newStatus) returns boolean {

    if cars.hasKey(newPlate) {

        Car update = <Car>cars[newPlate];
        if(newPlate.trim().length() != 0) {update.plate = newPlate;}
        if(newDailyPrice.toBalString().trim().length() != 0) {update.dailyPrice = newDailyPrice;}
        if(newStatus.trim().length() != 0) {update.status = newStatus;}

        return true;
    }
    return false;
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
    Car carImLookingFor;
    foreach var [_, car] in cars.entries() {
        if car.plate == plate {
            return cars.get(plate);
        }
    }
    return ();
}

// type User record {
//     string user_id;
//     string name;
//     string role; //admin or customer
// };
function addUser(User newUser) returns boolean {
    if (newUser.user_id.trim().length() == 0){return false;}
    if (newUser.name.trim().length() == 0){return false;}
    if (newUser.role.trim().length() == 0){return false;}
    if (newUser.hasKey(newUser.user_id)) {return false;}
    users[newUser.user_id] = newUser;
    return true;
}

function getUser(string userId) returns User? {
    User userImLookingFor;
    foreach var [_, user] in users.entries() {
        if user.user_id == userId {
            return users.get(userId);
        }
    }

    return ();
}

function listUsers() returns User[] {
    User[] listOfUsers = []; 
    foreach var [_, user] in users.entries() {
        listOfUsers.push(user);
    }

    return [];
}





// type CartItem record {
//     string plate;
//     string startDate;
//     string endDate;
// };

function addToCart(string customerId, CartItem item) {
    CartItem[] cart = [];
    if carts.hasKey(customerId) {
        //addin item to the old card
        cart = <CartItem[]>carts[customerId];
        cart.push(item);
        carts[customerId] = cart;
    }
    else {
        //adding item to the empty card
        cart.push(item);
        carts[customerId] = cart;
    }
}


function getCart(string customerId) returns CartItem[] {
    CartItem[] cart = [];
    if carts.hasKey(customerId) {return <CartItem[]>carts[customerId];}
    else {return [];}

}



function clearCart(string customerId) {
    if (carts.hasKey(customerId)) {_ = carts.remove(customerId);}

}

