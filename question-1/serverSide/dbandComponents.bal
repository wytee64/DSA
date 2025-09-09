import ballerina/http;
import ballerina/uuid;

type Component record {|
    string id?;
    string name;
    string? serial;
    string status = "OK"; // "OK", "FAULTY", "REPLACED"
|};

type Asset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    string status;
    string acquiredDate;
    map<Component> components;
|};

final map<Asset> database = {};

service /assets on new http:Listener(8080) {
resource function post addAsset(@http:Payload Asset asset) returns http:Created|http:Conflict|http:BadRequest {

    if asset.assetTag.trim().length() == 0 {return <http:BadRequest>{ body: { message:"asset tag is needed" } };}
    if database.hasKey(asset.assetTag) {return <http:Conflict>{ body: { message: "asset already exists" } };}
    if asset.components.length() == 0 {asset.components = {};}
    
    database[asset.assetTag] = asset; //savin the asset to the database
    return <http:Created>{ body: { message: "asset added", asset: asset.clone() } };
}


    resource function get [string assetTag]() returns http:Ok|http:NotFound {
        //tryin to get asset usin tag
        Asset|() asset = database[assetTag];
        if asset is () {return <http:NotFound>{ body: { message: "asset not found" } };}//check if it exists        
        return <http:Ok>{ body: asset.clone() }; // returning it if it does exist still
    }

    resource function delete [string assetTag]()
        returns http:Ok|http:NotFound {
        if !database.hasKey(assetTag) {
            return <http:NotFound>{body:{message:"asset not found"}};
        }
        _ = database.remove(assetTag);
        return <http:Ok>{ body: { message: "asset deleted" } };
    }

    resource function post [string tag]/components(@http:Payload Component comp) returns http:Created|http:NotFound|http:Conflict|http:BadRequest {

        //checkin if required fields are actually provided
        if (comp.name.trim().length() == 0) {return <http:BadRequest>{body:{message:"name is needed"}};}
        else if (comp.status.trim().length()== 0) {
            return <http:BadRequest>{body:{message:"status is needed"}};
        }

        //checkin if provided id is a string
        string newId = comp.id is string ? <string>comp.id : "";

        lock {
            Asset|() asset = database[tag];
            if asset ==() {return <http:NotFound>{ body: { message: "asset not found" } };}

            string cid = newId.trim().length() > 0 ? newId.trim() : uuid:createType4AsString();

            if asset.components.hasKey(cid) {return <http:Conflict>{body:{message:"component with this id already exists"}};}

            comp.id = cid;
            asset.components[cid] = comp.clone();
            database[tag] = asset; //savin the asset to the database

            return <http:Created>{body: {message:"component added", assetTag: tag, component: comp.clone() }};
        }
    }

    resource function get [string tag]/components() returns http:Ok|http:NotFound {
        lock {
            Asset|() a = database[tag];
            if a is () {
                return <http:NotFound>{body: {message: "asset not found"}};
            }
            Component[] components_array = [];
            foreach var [_, component] in a.components.entries() {
                components_array.push(component);
            }
            return <http:Ok>{ body: components_array.clone()};
        }
    }

    resource function put [string tag]/components/[string compId](@http:Payload Component updated)
        returns http:Ok|http:NotFound {
        lock {
            Asset|() asset = database[tag];
            if asset is () {
                return <http:NotFound>{ body: { message: "asset not found" } };
            }
            if !asset.components.hasKey(compId) {
                return <http:NotFound>{ body: { message: "component not found" } };
            }
            updated.id = compId;
            asset.components[compId] = updated.clone();
            database[tag] = asset;
            return <http:Ok>{ body: { message: "component updated", component: updated.clone() } };
        }
    }

    resource function delete [string tag]/components/[string compId]() 
        returns http:Ok|http:NotFound {
        lock {
            Asset|() asset = database[tag];
            if asset is () {
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
}
