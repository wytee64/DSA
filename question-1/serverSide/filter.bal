import ballerina/http;

type Component record {| 
    string id?;
    string name;
    string? serial;
    string status = "OK"; 
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

Asset[] asset = [];

service /asset on new http:Listener(9090) {

    resource function get .(@http:Query string? faculty) returns Asset[]|http:Response {
         if faculty is string {
            Asset[] filtered = [];
            foreach var asset in asset {
                if asset.faculty == faculty {
                    filtered.push(asset);
                }
            }
            return filtered;
         }
         return asset;
    }

    resource function  get [string assetTag]() returns Asset|http:Response {

        foreach var asset in asset {
            if asset.assetTag == assetTag {
                return asset;
            }
            
        }


        http:Response resp = new;
        resp.statusCode = 404;
        resp.setPayload({"Error": "Asset not found" });
        return resp;
        
    }

    resource  function get [string assetTag]/components() returns map<Component>|http:Response {
        foreach var asset in asset {
            if asset.assetTag == assetTag {
                return asset.components;
            }
            
        }
        http:Response resp = new;
            resp.statusCode = 404;
            resp.setPayload({"Error:": "Asset not found"});
            return resp;
    }
    resource function post .(@http:Payload Asset newAsset) returns http:Response {
        
        asset.push(newAsset);
        http:Response resp = new;
        resp.statusCode = 404;
        resp.setPayload(newAsset);
        return resp;
        
    }

    resource function put [string assetTag](@http:Payload Asset updatedAsset) returns http:Response {
        foreach var i in 0 ..< asset.length() {
if asset[i].assetTag == assetTag{
    asset[i] = updatedAsset;
    http:Response resp = new;
    resp.statusCode =  404;
    resp.setJsonPayload(updatedAsset);
    return resp;
        }
        
    }
    http:Response resp = new;
    resp.statusCode = 404;
    resp.setJsonPayload({"Error": "Asset not found"});
    return resp;
    }

    resource function delete [string assetTag]() returns http:Response{
        Asset[] remaining  = [];
        boolean found = false;
        foreach  var asset in asset {
            if asset.assetTag == assetTag{
                found =  true;
                continue;
            }
            remaining.push(asset);
            
        }
        asset = remaining;

        http:Response resp = new;
        if found {
            resp.statusCode =204;
        }
        else {
            resp.statusCode = 404;
            resp.setJsonPayload ({ "Error": "Asset not found"});
    
        }
        return resp;
        
    }

    
}


