import ballerina/http;


service /filter on new http:Listener(9090) {

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
