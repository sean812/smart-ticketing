import ballerina/http;

// Passenger record
type Passenger record {|
    int id;
    string name;
    string email;
    string password;
|};

// In-memory "database"
map<Passenger> passengers = {};

// Service for managing passengers
service /passenger on new http:Listener(8080) {

    // Register a passenger
    resource function post register(@http:Payload json regReq) returns json {
        // Convert incoming JSON directly into Passenger type
        Passenger|error newPassenger = regReq.fromJsonWithType(Passenger);

        if newPassenger is Passenger {
            if passengers.hasKey(newPassenger.id.toString()) {
                return { message: "Passenger with ID " + newPassenger.id.toString() + " already exists." };
            }
            passengers[newPassenger.id.toString()] = newPassenger;
            return { message: "Passenger registered successfully!", passenger: newPassenger };
        } else {
            return { message: "Invalid registration data." };
        }
    }

    // Login passenger
    resource function post login(@http:Payload json loginReq) returns json {
        int|error idVal = loginReq.id.ensureType(int);
        string|error passVal = loginReq.password.ensureType(string);

        if idVal is int && passVal is string {
            Passenger? p = passengers[idVal.toString()];
            if p is Passenger && p.password == passVal {
                return { message: "Login successful!", passenger: p };
            }
        }
        return { message: "Invalid ID or password." };
    }

    // Get passenger by ID
    resource function get [int id]() returns json {
        Passenger? p = passengers[id.toString()];
        if p is Passenger {
            return p;
        } else {
            return { message: "Passenger not found." };
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
    resource function delete [int id]() returns json {
        if passengers.hasKey(id.toString()) {
            _ = passengers.remove(id.toString());
            return { message: "Passenger deleted successfully." };
        } else {
            return { message: "Passenger not found." };
        }
    }
}


