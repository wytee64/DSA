import ballerina/http;

type Asset record {
   int asset_id;
   string asset_name;
   string faculty;
   string status;
};
// {} for flexiblity and easier consuption of data that is unpredictable e.g dynamic json


final Asset[] & readonly assets = [
  {asset_id: 1,asset_name: "Desktop A",faculty: "Science",status: "Active"}, {asset_id: 2, asset_name: "Desktop B",faculty: "Education",status: "Not in use"},
 {asset_id: 2,asset_name: "Computer",faculty: "Computer Science",status: "Maintance"},
 {asset_id: 4,asset_name: "Camera",faculty: "Journalism",status: "In use"}

  ];
  //its readonly because the assets are fixed and cant be changed after creation basically immutabe
   //stated Final to prevent reassginment of the variable Asset again


service /assets on new //listens to requests made to path assets THE HTTP BELOW TELLS THE PATH TO LISTEN TO PORT 9090 NO OTHER PORT
http:Listener(9090) {

isolated resource function get .(@http:Query // THE GET   handles the get requets the . reposnds directly to /assets
  string?faculty) returns Asset[] { //@http:Q string?faculty tells Bal to look for the paramater "faculty" in the url and "String?" the ? means its optional if the parameter is not there it will be NULL
    Asset[] filteredAssets = [];

    if faculty is string {
      foreach var asset in assets {
        if asset.faculty == faculty{
          filteredAssets.push(asset);
        }
      }
      return filteredAssets;
    } 
   return assets; // if the parameter faculty is not provided it will just show all the assets so yeahh
  }
  
}

//i think that clears it all

