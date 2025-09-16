import ballerina/http;
import ballerina/uuid;

type Component record {|
    string id?;
    string name;
    string? serial;
    string status; // OK, FAULTY, REPLACED
|};

type Maintenance record {|
    string id?;
    string maintenanceType;   // weekly,monthly,yearly
    string nextDueDate;      //year then month then date
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
    map<Component> components;
    map<Maintenance> schedules;
    map<WorkOrder> workOrders;
|};

final map<Asset> database = {};

service /assets on new http:Listener(8080) {
    resource function post addAsset(@http:Payload Asset asset) returns http:Created|http:Conflict|http:BadRequest {
        //makin sure theres no missin anything still before addin an asset still
        if (asset.assetTag.trim().length() == 0){return <http:BadRequest>{ body: { message:"asset tag is needed" } };}
        if (asset.acquiredDate.trim().length() == 0) {return <http:BadRequest>{ body: { message:"acquired date is needed" } };}
        if (asset.department.trim().length() == 0) {return <http:BadRequest>{ body: { message:"departmet is needed" } };}
        if (asset.faculty.trim().length() == 0) {return <http:BadRequest>{ body: { message:"faculty is needed" } };}
        if (asset.name.trim().length() == 0) {return <http:BadRequest>{ body: { message:"name is needed" } };}
        if (asset.status.trim().length() == 0) {return <http:BadRequest>{ body: { message:"status is needed" } };}
        if (database.hasKey(asset.assetTag)) {return <http:Conflict>{ body: { message: "asset wit this tag already exists" } };} //checkin' if asset with that tag exists already still.
        if (asset.status.toLowerAscii().trim() != "working") || (asset.status.toLowerAscii().trim() !="not_working")  { return <http:BadRequest>{body:{message:"asset status is not valid please enter working or not_working"}};}
        
        if (asset.components.length() == 0) {asset.components = {};}
        if (asset.schedules.length() == 0) {asset.schedules = {};}
        if (asset.workOrders.length() == 0) {asset.workOrders = {};}

        lock {
            database[asset.assetTag] = asset; //savin the asset to the database
            return <http:Created>{body:{message:"asset added", asset:asset.clone()}};
        }
    }

    //get a specific asset using its tag
    resource function get getAsset/[string assetTag]() returns json {
        Asset? asset = database[assetTag];
        if database.hasKey(assetTag) {
            return<json>asset;
        }
        return {message:"asset not found"};       
    }

    resource function put updateAsset/[string assertTag](@http:Payload Asset updated) returns json{
        if database.hasKey(assertTag){
            database[assertTag]=updated;
            return{message: "Aset updated", asset: <json>updated};
        }
    }

    resource function delete removeAsset/[string assertTag]() returns json{
        if database.hasKey(assertTag){
            _ = database.remove(assertTag);
            return{message: "Asset deleted"};
        }
        return {massage: "Asset not found"};
    }

    resource function post [string tag]/components(@http:Payload Component comp) returns http:Created|http:NotFound|http:Conflict|http:BadRequest {

        //checkin if required fields are actually provided
        if (comp.name.trim().length() ==0) {return <http:BadRequest>{body:{message:"name is needed"}};}
        if (comp.status.trim().length()== 0 ) {return <http:BadRequest>{body:{message:"status is needed"}};}
        if (comp.status.toUpperAscii().trim() != "OK") || (comp.status.toUpperAscii().trim() != "FAULTY") || (comp.status.toUpperAscii().trim() != "REPLACED") { return <http:BadRequest>{body:{message:"component status is not valid please enter OK, FAULTY, or REPLACED"}};}

        //checkin if provided id is a string
        string newId = comp.id is string ? <string>comp.id : "";
        lock {
            Asset|() asset = database[tag];
            if asset ==() {return <http:NotFound>{ body: { message: "asset not found" } };}

            string cid;
            //if the serial number is there use it as a id because they are also unique because using uuid is too long so its the last option
            if comp.serial.clone().toString().length() > 0{cid = newId.trim().length() > 0 ? newId.trim() : comp.serial.clone().toString();}
            else {cid = newId.trim().length() > 0 ? newId.trim() : uuid:createType4AsString();}

            if asset.components.hasKey(cid) {return <http:Conflict>{body:{message:"component with this id already exists"}};}

            comp.id = cid; 
            asset.components[cid] = comp.clone();
            database[tag] = asset; //savin the asset to the database

            return <http:Created>{body: {message:"component added", assetTag: tag, component: comp.clone() }};
        }
    }

    resource function get [string tag]/components() returns http:Ok|http:NotFound {
        Asset|() a = database[tag];
        if a == () {return <http:NotFound>{body: {message: "asset not found"}};}
        
        Component[] components_array = [];
        foreach var [_, component] in a.components.entries() {
            components_array.push(component);
        }
        return <http:Ok>{ body: components_array.clone()};
    }


    resource function put [string tag]/components/[string compId](@http:Payload Component updated) returns http:Ok|http:NotFound|http:BadRequest {
        if (updated.name.trim().length() ==0) {return <http:BadRequest>{body:{message:"name is needed"}};}
        if (updated.status.trim().length()== 0 ) {return <http:BadRequest>{body:{message:"status is needed"}};}
        if (updated.status.toUpperAscii().trim() != "OK") || (updated.status.toUpperAscii().trim() != "FAULTY") || (updated.status.toUpperAscii().trim() != "REPLACED") { return <http:BadRequest>{body:{message:"component status is not valid please enter OK, FAULTY, or REPLACED"}};}

        
        lock {
            Asset|() asset = database[tag];
            if (asset == ()) {return <http:NotFound>{body:{message:"asset not found"}};}
            if !asset.components.hasKey(compId) {
                return <http:NotFound>{ body: { message: "component not found" } };
            }
            updated.id = compId;
            asset.components[compId] = updated.clone();
            database[tag] = asset;
            return <http:Ok>{ body: { message: "component updated", component: updated.clone() } };
        }
    }

    resource function delete [string tag]/components/[string compId]() returns http:Ok|http:NotFound {
        lock {
            Asset|() asset = database[tag];
            if (asset == ()) {
                return <http:NotFound>{ body: { message: "asset not found" } };
            }
            if !asset.components.hasKey(compId) {
                return <http:NotFound>{ body: { message: "component not found" } };
            }
            _ = asset.components.remove(compId);
            database[tag] = asset;
            return <http:Ok>{ body: { message: "component deleted" } };
        }
    }
    resource function get faculty/[string faculty]() returns http:Ok {

        Asset[] results = []; // empty Array of Asset called results

        foreach var [_, asset] in database.entries() { // goes through the database which contains all assets 
        // and then database.entries returns a list of turples string,Asset 
        //where assetTag is the key for asset and asset is the value for Asset Record

            // checks if the faculty is provided
            if faculty.trim() != "all" {

            // check if the current asset's faculty field matches the query parameter
                if asset.faculty == faculty {

                    results.push(asset.clone()); // adds a copy of the asset to the results array
                    // clone() is good practice to prevent accidental modification

                }
            } 
            
            else {
                results.push(asset.clone()); // if the faculty provided is all it will return all assets
            }
        }
        return <http:Ok>{ body: results }; // returns the error message with the results array
    }

}
