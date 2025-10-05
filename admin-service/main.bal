import ballerina/http;

// Admin record
type Admin record {|
    int id;
    string name;
    string email;
    string role; // e.g., "SystemAdmin" or "TicketManager"
|};

// In-memory store
map<Admin> admins = {};

// HTTP Service
service /admin on new http:Listener(8082) {

    // Register a new admin
    resource function post register(@http:Payload Admin newAdmin) returns json {
        if admins.hasKey(newAdmin.id.toString()) {
            return { message: "Admin with ID " + newAdmin.id.toString() + " already exists." };
        }
        admins[newAdmin.id.toString()] = newAdmin;
        return { message: "Admin registered successfully!", admin: newAdmin };
    }

    // Get admin by ID
    resource function get [int id]() returns json {
        Admin? a = admins[id.toString()];
        if a is Admin {
            return { admin: a };
        } else {
            return { message: "Admin not found." };
        }
    }

    // Get all admins
    resource function get list() returns json {
        Admin[] allAdmins = [];
        foreach var key in admins.keys() {
            Admin? a = admins[key];
            if a is Admin {
                allAdmins.push(a);
            }
        }
        return { admins: allAdmins };
    }
}
