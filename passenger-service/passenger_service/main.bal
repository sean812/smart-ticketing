import ballerina/http;

// Passenger record
type Passenger record {|
    int id;
    string name;
    string email;
|};

// In-memory "database"
map<Passenger> passengers = {};

// Service for managing passengers
service /passenger on new http:Listener(8080) {

    // Add a passenger
    resource function post register(@http:Payload Passenger newPassenger) returns string {
        if passengers.hasKey(newPassenger.id.toString()) {
            return "Passenger with ID " + newPassenger.id.toString() + " already exists.";
        }
        passengers[newPassenger.id.toString()] = newPassenger;
        return "Passenger registered successfully!";
    }

    // Get passenger by ID
    resource function get [int id]() returns Passenger|http:NotFound {
        Passenger? p = passengers[id.toString()];
        if p is Passenger {
            return p;
        } else {
            return http:NOT_FOUND;
        }
    }

    // Get all passengers
    resource function get list() returns Passenger[] {
        Passenger[] result = [];
        foreach var key in passengers.keys() {
            Passenger? p = passengers[key];
            if p is Passenger {
                result.push(p);
            }
        }
        return result;
    }

    // Delete passenger
    resource function delete [int id]() returns string {
        if passengers.hasKey(id.toString()) {
            _ = passengers.remove(id.toString());
            return "Passenger deleted successfully.";
        } else {
            return "Passenger not found.";
        }
    }
}
