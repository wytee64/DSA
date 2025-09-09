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

final Asset[] & readonly assets = [
    {
        assetTag: "AST-001",
        name: "Desktop A",
        faculty: "Science",
        department: "Physics",
        status: "Active",
        acquiredDate: "2023-01-10",
        components: {
            "comp1": {id: "C-001", name: "CPU", serial: "SN12345"},
            "comp2": {id: "C-002", name: "Monitor", serial: "SN67890"}
        }
    },
    {
        assetTag: "AST-002",
        name: "Camera",
        faculty: "Journalism",
        department: "Media",
        status: "In use",
        acquiredDate: "2022-05-15",
        components: {
            "comp1": {id: "C-003", name: "Lens", serial: "LNS98765", status: "FAULTY"},
            "comp2": {id: "C-004", name: "Tripod", serial: "TR1234"}
        }
    },

    {
        assetTag: "AST-003",
        name: "Desktop B",
        faculty: "Education",
        department: "Mathematics",
        status: "Not in use",
        acquiredDate: "2021-08-28",
        components: {
            "comp1": {id: "C-005", name: "Keyboard", serial: "KB123"},
            "comp2": {id: "C-006", name: "Mouse", serial: "MS456"}
        }
    }
];


service /assets on new http:Listener(9090) {

    isolated resource function get .(@http:Query string? faculty) 
        returns http:Response|Asset[] {

        Asset[] result = faculty is string
            ? assets.filter(asset => asset.faculty == faculty)
            : assets;

        if faculty is string && result.length() == 0 {
            http:Response res = new;
            res.statusCode = 404;
            res.setPayload({message: "No assets found for faculty ", faculty});
            return res;
        }

        return result;
    }

isolated resource function get [string assetTag]() 
        returns http:Response|Asset {

    Asset[] matches = assets.filter(a => a.assetTag == assetTag);

    if matches.length() > 0 {
        return matches[0];
    } else {
        http:Response res = new;
        res.statusCode = 404;
        res.setPayload({message: "Asset with tag " + assetTag + " not found"});
        return res;
    }
}

isolated resource function get [string assetTag]/components() 
        returns http:Response|map<Component> {

    Asset[] matches = assets.filter(a => a.assetTag == assetTag);

    if matches.length() > 0 {
        return matches[0].components;
    } else {
        http:Response res = new;
        res.statusCode = 404;
        res.setPayload({message: "Asset with tag " + assetTag + " not found"});
        return res;
    }
        }
}
