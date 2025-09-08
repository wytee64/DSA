import ballerina/http;
import ballerina/uuid;


type Component record {|
    string id?;
    string name;
    string? serial;
    string status = "OK";  // "OK", "FAULTY", "REPLACED"
|};

// For testing still
type Asset record {|
    map<Component> components;
|};
isolated final map<Asset> DB = {};

service /assets on new http:Listener(9090) {
    
    // adding a component to an asset
    resource function post [string tag]/components(@http:Payload Component comp) returns http:Created|http:NotFound|http:Conflict|http:BadRequest {
        
        if comp.name.trim().length() == 0 || comp.status.trim().length() == 0{
            return <http:BadRequest>{body:{message: "name and status are required"}};
        }

        //because the trimming thing below didnt wanna work because its in the lock do im doin the validation outside
        string newId = comp.id is string ? <string>comp.id : ""; 

        lock {
            Asset|() asset = DB[tag];  

            if asset is () {
                return <http:NotFound>{body:{message:"asset not found"}};
            }

            // makin sure the component has a unique id else give it one
            string cid = newId.trim().length() > 0 ? newId.trim() : uuid:createType4AsString(); 

            if asset.components.hasKey(cid) {
                return <http:Conflict>{body: { message: "Component id already exists"}};
            }

            // addin the component into the asset with the id after making sure it doesnt exist
            comp.id = cid;
            asset.components[cid] = comp.clone();
            DB[tag] = asset;


            return <http:Created>{ body: { message: "Component added", assetTag: tag, component: comp.clone() } };
        }

    }
}