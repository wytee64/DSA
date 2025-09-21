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
        io:println("2. Get Asset");
        io:println("3. Update Asset");
        io:println("4. Remove Asset");
        io:println("5. Add Component to Asset");
        io:println("6. List Components of Asset");
        io:println("7. Update Component of Asset");
        io:println("8. Remove Component of Asset");
        io:println("9. Add Work Order to Asset");
        io:println("10. List Work Orders of Asset");
        io:println("11. Add Schedule to Asset");
        io:println("12. List Schedules of Asset");
        io:println("13. Update Schedule of Asset");
        io:println("14. Remove Schedule of Asset");
        io:println("15. Advance Schedule of Asset");
        io:println("16. List Overdue Schedules");
        io:println("17. Filter Assets by Faculty");
        io:println("18. Exit");
        io:print("enter choice (1-18): ");
        string choice = io:readln().trim();
        if choice == "18" {
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

            json asset = { 
                assetTag: tag, 
                name: name, 
                faculty: faculty, 
                department: dept,
                status: status,
                aquiredDate: acquired 
            };
            json resp = check clientEP->post("/addAsset", asset);
            io:println("Response: ", resp.toJsonString());
        }
        "2" => {
            string tag = io:readln("enter assetTag: ").trim();
            json resp = check clientEP->get("/getAsset/" + tag);
            io:println(resp.toJsonString());
        }
        "3" => {
            string tag = io:readln("enter Asset Tag to Update: ");

            // Get existing asset first
            json existing = check clientEP->get("/getAsset/" + tag);
            Asset existingAsset = <Asset>existing;

            string name = io:readln("New Name (leave empty to keep '" + existingAsset.name + "'): ");
            string status = io:readln("New Status (ACTIVE/UNDER_REPAIR/DISPOSED, leave empty to keep '" + existingAsset.status + "'): ");
            string faculty = io:readln("New Faculty (leave empty to keep '" + existingAsset.faculty + "'): ");
            string dept = io:readln("New Department (leave empty to keep '" + existingAsset.department + "'): ");

            json updated = {
                name: name,
                faculty: faculty,
                department: dept,
                status: status      
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
            string tag = io:readln("asset Tag: ");
            string cid = io:readln("ecomponent Id: ");
            string name = io:readln("name: ");
            string serial = io:readln("serial (optional): ");
            string status = io:readln("status: ");
            json comp = { 
                name: name, 
                serial: serial == "" ? () : serial , 
                status: status == "" ? () : status
                };
            json resp = check clientEP->put("/" + tag + "/components/" + cid, comp);
            io:println(resp.toJsonString());
        }
        "8" => {
            string tag = io:readln("enter assetTag: ").trim();
            string cid = io:readln("enter component Id: ").trim();
            json resp = check clientEP->delete("/" + tag + "/components/" + cid);
            io:println(resp.toJsonString());
        }
        "9" => {
            string tag = io:readln("Enter Asset Tag: ");
            string title = io:readln("Work Order Title: ");
            string desc = io:readln("Description: ");
            string status = io:readln("Status (open/in_progress/closed): ");

            WorkOrder wo = {title: title, description: desc, status: status, tasks: {}};
            json resp = check clientEP->post("/" + tag + "/workorders", wo);
            io:println("Response: ", resp.toJsonString());
        }
        "10" => {
            string tag = io:readln("Enter Asset Tag: ");
            json resp = check clientEP->get("/" + tag + "/workorders");
            io:println(resp.toJsonString());
        }
        "11" => {
            string tag = io:readln("Enter Asset Tag: ");
            string desc = io:readln("schedule description: ").trim();
            string freq = io:readln("frequency (daily/weekly/monthly): ").trim();
            string date = io:readln("nextDue (YYYY-MM-DD): ").trim();
            json payload = { description: desc, frequency: freq, nextDue: date };
            json resp = check clientEP->post("/" + tag + "/schedules", payload);
            io:println(resp.toJsonString());
        }
        "12" => {
            string tag = io:readln("Enter Asset Tag: ");
            json resp = check clientEP->get("/" + tag + "/schedules");
            io:println(resp.toJsonString());
        }
        "13" => {
            string tag = io:readln("Enter Asset Tag: ");
            string sid = io:readln("scheduleId: ").trim();
            string desc = io:readln("description: ").trim();
            string freq = io:readln("frequency: ").trim();
            string date = io:readln("new nextDue: ").trim();
            json sched = { description: desc, frequency: freq, nextDue: date };
            json resp = check clientEP->put("/" + tag + "/schedules/" + sid, sched);
            io:println(resp.toJsonString());
        }
        "14" => {
            string tag = io:readln("Enter Asset Tag: ");
            string sid = io:readln("schedule Id: ");
            json resp = check clientEP->delete("/" + tag + "/schedules/" + sid);
            io:println(resp.toJsonString());
        }
        "15" => {
            string tag = io:readln("Enter Asset Tag: ");
            string sid = io:readln("schedule Id: ");
            json resp = check clientEP->post("/" + tag + "/schedules/" + sid + "/advance", {});
            io:println(resp.toJsonString());
        }
        "16" => {
            json resp = check clientEP->get("/overdue_schedules");
            io:println(resp.toJsonString());
        }
        "17" => {
            string faculty = io:readln("enter faculty: ").trim();
            json resp = check clientEP->get("/faculty/" + faculty);
            io:println(resp.toJsonString());
        }
        _ => {
            io:println("Invalid choice, please try again!");
        }
    }
}
