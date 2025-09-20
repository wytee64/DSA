import ballerina/http;
import ballerina/uuid;
import ballerina/time; // for simple date helpers (weekly adds via seconds)

type Component record {|
    string id?;
    string name;
    string? serial;
    string status; // OK, FAULTY, REPLACED
|};

type Maintenance record {|
    string id?;
    string maintenanceType;   // weekly,monthly,yearly
    string nextDueDate;      // year then month then date (YYYY-MM-DD)
    string status;
|};

type Task record {|
    string id?;
    string description;
    string status; // pending, done
|};

type WorkOrder record {|
    string id?;
    string title;
    string description;
    string status; // open, in_progress, closed
    map<Task> tasks;
|};

type Asset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    string status;
    string acquiredDate;
    map<Component>   components;
    map<Maintenance> schedules;
    map<WorkOrder>   workOrders;
|};

// ---------- schedules helpers (dates + cadence) ----------

// quick sanity check for ISO "YYYY-MM-DD"
function isIsoDate(string d) returns boolean {
    // use substring(start, end) — indices [4:5] are invalid
    return d.length() == 10
        && d.substring(4, 5) == "-"
        && d.substring(7, 8) == "-";
}

// allowed cadence values (case-insensitive)
function isValidCadence(string s) returns boolean {
    string v = s.toLowerAscii().trim();
    return v == "weekly" || v == "monthly" || v == "quarterly" || v == "yearly";
}

// format YYYY-MM-DD with zero-padding
function fmtDate(int y, int m, int d) returns string {
    string mm = m < 10 ? "0" + m.toString() : m.toString();
    string dd = d < 10 ? "0" + d.toString() : d.toString();
    return y.toString() + "-" + mm + "-" + dd;
}

// add months (handles year rollover; clamps day to 28 to avoid invalid dates)
function addMonths(int y, int m, int add, int d) returns string {
    int total = (m - 1) + add;
    int ny = y + (total / 12);
    int nm = (total % 12) + 1;
    int nd = d > 28 ? 28 : d;
    return fmtDate(ny, nm, nd);
}

// compute the next due date from a current 'nextDueDate' and a cadence
function computeNextDue(string currentDue, string cadence) returns string {
    // if the date looks wrong, just echo back (keeps things robust)
    if !isIsoDate(currentDue) { return currentDue; }

    // split YYYY-MM-DD into ints
    int|error yi = int:fromString(currentDue.substring(0, 4));
    int|error mi = int:fromString(currentDue.substring(5, 7));
    int|error di = int:fromString(currentDue.substring(8, 10));
    if yi is error || mi is error || di is error { return currentDue; }
    int y = <int>yi; int m = <int>mi; int d = <int>di;

    string c = cadence.toLowerAscii().trim();
    if c == "monthly"   { return addMonths(y, m, 1,  d); }
    if c == "quarterly" { return addMonths(y, m, 3,  d); }
    if c == "yearly"    { return addMonths(y, m, 12, d); }

    // weekly via time: 7 days = 604800 seconds
    if c == "weekly" {
        time:Utc|time:Error base = time:utcFromString(currentDue + "T00:00:00Z");
        if base is time:Utc {
            time:Utc next = time:utcAddSeconds(base, <time:Seconds>604800);
            return next.toString().substring(0, 10);
        }
    }
    return currentDue;
}

// true if dueDate < today (both ISO strings), so it's overdue
function isOverdue(string dueDate, string today) returns boolean {
    return isIsoDate(dueDate) && isIsoDate(today) && (dueDate < today);
}

// safely turn string? into a non-null string
function getOrEmpty(string? s) returns string {
    return s is string ? s : "";
}

final map<Asset> database = {};

service /assets on new http:Listener(8080) {
    resource function post addAsset(@http:Payload Asset asset) returns http:Created|http:Conflict|http:BadRequest {
        // makin sure theres no missin anything still before addin an asset still
        if (asset.assetTag.trim().length() == 0) { return <http:BadRequest>{ body: { message:"asset tag is needed" } }; }
        if (asset.acquiredDate.trim().length() == 0) { return <http:BadRequest>{ body: { message:"acquired date is needed" } }; }
        if (asset.department.trim().length() == 0) { return <http:BadRequest>{ body: { message:"departmet is needed" } }; }
        if (asset.faculty.trim().length() == 0) { return <http:BadRequest>{ body: { message:"faculty is needed" } }; }
        if (asset.name.trim().length() == 0) { return <http:BadRequest>{ body: { message:"name is needed" } }; }
        if (asset.status.trim().length() == 0) { return <http:BadRequest>{ body: { message:"status is needed" } }; }
        if (database.hasKey(asset.assetTag)) { return <http:Conflict>{ body: { message: "asset wit this tag already exists" } }; } // checkin' if asset with that tag exists already still.

        // only allow working/not_working
        string st = asset.status.toLowerAscii().trim();
        if !(st == "working" || st == "not_working") {
            return <http:BadRequest>{ body:{ message:"asset status is not valid please enter working or not_working" } };
        }

        if (asset.components.length() == 0) { asset.components = {}; }
        if (asset.schedules.length()  == 0) { asset.schedules  = {}; }
        if (asset.workOrders.length() == 0) { asset.workOrders = {}; }

        //checkin' if asset with that tag exists already still.
        if (asset.status.toUpperAscii().trim() != "ACTIVE") && (asset.status.toUpperAscii().trim() != "UNDER_REPAIR") && (asset.status.toUpperAscii().trim() != "DISPOSED") {
            return <http:BadRequest>{body: {message: "asset status is not valid please enter ACTIVE, UNDER_REPAIR, or DISPOSED"}};
        }

        if (asset.components.length() == 0) {
            asset.components = {};
        }
        if (asset.schedules.length() == 0) {
            asset.schedules = {};
        }
        if (asset.workOrders.length() == 0) {
            asset.workOrders = {};
        }


        lock {
            database[asset.assetTag] = asset; // savin the asset to the database
            return <http:Created>{ body:{ message:"asset added", asset:asset.clone() } };
        }
    }

    // get a specific asset using its tag
    resource function get getAsset/[string assetTag]() returns json {
        Asset? asset = database[assetTag];
        if database.hasKey(assetTag) {
            return <json>asset;
        }
        return { message:"asset not found" };
    }

    resource function put updateAsset/[string assertTag](@http:Payload Asset updated) returns json {
        if database.hasKey(assertTag) {
            database[assertTag] = updated;
            return { message: "Aset updated", asset: <json>updated };
        }
        return { message: "Asset not found" };
    }

    resource function delete removeAsset/[string assertTag]() returns json {
        if database.hasKey(assertTag) {
            _ = database.remove(assertTag);
            return { message: "Asset deleted" };
        }
        return { message: "Asset not found" };
    }

    resource function post [string tag]/components(@http:Payload Component comp)
            returns http:Created|http:NotFound|http:Conflict|http:BadRequest {

        // checkin if required fields are actually provided
        if (comp.name.trim().length() == 0) { return <http:BadRequest>{ body:{ message:"name is needed" } }; }
        if (comp.status.trim().length() == 0) { return <http:BadRequest>{ body:{ message:"status is needed" } }; }
        // allow only OK/FAULTY/REPLACED
        string cs = comp.status.toUpperAscii().trim();
        if !(cs == "OK" || cs == "FAULTY" || cs == "REPLACED") {
            return <http:BadRequest>{ body:{ message:"component status is not valid please enter OK, FAULTY, or REPLACED" } };
        }

        // checkin if provided id is a string
        string newId = comp.id is string ? <string>comp.id : "";
        lock {
            Asset|() asset = database[tag];
            if asset == () { return <http:NotFound>{ body: { message: "asset not found" } }; }

            string cid;
            // if the serial number is there use it as a id because they are also unique because using uuid is too long so its the last option
            string serialSafe = getOrEmpty(comp.serial).trim();
            if serialSafe.length() > 0 {
                cid = newId.trim().length() > 0 ? newId.trim() : serialSafe;
            } else {
                cid = newId.trim().length() > 0 ? newId.trim() : uuid:createType4AsString();
            }

            if asset.components.hasKey(cid) { return <http:Conflict>{ body:{ message:"component with this id already exists" } }; }

            comp.id = cid;
            asset.components[cid] = comp.clone();
            database[tag] = asset; // savin the asset to the database

            return <http:Created>{ body: { message:"component added", assetTag: tag, component: comp.clone() } };
        }
    }

    resource function get [string tag]/components() returns http:Ok|http:NotFound {
        Asset|() a = database[tag];
        if a == () { return <http:NotFound>{ body: { message: "asset not found" } }; }

        Component[] components_array = [];
        foreach var [_, component] in a.components.entries() {
            components_array.push(component);
        }
        return <http:Ok>{ body: components_array.clone() };
    }

    resource function put [string tag]/components/[string compId](@http:Payload Component updated)
            returns http:Ok|http:NotFound|http:BadRequest {
        if (updated.name.trim().length() == 0) { return <http:BadRequest>{ body:{ message:"name is needed" } }; }
        if (updated.status.trim().length() == 0) { return <http:BadRequest>{ body:{ message:"status is needed" } }; }
        string cs = updated.status.toUpperAscii().trim();
        if !(cs == "OK" || cs == "FAULTY" || cs == "REPLACED") {
            return <http:BadRequest>{ body:{ message:"component status is not valid please enter OK, FAULTY, or REPLACED" } };
        }

        lock {
            Asset|() asset = database[tag];
            if (asset == ()) { return <http:NotFound>{ body:{ message:"asset not found" } }; }
            if !asset.components.hasKey(compId) {
                return <http:NotFound>{body: {message: "component not found"}};
            }
            updated.id = compId;
            asset.components[compId] = updated.clone();
            database[tag] = asset;
            return <http:Ok>{body: {message: "component updated", component: updated.clone()}};
        }
    }

    resource function delete [string tag]/components/[string compId]() returns http:Ok|http:NotFound {
        lock {
            Asset|() asset = database[tag];
            if (asset == ()) {
                return <http:NotFound>{body: {message: "asset not found"}};
            }
            if !asset.components.hasKey(compId) {
                return <http:NotFound>{body: {message: "component not found"}};
            }
            _ = asset.components.remove(compId);
            database[tag] = asset;
            return <http:Ok>{body: {message: "component deleted"}};
        }
    }

    resource function get faculty/[string faculty]() returns http:Ok {
        Asset[] results = []; // empty Array of Asset called results

        foreach var [_, asset] in database.entries() { // goes through the database which contains all assets
            // checks if the faculty is provided
            if faculty.trim() != "all" {
                // check if the current asset's faculty field matches the query parameter
                if asset.faculty == faculty {
                    results.push(asset.clone()); // adds a copy of the asset to the results array
                    // clone() is good practice to prevent accidental modification
                }
            } else {
                results.push(asset.clone()); // if the faculty provided is all it will return all assets
            }
        }
        return <http:Ok>{body: results}; // returns the error message with the results array
    }
       // created a new work order
    resource function post [string tag]/workorders(@http:Payload WorkOrder wo) returns http:Created|http:NotFound|http:BadRequest {
        if (wo.title.trim().length() == 0) {
            return <http:BadRequest>{body:{message:"title is needed"}};
        }
        if (wo.description.trim().length() == 0) {
            return <http:BadRequest>{body:{message:"description is needed"}};
        }
        // check if the status is allowed
        if (wo.status != "open" && wo.status != "in_progress" && wo.status != "closed") {
            return <http:BadRequest>{body:{message:"status must be open, in_progress, or closed"}};
        }

        Asset|() asset = database[tag];
        if (asset == ()) {
            return <http:NotFound>{body:{message:"asset not found"}};
        }
        // make a new ID for this work order
        string newId = "WO-" + asset.workOrders.length().toString();
        wo.id = newId;
        if (wo.tasks.length() == 0) {
            wo.tasks = {};
        }

        asset.workOrders[newId] = wo.clone();
        database[tag] = asset;

        return <http:Created>{body:{message:"work order added", workOrder: wo.clone()}};
    }

    // ===================== SCHEDULES =====================

    // add a maintenance schedule to an asset
    resource function post [string tag]/schedules(@http:Payload Maintenance sched)
            returns http:Created|http:NotFound|http:BadRequest|http:Conflict {

        // quick validations
        if sched.maintenanceType.trim().length() == 0 {
            return <http:BadRequest>{ body: { message: "maintenanceType is needed (weekly, monthly, quarterly, yearly)" } };
        }
        if !isValidCadence(sched.maintenanceType) {
            return <http:BadRequest>{ body: { message: "invalid maintenanceType; use weekly/monthly/quarterly/yearly" } };
        }
        if sched.nextDueDate.trim().length() == 0 || !isIsoDate(sched.nextDueDate) {
            return <http:BadRequest>{ body: { message: "nextDueDate must be YYYY-MM-DD" } };
        }
        if sched.status.trim().length() == 0 {
            return <http:BadRequest>{ body: { message: "status is needed" } };
        }

        lock {
            Asset|() asset = database[tag];
            if asset == () { return <http:NotFound>{ body: { message: "asset not found" } }; }

            // choose schedule id (provided or generated)
            string sid = sched.id is string && (<string>sched.id).trim().length() > 0
                ? (<string>sched.id).trim()
                : uuid:createType4AsString();

            if asset.schedules.hasKey(sid) {
                return <http:Conflict>{ body: { message: "schedule with this id already exists" } };
            }

            sched.id = sid;
            asset.schedules[sid] = sched.clone();
            database[tag] = asset;

            return <http:Created>{ body: { message: "schedule added", assetTag: tag, schedule: sched.clone() } };
        }
    }

    // list schedules for an asset
    resource function get [string tag]/schedules() returns http:Ok|http:NotFound {
        Asset|() a = database[tag];
        if a == () { return <http:NotFound>{ body: { message: "asset not found" } }; }
        Maintenance[] list = [];
        foreach var [_, sch] in a.schedules.entries() { list.push(sch); }
        return <http:Ok>{ body: list.clone() };
    }

    // update/replace a schedule (by id)
    resource function put [string tag]/schedules/[string schedId](@http:Payload Maintenance updated)
            returns http:Ok|http:NotFound|http:BadRequest {

        if updated.maintenanceType.trim().length() == 0 || !isValidCadence(updated.maintenanceType) {
            return <http:BadRequest>{ body: { message: "maintenanceType invalid (weekly/monthly/quarterly/yearly)" } };
        }
        if updated.nextDueDate.trim().length() == 0 || !isIsoDate(updated.nextDueDate) {
            return <http:BadRequest>{ body: { message: "nextDueDate must be YYYY-MM-DD" } };
        }
        if updated.status.trim().length() == 0 {
            return <http:BadRequest>{ body: { message: "status is needed" } };
        }

        lock {
            Asset|() asset = database[tag];
            if asset == () { return <http:NotFound>{ body: { message: "asset not found" } }; }
            if !asset.schedules.hasKey(schedId) { return <http:NotFound>{ body: { message: "schedule not found" } }; }

            updated.id = schedId;
            asset.schedules[schedId] = updated.clone();
            database[tag] = asset;
            return <http:Ok>{ body: { message: "schedule updated", schedule: updated.clone() } };
        }
    }

    // delete a schedule
    resource function delete [string tag]/schedules/[string schedId]()
            returns http:Ok|http:NotFound {
        lock {
            Asset|() asset = database[tag];
            if asset == () { return <http:NotFound>{ body: { message: "asset not found" } }; }
            if !asset.schedules.hasKey(schedId) { return <http:NotFound>{ body: { message: "schedule not found" } }; }
            _ = asset.schedules.remove(schedId);
            database[tag] = asset;
            return <http:Ok>{ body: { message: "schedule deleted" } };
        }
    }

    // mark a schedule done → auto-advance nextDueDate using its cadence
    // POST /assets/{tag}/schedules/{id}/advance
    resource function post [string tag]/schedules/[string schedId]/advance()
            returns http:Ok|http:NotFound {
        lock {
            Asset|() asset = database[tag];
            if asset == () { return <http:NotFound>{ body: { message: "asset not found" } }; }
            Maintenance|() sched = asset.schedules[schedId];
            if sched == () { return <http:NotFound>{ body: { message: "schedule not found" } }; }

            // compute the next nextDueDate from current one and cadence (weekly/monthly/quarterly/yearly)
            string newDue = computeNextDue(sched.nextDueDate, sched.maintenanceType);
            sched.nextDueDate = newDue;
            asset.schedules[schedId] = sched;
            database[tag] = asset;

            return <http:Ok>{ body: { message: "schedule advanced", schedule: sched.clone() } };
        }
    }

    // list all overdue schedules across all assets (today optional)
    // GET /assets/overdue_schedules?today=YYYY-MM-DD
    resource function get overdue_schedules(@http:Query string? today)
            returns http:Ok {
        // build today's ISO date (if not provided)
        time:Utc now = time:utcNow();
        string isoToday = (today is string && today.trim().length() == 10) ? today : now.toString().substring(0, 10);

        json[] out = [];
        foreach var [tag, a] in database.entries() {
            foreach var [sid, sch] in a.schedules.entries() {
                if isOverdue(sch.nextDueDate, isoToday) {
                    out.push({ assetTag: tag, scheduleId: sid, maintenanceType: sch.maintenanceType, nextDueDate: sch.nextDueDate });
                }
            }
        }
        return <http:Ok>{ body: out };
    }
}
