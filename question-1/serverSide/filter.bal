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

Asset[] assets = []; // declaring an empty arry, every asset created or updated will be stored here

service /assets on new http:Listener(9090) {
// the one below i used a query which accepts a optinal parameter which will either return the array or http response(error)
    resource function get .(@http:Query string? faculty) returns Asset[] {
         if faculty is string {
            Asset[] filtered = []; // this is creating an empty array called filtered when the faculty para is provided
            foreach var asset in assets {
                if asset.faculty == faculty { // looops through all the assets to look for the asset attached to that faculty
                    filtered.push(asset); // now if a asset is matched that is attched to the faculty its added to the array called filtered
                }
            }
            return filtered; // return only filtered assets to the client 
         }
         return assets; // if no faculty was given all the assets return
    } 
// here we gettting asset by tag
    resource function  get [string assetTag]() returns Asset|http:Response {
// as always we loop through all assets
        foreach var asset in assets {
            if asset.assetTag == assetTag {
                return asset;
            }
            
        }

// if no asset found it return the error below to the client side 
        http:Response resp = new;
        resp.statusCode = 404;
        resp.setPayload({"Error": "Asset not found" });
        return resp;
        
    }
// here we are returning the componets 
    resource  function get [string assetTag]/components() returns map<Component>|http:Response {
        foreach var asset in assets {
            if asset.assetTag == assetTag {
                return asset.components;
            }
            // if the asset tag match return asset's componets if not return thr error message!!
        }
        http:Response resp = new;
            resp.statusCode = 404;
            resp.setPayload({"Error:": "Asset not found"});
            return resp;
    }
    
}


