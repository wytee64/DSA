import ballerina/http;
import ballerina/io;
import ballerina/time;

public function main() returns error? {
    http:Client c = check new ("http://localhost:9090");

    // ---- Add asset
    json a = {
        assetTag: "EQ-001",
        name: "3D Printer",
        faculty: "Computing & Informatics",
        department: "Software Engineering",
        status: "ACTIVE",
        acquiredDate: "2024-03-10",
        components: [],
        schedules: [{ id: "s1", cadence: "quarterly", nextDue: "2025-04-01" }],
        workOrders: []
    };
    http:Response r1 = check c->post("/assets", a);
    io:println("CREATE:", check r1.getJsonPayload());

    // ---- Update (use a fresh JSON literal)
    json u = {
        assetTag: "EQ-001",
        name: "3D Printer (Lab A)",
        faculty: "Computing & Informatics",
        department: "Software Engineering",
        status: "ACTIVE",
        acquiredDate: "2024-03-10",
        components: [],
        schedules: [{ id: "s1", cadence: "quarterly", nextDue: "2025-04-01" }],
        workOrders: []
    };
    http:Response r2 = check c->put("/assets/EQ-001", u);
    io:println("UPDATE:", check r2.getJsonPayload());

    // ---- List all
    http:Response r3 = check c->get("/assets");
    io:println("ALL:", check r3.getJsonPayload());

    // ---- By faculty
    http:Response r4 = check c->get("/assets?faculty=Computing%20%26%20Informatics");
    io:println("FACULTY:", check r4.getJsonPayload());

    // ---- Overdue (today = UTC YYYY-MM-DD)
    time:Utc now = time:utcNow();
    string today = now.toString().substring(0, 10);
    // Either concat...
    http:Response r5 = check c->get("/assets/overdue?today=" + today);
    // ...or use interpolation: http:Response r5 = check c->get(string /assets/overdue?today=${today});
    io:println("OVERDUE:", check r5.getJsonPayload());

    // ---- Add a component
    json comp = { id: "c1", name: "Extruder Motor" };
    http:Response r6 = check c->post("/assets/EQ-001/components", comp);
    io:println("ADD COMPONENT:", check r6.getJsonPayload());
}