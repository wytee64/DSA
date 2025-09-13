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

final map<Asset> database = {};

service /assets on new http:Listener(9090) {
// the one below i used a query which accepts a optinal parameter which will either return the array or http response(error)
    resource function get .(@http:Query string? faculty) returns http:Ok {
      Asset[] results = [];

      foreach [string key, Asset asset] in database.entries() {
        if faculty is string {
            if asset.faculty == faculty {
                results.push(asset.clone());
            }
        }
        else {
            results.push(asset.clone());
        }
      }  return <http:Ok>{ body: results };
     
}


}

