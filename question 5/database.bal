import ballerina/http;

type Asset record {
    string assetTag;
    string name;
    string faculti;
    string department;
    string status;
    string acquiredDate;
};

map<Asset> assets = {};

service /assets on new http:Listener(8080) {
    resource function post addAsset(@http:Payload Asset asset) returns json {
        if assets.hasKey(asset.assetTag) {
            return { message: "Asset already exists" };
        }
        assets[asset.assetTag] = asset;
        return { message: "Asset added", asset: <json>asset };
    }

    resource function get getAsset(string assetTag) returns json{
        Asset? asset = assets[assetTag];
        if assets.hasKey(assetTag){
            return <json>asset;
        }
        return{message:"Asset not found"};
    }

    resource function put updateAsset(string assertTag, @http:Payload Asset updated) returns json{
        if assets.hasKey(assertTag){
            assets[assertTag]=updated;
            return{message: "Aset updated", asset: <json>updated};
        }
    }
    resource function delete removeAsset(string assertTag) returns json{
        if assets.hasKey(assertTag){
            Asset remove = assets.remove(assertTag);
            return{message: "Asset deleted"};
        }
        return {massage: "Asset not found"};
    }
    
}
