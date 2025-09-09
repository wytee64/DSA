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
 {asset_id: 3,asset_name: "Computer",faculty: "Computer Science",status: "Maintainance"},
 {asset_id: 4,asset_name: "Camera",faculty: "Journalism",status: "In use"}

  ];
  //its readonly because the assets are fixed and cant be changed after creation basically immutabe
   //stated Final to prevent reassginment of the variable Asset again


service /assets on new //listens to requests made to path assets THE HTTP BELOW TELLS THE PATH TO LISTEN TO PORT 9090 NO OTHER PORT
http:Listener(9090) {

isolated resource function get .(@http:Query string? faculty) returns  http:Response|Asset[] {
  Asset[] result = faculty is string? assets.filter(asset => asset.faculty == faculty)
  : assets;

  if faculty is string && result.length()==0 {
    http:Response res=new;
    res.statusCode=404;
    res.setPayload({"message": "No assets found for faculty ", faculty});
    return res;
  }
}

  

}

//i think that clears it all

