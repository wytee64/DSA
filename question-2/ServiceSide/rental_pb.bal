import ballerina/grpc;
import ballerina/protobuf;

public const string RENTAL_DESC = "0A0C72656E74616C2E70726F746F22B7010A0343617212200A0B706C6174654E756D626572180120012809520B706C6174654E756D62657212120A046D616B6518022001280952046D616B6512140A056D6F64656C18032001280952056D6F64656C12120A0479656172180420012805520479656172121E0A0A6461696C795072696365180520012801520A6461696C79507269636512180A076D696C6561676518062001280552076D696C6561676512160A06737461747573180720012809520673746174757322460A045573657212160A06757365724964180120012809520675736572496412120A046E616D6518022001280952046E616D6512120A04726F6C651803200128095204726F6C6522640A08436172744974656D12200A0B706C6174654E756D626572180120012809520B706C6174654E756D626572121C0A09737461727444617465180220012809520973746172744461746512180A07656E64446174651803200128095207656E64446174652294010A0B5265736572766174696F6E12240A0D7265736572766174696F6E4964180120012809520D7265736572766174696F6E4964121E0A0A637573746F6D65724964180220012809520A637573746F6D65724964121F0A056974656D7318032003280B32092E436172744974656D52056974656D73121E0A0A746F74616C5072696365180420012801520A746F74616C507269636522B5010A0D4164644361725265717565737412120A046D616B6518012001280952046D616B6512140A056D6F64656C18022001280952056D6F64656C12120A0479656172180320012805520479656172121E0A0A6461696C795072696365180420012801520A6461696C79507269636512180A076D696C6561676518052001280552076D696C6561676512140A05706C6174651806200128095205706C61746512160A06737461747573180720012809520673746174757322280A0E416464436172526573706F6E736512160A0363617218012001280B32042E436172520363617222320A134372656174655573657273526573706F6E7365121B0A05757365727318012003280B32052E557365725205757365727322600A105570646174654361725265717565737412140A05706C6174651801200128095205706C617465121E0A0A6461696C795072696365180220012801520A6461696C79507269636512160A067374617475731803200128095206737461747573222B0A11557064617465436172526573706F6E736512160A0363617218012001280B32042E436172520363617222280A1052656D6F76654361725265717565737412140A05706C6174651801200128095205706C617465222D0A1152656D6F7665436172526573706F6E736512180A046361727318012003280B32042E43617252046361727322320A184C697374417661696C61626C65436172735265717565737412160A0666696C746572180120012809520666696C74657222280A105365617263684361725265717565737412140A05706C6174651801200128095205706C61746522410A11536561726368436172526573706F6E736512140A05666F756E641801200128085205666F756E6412160A0363617218022001280B32042E43617252036361722280010A10416464546F4361727452657175657374121E0A0A637573746F6D65724964180120012809520A637573746F6D6572496412140A05706C6174651802200128095205706C617465121C0A09737461727444617465180320012809520973746172744461746512180A07656E64446174651804200128095207656E6444617465224C0A11416464546F43617274526573706F6E736512180A0773756363657373180120012808520773756363657373121D0A046974656D18022001280B32092E436172744974656D52046974656D22390A17506C6163655265736572766174696F6E52657175657374121E0A0A637573746F6D65724964180120012809520A637573746F6D65724964227E0A18506C6163655265736572766174696F6E526573706F6E736512180A0773756363657373180120012808520773756363657373122E0A0B7265736572766174696F6E18022001280B320C2E5265736572766174696F6E520B7265736572766174696F6E12180A076D65737361676518032001280952076D65737361676532BF030A0943617252656E74616C122A0A076164645F636172120E2E416464436172526571756573741A0F2E416464436172526573706F6E7365122D0A0C6372656174655F757365727312052E557365721A142E4372656174655573657273526573706F6E7365280112330A0A7570646174655F63617212112E557064617465436172526571756573741A122E557064617465436172526573706F6E736512330A0A72656D6F76655F63617212112E52656D6F7665436172526571756573741A122E52656D6F7665436172526573706F6E736512380A136C6973745F617661696C61626C655F6361727312192E4C697374417661696C61626C6543617273526571756573741A042E436172300112330A0A7365617263685F63617212112E536561726368436172526571756573741A122E536561726368436172526573706F6E736512340A0B6164645F746F5F6361727412112E416464546F43617274526571756573741A122E416464546F43617274526573706F6E736512480A11706C6163655F7265736572766174696F6E12182E506C6163655265736572766174696F6E526571756573741A192E506C6163655265736572766174696F6E526573706F6E7365620670726F746F33";

public isolated client class CarRentalClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, RENTAL_DESC);
    }

    isolated remote function add_car(AddCarRequest|ContextAddCarRequest req) returns AddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddCarRequest message;
        if req is ContextAddCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRental/add_car", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddCarResponse>result;
    }

    isolated remote function add_carContext(AddCarRequest|ContextAddCarRequest req) returns ContextAddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddCarRequest message;
        if req is ContextAddCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRental/add_car", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddCarResponse>result, headers: respHeaders};
    }

    isolated remote function update_car(UpdateCarRequest|ContextUpdateCarRequest req) returns UpdateCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRental/update_car", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UpdateCarResponse>result;
    }

    isolated remote function update_carContext(UpdateCarRequest|ContextUpdateCarRequest req) returns ContextUpdateCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRental/update_car", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UpdateCarResponse>result, headers: respHeaders};
    }

    isolated remote function remove_car(RemoveCarRequest|ContextRemoveCarRequest req) returns RemoveCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRental/remove_car", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RemoveCarResponse>result;
    }

    isolated remote function remove_carContext(RemoveCarRequest|ContextRemoveCarRequest req) returns ContextRemoveCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRental/remove_car", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RemoveCarResponse>result, headers: respHeaders};
    }

    isolated remote function search_car(SearchCarRequest|ContextSearchCarRequest req) returns SearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRental/search_car", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchCarResponse>result;
    }

    isolated remote function search_carContext(SearchCarRequest|ContextSearchCarRequest req) returns ContextSearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRental/search_car", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchCarResponse>result, headers: respHeaders};
    }

    isolated remote function add_to_cart(AddToCartRequest|ContextAddToCartRequest req) returns AddToCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRental/add_to_cart", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddToCartResponse>result;
    }

    isolated remote function add_to_cartContext(AddToCartRequest|ContextAddToCartRequest req) returns ContextAddToCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRental/add_to_cart", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddToCartResponse>result, headers: respHeaders};
    }

    isolated remote function place_reservation(PlaceReservationRequest|ContextPlaceReservationRequest req) returns PlaceReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRental/place_reservation", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PlaceReservationResponse>result;
    }

    isolated remote function place_reservationContext(PlaceReservationRequest|ContextPlaceReservationRequest req) returns ContextPlaceReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRental/place_reservation", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PlaceReservationResponse>result, headers: respHeaders};
    }

    isolated remote function create_users() returns Create_usersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("CarRental/create_users");
        return new Create_usersStreamingClient(sClient);
    }

    isolated remote function list_available_cars(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns stream<Car, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("CarRental/list_available_cars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        CarStream outputStream = new CarStream(result);
        return new stream<Car, grpc:Error?>(outputStream);
    }

    isolated remote function list_available_carsContext(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns ContextCarStream|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("CarRental/list_available_cars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        CarStream outputStream = new CarStream(result);
        return {content: new stream<Car, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class Create_usersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUser(User message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUser(ContextUser message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveCreateUsersResponse() returns CreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <CreateUsersResponse>payload;
        }
    }

    isolated remote function receiveContextCreateUsersResponse() returns ContextCreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <CreateUsersResponse>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class CarStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Car value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Car value;|} nextRecord = {value: <Car>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public isolated client class CarRentalCarCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCar(Car response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCar(ContextCar response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalUpdateCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendUpdateCarResponse(UpdateCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextUpdateCarResponse(ContextUpdateCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalRemoveCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendRemoveCarResponse(RemoveCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextRemoveCarResponse(ContextRemoveCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalSearchCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendSearchCarResponse(SearchCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextSearchCarResponse(ContextSearchCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalPlaceReservationResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendPlaceReservationResponse(PlaceReservationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextPlaceReservationResponse(ContextPlaceReservationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalAddToCartResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendAddToCartResponse(AddToCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextAddToCartResponse(ContextAddToCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalAddCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendAddCarResponse(AddCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextAddCarResponse(ContextAddCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalCreateUsersResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCreateUsersResponse(CreateUsersResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCreateUsersResponse(ContextCreateUsersResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextUserStream record {|
    stream<User, error?> content;
    map<string|string[]> headers;
|};

public type ContextCarStream record {|
    stream<Car, error?> content;
    map<string|string[]> headers;
|};

public type ContextUser record {|
    User content;
    map<string|string[]> headers;
|};

public type ContextPlaceReservationResponse record {|
    PlaceReservationResponse content;
    map<string|string[]> headers;
|};

public type ContextRemoveCarRequest record {|
    RemoveCarRequest content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarRequest record {|
    UpdateCarRequest content;
    map<string|string[]> headers;
|};

public type ContextAddCarResponse record {|
    AddCarResponse content;
    map<string|string[]> headers;
|};

public type ContextAddToCartResponse record {|
    AddToCartResponse content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarResponse record {|
    UpdateCarResponse content;
    map<string|string[]> headers;
|};

public type ContextAddToCartRequest record {|
    AddToCartRequest content;
    map<string|string[]> headers;
|};

public type ContextListAvailableCarsRequest record {|
    ListAvailableCarsRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarRequest record {|
    SearchCarRequest content;
    map<string|string[]> headers;
|};

public type ContextAddCarRequest record {|
    AddCarRequest content;
    map<string|string[]> headers;
|};

public type ContextRemoveCarResponse record {|
    RemoveCarResponse content;
    map<string|string[]> headers;
|};

public type ContextCar record {|
    Car content;
    map<string|string[]> headers;
|};

public type ContextPlaceReservationRequest record {|
    PlaceReservationRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarResponse record {|
    SearchCarResponse content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersResponse record {|
    CreateUsersResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type User record {|
    string userId = "";
    string name = "";
    string role = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type PlaceReservationResponse record {|
    boolean success = false;
    Reservation reservation = {};
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type RemoveCarRequest record {|
    string plate = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type UpdateCarRequest record {|
    string plate = "";
    float dailyPrice = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type AddCarResponse record {|
    Car car = {};
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type AddToCartResponse record {|
    boolean success = false;
    CartItem item = {};
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type UpdateCarResponse record {|
    Car car = {};
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type CartItem record {|
    string plateNumber = "";
    string startDate = "";
    string endDate = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type AddToCartRequest record {|
    string customerId = "";
    string plate = "";
    string startDate = "";
    string endDate = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type ListAvailableCarsRequest record {|
    string filter = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type SearchCarRequest record {|
    string plate = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type AddCarRequest record {|
    string make = "";
    string model = "";
    int year = 0;
    float dailyPrice = 0.0;
    int mileage = 0;
    string plate = "";
    string status = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type RemoveCarResponse record {|
    Car[] cars = [];
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type Reservation record {|
    string reservationId = "";
    string customerId = "";
    CartItem[] items = [];
    float totalPrice = 0.0;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type Car record {|
    string plateNumber = "";
    string make = "";
    string model = "";
    int year = 0;
    float dailyPrice = 0.0;
    int mileage = 0;
    string status = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type PlaceReservationRequest record {|
    string customerId = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type SearchCarResponse record {|
    boolean found = false;
    Car car = {};
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type CreateUsersResponse record {|
    User[] users = [];
|};
