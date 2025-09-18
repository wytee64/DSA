import ballerina/http;
import ballerina/io;
import ballerina/test;

final string BASE_URL = "http://localhost:8080/assets";
http:Client assetClient = check new (BASE_URL);

@test:Config {}
function testAddAsset() returns error? {
    Asset asset = {
        assetTag: "A123",
        name: "Projector",
        faculty: "Engineering",
        department: "Electrical",
        status: "working",
        acquiredDate: "2023-01-20",
        components: {},
        schedules: {},
        workOrders: {}
    };

    var response = check assetClient->post("/addAsset", asset);
    json payload = check response.getJsonPayload();
    io:println("Add Asset Response: ", response.statusCode, " -> ", payload);
}

@test:Config {}
function testGetAsset() returns error? {
    var response = check assetClient->get("/getAsset/A123");
    json payload = check response.getJsonPayload();
    io:println("Get Asset Response: ", response.statusCode, " -> ", payload);
}

@test:Config {}
function testUpdateAsset() returns error? {
    Asset updated = {
        assetTag: "A123",
        name: "Updated Projector",
        faculty: "Engineering",
        department: "Electrical",
        status: "not_working",
        acquiredDate: "2023-01-20",
        components: {},
        schedules: {},
        workOrders: {}
    };

    var response = check assetClient->put("/updateAsset/A123", updated);
    json payload = check response.getJsonPayload();
    io:println("Update Asset Response: ", response.statusCode, " -> ", payload);
}

@test:Config {}
function testAddComponent() returns error? {
    Component comp = {
        id: "C001",
        name: "Lamp",
        serial: "L-111",
        status: "OK"
    };

    var response = check assetClient->post("/A123/components", comp);
    json payload = check response.getJsonPayload();
    io:println("Add Component Response: ", response.statusCode, " -> ", payload);
}

@test:Config {}
function testGetComponents() returns error? {
    var response = check assetClient->get("/A123/components");
    json payload = check response.getJsonPayload();
    io:println("Get Components Response: ", response.statusCode, " -> ", payload);
}

@test:Config {}
function testUpdateComponent() returns error? {
    Component updatedComp = {
        id: "C001",
        name: "Lamp (Updated)",
        serial: "L-111",
        status: "FAULTY"
    };

    var response = check assetClient->put("/A123/components/C001", updatedComp);
    json payload = check response.getJsonPayload();
    io:println("Update Component Response: ", response.statusCode, " -> ", payload);
}

@test:Config {}
function testDeleteComponent() returns error? {
    var response = check assetClient->delete("/A123/components/C001");
    json payload = check response.getJsonPayload();
    io:println("Delete Component Response: ", response.statusCode, " -> ", payload);
}

@test:Config {}
function testGetByFaculty() returns error? {
    var response = check assetClient->get("/faculty/Engineering");
    json payload = check response.getJsonPayload();
    io:println("Get Faculty Assets Response: ", response.statusCode, " -> ", payload);
}

@test:Config {}
function testDeleteAsset() returns error? {
    var response = check assetClient->delete("/removeAsset/A123");
    json payload = check response.getJsonPayload();
    io:println("Delete Asset Response: ", response.statusCode, " -> ", payload);
}

type Component record {|
    string id?;
    string name;
    string? serial;
    string status;
|};

type Maintenance record {|
    string id?;
    string maintenanceType;
    string nextDueDate;
    string status;
|};

type Task record {|
    string id?;
    string description;
    string status;
|};

type WorkOrder record {|
    string id?;
    string title;
    string description;
    string status;
    map<Task> tasks;
|};

type Asset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    string status;
    string acquiredDate;
    map<Component> components;
    map<Maintenance> schedules;
    map<WorkOrder> workOrders;
|};
