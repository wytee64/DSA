import ballerina/io;
import ballerina/http;

// ===================== TYPES ===================== //
type Component record {|
    string id?;
    string name;
    string? serial;
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
    map<record {|string id?; string maintenanceType; string nextDueDate; string status;|}> schedules;
    map<WorkOrder> workOrders;
|};

// ===================== CLIENT ===================== //
http:Client clientEP = check new ("http://localhost:8080/assets");

public function main() returns error? {
    io:println("NUST Asset Management Client");
    io:println("----------------------------------");

    while true {
        io:println("\nChoose an option:");
        io:println("1. Add Asset");
        io:println("2. Get Asset by Tag");
        io:println("3. Update Asset ");
        io:println("4. Delete Asset");
        io:println("5. Add Component to Asset");
        io:println("6. List Components of Asset");
        io:println("7. Add Work Order");
        io:println("8. List Work Orders");
        io:println("9. Add Task to Work Order");
        io:println("10. List Tasks in Work Order");
        io:println("11. Exit");

        string choice = io:readln("Enter choice (1-11): ");
        if choice == "11" {
            io:println("Exiting client... Goodbye!");
            break;
        }

        check handleChoice(choice);
    }
}

function handleChoice(string choice) returns error? {
    match choice {
        "1" => {
            string tag = io:readln("Asset Tag: ");
            string name = io:readln("Name: ");
            string faculty = io:readln("Faculty: ");
            string dept = io:readln("Department: ");
            string status = io:readln("Status (ACTIVE/UNDER_REPAIR/DISPOSED): ");
            string acquired = io:readln("Acquired Date (YYYY-MM-DD): ");

            Asset asset = {
                assetTag: tag,
                name: name,
                faculty: faculty,
                department: dept,
                status: status,
                acquiredDate: acquired,
                components: {},
                schedules: {},
                workOrders: {}
            };

            json resp = check clientEP->post("/addAsset", asset);
            io:println("Response: ", resp.toJsonString());
        }
        "2" => {
            string tag = io:readln("Enter Asset Tag: ");
            json resp = check clientEP->get("/getAsset/" + tag);
            io:println("Response: ", resp.toJsonString());
        }
        "3" => {
            string tag = io:readln("Enter Asset Tag to Update: ");
            string name = io:readln("New Name: ");
            string faculty = io:readln("New Faculty: ");
            string dept = io:readln("New Department: ");
            string status = io:readln("New Status (ACTIVE/UNDER_REPAIR/DISPOSED): ");

            Asset updated = {
                assetTag: tag,
                name: name,
                faculty: faculty,
                department: dept,
                status: status,
                acquiredDate: "",    
                components: {},       
                schedules: {},        
                workOrders: {}        
            };

            io:println("\nPUT request:");
            json resp = check clientEP->put("/updateAsset/" + tag, updated);
            io:println(resp.toJsonString());
            io:println("");
        }
        "4" => {
            string tag = io:readln("Enter Asset Tag to Delete: ");
            json resp = check clientEP->delete("/removeAsset/" + tag);
            io:println("Response: ", resp.toJsonString());
        }
        "5" => {
            string tag = io:readln("Enter Asset Tag: ");
            string name = io:readln("Component Name: ");
            string serial = io:readln("Component Serial Number/ID: ");
            string status = io:readln("Component Status (OK/FAULTY/REPLACED): ");

            Component comp = { name: name, serial: serial, status: status };
            json resp = check clientEP->post("/" + tag + "/components", comp);
            io:println("Response: ", resp.toJsonString());
        }
        "6" => {
            string tag = io:readln("Enter Asset Tag: ");
            json resp = check clientEP->get("/" + tag + "/components");
            io:println("Components: ", resp.toJsonString());
        }
        "7" => {
            string tag = io:readln("Enter Asset Tag: ");
            string title = io:readln("Work Order Title: ");
            string desc = io:readln("Description: ");
            string status = io:readln("Status (open/in_progress/closed): ");

            WorkOrder wo = {title: title, description: desc, status: status, tasks: {}};
            json resp = check clientEP->post("/" + tag + "/workorders", wo);
            io:println("Response: ", resp.toJsonString());
        }
        "8" => {
            string tag = io:readln("Enter Asset Tag: ");
            json resp = check clientEP->get("/" + tag + "/workorders");
            io:println("Work Orders: ", resp.toJsonString());
        }
        "9" => {
            string tag = io:readln("Enter Asset Tag: ");
            string woId = io:readln("Enter Work Order ID: ");
            string desc = io:readln("Task Description: ");
            string status = io:readln("Task Status (pending/done): ");

            Task t = {description: desc, status: status};
            json resp = check clientEP->post("/" + tag + "/workorders/" + woId + "/tasks", t);
            io:println("Response: ", resp.toJsonString());
        }
        "10" => {
            string tag = io:readln("Enter Asset Tag: ");
            string woId = io:readln("Enter Work Order ID: ");
            json resp = check clientEP->get("/" + tag + "/workorders/" + woId + "/tasks");
            io:println("Tasks: ", resp.toJsonString());
        }
        _ => {
            io:println("Invalid choice, please try again!");
        }
    }
}
