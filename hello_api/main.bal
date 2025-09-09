import ballerina/http;

type Asset record {
   int asset_id;
   string asset_name;
   string faculty;
   string status;
};

final Asset[] & readonly assets = [
  {asset_id: 1,asset_name: "Desktop A",faculty: "Science",status: "Active"}, {asset_id: 2, asset_name: "Desktop B",faculty: "Education",status: "Not in use"},
 {asset_id: 2,asset_name: "Computer",faculty: "Computer Science",status: "Maintance"},
 {asset_id: 4,asset_name: "Camera",faculty: "Journalism",status: "In use"}

                  ];

service /assets on new 
http:Listener(9090) {

isolated resource function get .(@http:Query
  string?faculty) returns Asset[] {
    Asset[] filteredAssets = [];

    if faculty is string {
      foreach var asset in assets {
        if asset.faculty == faculty{
          filteredAssets.push(asset);
        }
      }
      return filteredAssets;
    } 
   return assets;
  }
  
}


