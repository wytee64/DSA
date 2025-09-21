import ballerina/io;
import ballerina/http;

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
        io:println("9. Add Work Order");
        io:println("10. List Work Orders");
        io:println("11. Add Maintenance Schedule");
        io:println("12. List Maintenance Schedules");
        io:println("13. Update Maintenance Schedule");
        io:println("14. Delete Maintenance Schedule");
        io:println("15. Advance Maintenance Schedule");
        io:println("16. List Overdue Schedules");
        io:println("17. Search Assets by Faculty");
        io:println("18. Exit");
        io:print("enter choice (1-18): ");
        string choice = io:readln().trim();
        if choice == "18" {
            io:println("peace");
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
            json|error resp = clientEP->/addAsset.post(asset);
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println("Response: ", resp.toJsonString());
        }
        "2" => {
            string tag = io:readln("enter assetTag: ").trim();
            json|error resp = clientEP->/getAsset/[tag];
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println(resp.toJsonString());
        }
        "3" => {
            string tag = io:readln("enter Asset Tag to Update: ");
            json|error getResp = clientEP->/getAsset/[tag];
            if getResp is error {
                io:println("error gettin asset: ", getResp.message());
                return;
            }

            Asset existingAsset = check getResp.cloneWithType();

            string newName = io:readln("New Name (leave empty to keep '" + existingAsset.name + "'): ");
            string newStatus = io:readln("New Status (leave empty to keep '" + existingAsset.status + "'): ");
            string newFaculty = io:readln("New Faculty (leave empty to keep '" + existingAsset.faculty + "'): ");
            string newDept = io:readln("New Department (leave empty to keep '" + existingAsset.department + "'): ");

            Asset updatedAsset = {
                assetTag: tag,
                name: newName == "" ? existingAsset.name : newName,
                faculty: newFaculty == "" ? existingAsset.faculty : newFaculty,
                department: newDept == "" ? existingAsset.department : newDept,
                status: newStatus == "" ? existingAsset.status : newStatus,
                acquiredDate: existingAsset.acquiredDate,
                components: existingAsset.components,
                schedules: existingAsset.schedules,
                workOrders: existingAsset.workOrders
            };

            json|error resp = clientEP->/updateAsset/[tag].put(updatedAsset);
            if resp is error {
                io:println("error updatin asset: ", resp.message());
                return;
            }
            io:println(resp.toJsonString());
        }
        "4" => {
            string tag = io:readln("Enter Asset Tag to Delete: ");
            json|error resp = clientEP->/removeAsset/[tag].delete();
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println("Response: ", resp.toJsonString());
        }
        "5" => {
            string tag = io:readln("Enter Asset Tag: ");
            string name = io:readln("Component Name: ");
            string serial = io:readln("Component Serial Number: ");
            string status = io:readln("Component Status: ");

            Component comp = {
                name: name,
                serial: serial == "" ? () : serial,
                status: status
            };
            json|error resp = clientEP->/[tag]/components.post(comp);
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println("response: ", resp.toJsonString());
        }
        "6" => {
            string tag = io:readln("Enter Asset Tag: ");
            json|error resp = clientEP->/[tag]/components;
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println("Components: ", resp.toJsonString());
        }
        "7" => {
            string tag = io:readln("Asset Tag: ");
            string cid = io:readln("Component Id: ");
            string name = io:readln("Name: ");
            string serial = io:readln("Serial: ");
            string status = io:readln("Status: ");
            
            Component comp = {
                id: cid,
                name: name,
                serial: serial == "" ? () : serial,
                status: status
            };
            json|error resp = clientEP->/[tag]/components/[cid].put(comp);
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println(resp.toJsonString());
        }
        "8" => {
            string tag = io:readln("Enter Asset Tag: ");
            string cid = io:readln("Enter Component Id: ");
            json|error resp = clientEP->/[tag]/components/[cid].delete();
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println(resp.toJsonString());
        }
        "9" => {
            string tag = io:readln("Asset Tag: ");
            string title = io:readln("Work Order Title: ");
            string desc = io:readln("Work Order Description: ");
            string status = io:readln("Status (open/in_progress/closed): ");

            WorkOrder wo = {
                title: title,
                description: desc,
                status: status,
                tasks: {}
            };
            json|error resp = clientEP->/[tag]/workorders.post(wo);
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println("Response: ", resp.toJsonString());
        }
        "10" => {
            string tag = io:readln("Asset Tag: ");
            json|error resp = clientEP->/getAsset/[tag];
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            Asset asset = check resp.cloneWithType();
            io:println("Work Orders: ", asset.workOrders.toJsonString());
        }
        "11" => {
            string tag = io:readln("Asset Tag: ");
            string mType = io:readln("Maintenance Type (weekly/monthly/quarterly/yearly): ");
            string nextDue = io:readln("Next Due Date (YYYY-MM-DD): ");
            string status = io:readln("Status: ");

            Maintenance sched = {
                maintenanceType: mType,
                nextDueDate: nextDue,
                status: status
            };
            json|error resp = clientEP->/[tag]/schedules.post(sched);
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println("Response: ", resp.toJsonString());
        }
        "12" => {
            string tag = io:readln("Asset Tag: ");
            json|error resp = clientEP->/[tag]/schedules;
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println("Schedules: ", resp.toJsonString());
        }
        "13" => {
            string tag = io:readln("Asset Tag: ");
            string schedId = io:readln("Schedule ID: ");
            string mType = io:readln("Maintenance Type (weekly/monthly/quarterly/yearly): ");
            string nextDue = io:readln("Next Due Date (YYYY-MM-DD): ");
            string status = io:readln("Status: ");

            Maintenance sched = {
                id: schedId,
                maintenanceType: mType,
                nextDueDate: nextDue,
                status: status
            };
            json|error resp = clientEP->/[tag]/schedules/[schedId].put(sched);
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println("Response: ", resp.toJsonString());
        }
        "14" => {
            string tag = io:readln("Asset Tag: ");
            string schedId = io:readln("Schedule ID: ");
            json|error resp = clientEP->/[tag]/schedules/[schedId].delete();
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println("Response: ", resp.toJsonString());
        }
        "15" => {
            string tag = io:readln("Asset Tag: ");
            string schedId = io:readln("Schedule ID: ");
            json|error resp = clientEP->/[tag]/schedules/[schedId]/advance.post({});
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println("Response: ", resp.toJsonString());
        }
        "16" => {
            string today = io:readln("Today's Date (YYYY-MM-DD, press Enter for current date): ");
            string path = today.trim() == "" ? "/overdue_schedules" : "/overdue_schedules?today=" + today;
            json|error resp = clientEP->get(path);
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println("Overdue Schedules: ", resp.toJsonString());
        }
        "17" => {
            string faculty = io:readln("Faculty (or 'all' for all assets): ");
            json|error resp = clientEP->/faculty/[faculty];
            if resp is error {
                io:println("error: ", resp.message());
                return;
            }
            io:println("Assets: ", resp.toJsonString());
        }
        _ => {
            io:println("choice invalid ,try again still");
        }
    }
}
