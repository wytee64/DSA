import ballerina/http;

// creates a service on port 9090
service /filter on new http:Listener(9090) {

//creates a optinal parameter query names faculty, the ? means it can be null if not provided which will return HTTP 200 OK response (http:Ok) containing a body of the error lmao
    resource function get .(@http:Query string? faculty) returns http:Ok {

        Asset[] results = []; // empty Array of Asset called results

        foreach var [assetTag, asset] in database.entries() { // goes through the database which contains all assets 
        // and then database.entries returns a list of turples string,Asset 
        //where assetTag is the key for asset and asset is the value for Asset Record

// checks if the faculty is provided
            if faculty is string {

            // check if the current asset's faculty field matches the query parameter
                if asset.faculty == faculty {

                    results.push(asset.clone()); // adds a copy of the asset to the results array
                    // clone() is good practice to prevent accidental modification

                }
            } 
            
            else {
        results.push(asset.clone()); // if the faculty is not provided it will return all assets
            }
        }
 return <http:Ok>{ body: results }; // returns the error message with the results array
    }
}
