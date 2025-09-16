import ballerina/http;
import ballerina/time;

// ---------- Domain ----------
type Status "ACTIVE"|"UNDER_REPAIR"|"DISPOSED";
type WOStatus "OPEN"|"IN_PROGRESS"|"CLOSED";

type Component record {| string id; string name; |};
type Schedule  record {| string id; string cadence; string nextDue; |}; // YYYY-MM-DD
type Task      record {| string id; string text; boolean done; |};
type WorkOrder record {| string id; WOStatus status; Task[] tasks; |};

type Asset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    Status status;
    string acquiredDate;     // YYYY-MM-DD
    Component[] components;
    Schedule[]  schedules;
    WorkOrder[] workOrders;
|};

// In-memory DB keyed by assetTag
map<Asset> db = {};

// ---------- Helpers ----------
function todayStr() returns string {
    // e.g. "2025-09-14T18:22:03.123Z" -> "2025-09-14"
    time:Utc now = time:utcNow();
    string iso = now.toString();
    return iso.substring(0, 10);
}

function ltDate(string a, string b) returns boolean {
    // ISO YYYY-MM-DD strings compare correctly lexically
    return a < b;
}

// ---------- Service ----------
@http:ServiceConfig {
    cors: { allowOrigins:["*"], allowMethods:["GET","POST","PUT","DELETE"], allowHeaders:["content-type"] }
}
service / on new http:Listener(9090) {

    // Create asset
    resource function post assets(@http:Payload Asset a) returns http:Created|http:Conflict {
        if db.hasKey(a.assetTag) { return <http:Conflict>{ body: {message:"asset exists"} }; }
        db[a.assetTag] = a;
        return <http:Created>{ body: a };
    }

    // List all or filter by faculty: GET /assets?faculty=...
    resource function get assets(@http:Query string? faculty) returns Asset[] {
        Asset[] out = [];
        foreach string k in db.keys() {
            Asset? vOpt = db[k];
            if vOpt is Asset {
                if faculty is string {
                    if vOpt.faculty == faculty { out.push(vOpt); }
                } else {
                    out.push(vOpt);
                }
            }
        }
        return out;
    }

    // Get by id
    resource function get assets/[string tag]() returns Asset|http:NotFound {
        Asset? a = db[tag];
        if a is () { return <http:NotFound>{ body: {message:"not found"} }; }
        return a;
    }

    // Update by id (replace)
    resource function put assets/[string tag](@http:Payload Asset body) returns Asset|http:NotFound {
        if !db.hasKey(tag) { return <http:NotFound>{ body: {message:"not found"} }; }
        body.assetTag = tag; // enforce key
        db[tag] = body;
        return body;
    }

    // Delete by id
    resource function delete assets/[string tag]() returns json|http:NotFound {
        if !db.hasKey(tag) { return <http:NotFound>{ body: {message:"not found"} }; }
        _ = db.remove(tag);
        return { message:"deleted" };
    }

    // Overdue schedules (optional ?today=YYYY-MM-DD)
    resource function get assets/overdue(@http:Query string? today) returns Asset[] {
        string t = today is string && today.length() > 0 ? today : todayStr();
        Asset[] out = [];
        foreach string k in db.keys() {
            Asset? aOpt = db[k];
            if aOpt is Asset {
                boolean hasOverdue = false;
                foreach var s in aOpt.schedules {
                    if ltDate(s.nextDue, t) { hasOverdue = true; break; }
                }
                if (hasOverdue) { out.push(aOpt); }
            }
        }
        return out;
    }

    // ----- Components -----
    resource function post assets/[string tag]/components(@http:Payload Component c)
            returns Asset|http:NotFound {
        Asset? a = db[tag];
        if a is () { return <http:NotFound>{ body: {message:"not found"} }; }
        a.components.push(c);
        db[tag] = a;
        return a;
    }

    resource function delete assets/[string tag]/components/[string id]()
            returns Asset|http:NotFound {
        Asset? a = db[tag];
        if a is () { return <http:NotFound>{ body: {message:"not found"} }; }
        a.components = from var x in a.components where x.id != id select x;
        db[tag] = a;
        return a;
    }

    // ----- Schedules -----
    resource function post assets/[string tag]/schedules(@http:Payload Schedule s)
            returns Asset|http:NotFound {
        Asset? a = db[tag];
        if a is () { return <http:NotFound>{ body: {message:"not found"} }; }
        a.schedules.push(s);
        db[tag] = a;
        return a;
    }

    resource function delete assets/[string tag]/schedules/[string id]()
            returns Asset|http:NotFound {
        Asset? a = db[tag];
        if a is () { return <http:NotFound>{ body: {message:"not found"} }; }
        a.schedules = from var s in a.schedules where s.id != id select s;
        db[tag] = a;
        return a;
    }

    // ----- Work orders & tasks -----
    resource function post assets/[string tag]/workorders(@http:Payload WorkOrder w)
            returns Asset|http:NotFound {
        Asset? a = db[tag];
        if a is () { return <http:NotFound>{ body: {message:"not found"} }; }
        a.workOrders.push(w);
        db[tag] = a;
        return a;
    }

    resource function put assets/[string tag]/workorders/[string id](@http:Payload json body)
            returns Asset|http:NotFound|http:BadRequest {
        Asset? a = db[tag];
        if a is () { return <http:NotFound>{ body: {message:"not found"} }; }
        string|error st = body.status.ensureType(string);
        if st is error { return <http:BadRequest>{ body: {message:"status required"} }; }
        foreach int i in 0 ..< a.workOrders.length() {
            if a.workOrders[i].id == id {
                if st == "OPEN" || st == "IN_PROGRESS" || st == "CLOSED" {
                    a.workOrders[i].status = <WOStatus>st;
                }
            }
        }
        db[tag] = a;
        return a;
    }

    resource function post assets/[string tag]/workorders/[string id]/tasks(@http:Payload Task t)
            returns Asset|http:NotFound {
        Asset? a = db[tag];
        if a is () { return <http:NotFound>{ body: {message:"not found"} }; }
        foreach int i in 0 ..< a.workOrders.length() {
            if a.workOrders[i].id == id { a.workOrders[i].tasks.push(t); }
        }
        db[tag] = a;
        return a;
    }

    resource function delete assets/[string tag]/workorders/[string id]/tasks/[string taskId]()
            returns Asset|http:NotFound {
        Asset? a = db[tag];
        if a is () { return <http:NotFound>{ body: {message:"not found"} }; }
        foreach int i in 0 ..< a.workOrders.length() {
            if a.workOrders[i].id == id {
                a.workOrders[i].tasks = from var t in a.workOrders[i].tasks
                                        where t.id != taskId select t;
            }
        }
        db[tag] = a;
        return a;
    }
}