import ballerina/http;


service /filter on new http:Listener(9090) {

<<<<<<< HEAD
    resource function get .(@http:Query string? faculty) returns http:Ok {

        Asset[] results = [];

        foreach var [assetTag, asset] in database.entries() {


            if faculty is string {

            
                if asset.faculty == faculty {

                    results.push(asset.clone());

                }
            } 
            
            else {
        results.push(asset.clone());
            }
        }
 return <http:Ok>{ body: results };
    }
}
=======
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

>>>>>>> 5a339b23c0300d75c2d503a52173b42a64764ca2
