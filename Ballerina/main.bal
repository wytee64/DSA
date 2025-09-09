import ballerina/io;

public function main() {
    string city = "Paris";
    int year = 2025;

    io:println("i live in " + city + " in " + year.toString());
}
