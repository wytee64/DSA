import ballerina/http;
import ballerina/time;

// ---------- Domain ----------
type Schedule record {|
    string id;           // primary key
    string assetTag;     // which asset this schedule belongs to
    string cadence;      // e.g., "quarterly", "yearly"
    string nextDue;      // YYYY-MM-DD
|};

// In-memory DB keyed by id
map<Schedule> sdb = {};

// ---------- Helpers ----------
function todayStr() returns string {
    time:Utc now = time:utcNow();
    string iso = now.toString();         // e.g., 2025-09-17T10:22:33Z
    return iso.substring(0, 10);         // "2025-09-17"
}
function ltDate(string a, string b) returns boolean {
    return a < b; // ISO YYYY-MM-DD compares lexicographically
}

// ---------- Service ----------
@http:ServiceConfig {
    cors: { allowOrigins:["*"], allowMethods:["GET","POST","PUT","DELETE"], allowHeaders:["content-type"] }
}
service / on new http:Listener(9091) {

    // Create schedule
    resource function post schedules(@http:Payload Schedule s) returns http:Created|http:Conflict {
        if sdb.hasKey(s.id) { return <http:Conflict>{ body: { message: "schedule exists" } }; }
        sdb[s.id] = s;
        return <http:Created>{ body: s };
    }

    // List all or filter: GET /schedules?assetTag=EQ-001&cadence=yearly
    resource function get schedules(@http:Query string? assetTag, @http:Query string? cadence)
            returns Schedule[] {
        Schedule[] out = [];
        foreach string k in sdb.keys() {
            Schedule? v = sdb[k];
            if v is Schedule {
                boolean ok = true;
                if assetTag is string { ok = ok && v.assetTag == assetTag; }
                if cadence  is string { ok = ok && v.cadence  == cadence; }
                if ok { out.push(v); }
            }
        }
        return out;
    }

    // Get by id
    resource function get schedules/[string id]() returns Schedule|http:NotFound {
        Schedule? s = sdb[id];
        if s is () { return <http:NotFound>{ body: { message: "not found" } }; }
        return s;
    }

    // Update by id
    resource function put schedules/[string id](@http:Payload Schedule body)
            returns Schedule|http:NotFound {
        if !sdb.hasKey(id) { return <http:NotFound>{ body: { message: "not found" } }; }
        body.id = id;
        sdb[id] = body;
        return body;
    }

    // Delete by id
    resource function delete schedules/[string id]() returns json|http:NotFound {
        if !sdb.hasKey(id) { return <http:NotFound>{ body: { message: "not found" } }; }
        _ = sdb.remove(id);
        return { message: "deleted" };
    }

    // Overdue schedules: GET /schedules/overdue?today=YYYY-MM-DD
    resource function get schedules/overdue(@http:Query string? today)
            returns Schedule[] {
        string t = (today is string && today.length() > 0) ? today : todayStr();
        Schedule[] out = [];
        foreach string k in sdb.keys() {
            Schedule? s = sdb[k];
            if s is Schedule {
                if ltDate(s.nextDue, t) { out.push(s); }
            }
        }
        return out;
    }
}
