import ballerina/http;
import ballerina/io;
import ballerina/time;

public function main() returns error? {
    http:Client c = check new ("http://localhost:9091");

    // ---- Seed schedule
    json s1 = {
        id: "s1",
        assetTag: "EQ-001",
        cadence: "yearly",
        nextDue: "2025-02-01"
    };
    http:Response r1 = check c->post("/schedules", s1);
    io:println("CREATE:", check r1.getJsonPayload());

    // ---- Update schedule
    json s1u = {
        id: "s1",
        assetTag: "EQ-001",
        cadence: "yearly",
        nextDue: "2025-01-15"
    };
    http:Response r2 = check c->put("/schedules/s1", s1u);
    io:println("UPDATE:", check r2.getJsonPayload());

    // ---- List all
    http:Response r3 = check c->get("/schedules");
    io:println("ALL:", check r3.getJsonPayload());

    // ---- Filter by assetTag
    http:Response r4 = check c->get("/schedules?assetTag=EQ-001");
    io:println("BY ASSET:", check r4.getJsonPayload());

    // ---- Overdue (today = UTC yyyy-MM-dd)
    time:Utc now = time:utcNow();
    string today = now.toString().substring(0, 10);
    http:Response r5 = check c->get("/schedules/overdue?today=" + today);
    io:println("OVERDUE:", check r5.getJsonPayload());

    // ---- Delete
    http:Response r6 = check c->delete("/schedules/s1");
    io:println("DELETE:", check r6.getJsonPayload());
}
