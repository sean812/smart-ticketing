import ballerina/http;

// Ticket record
public type Ticket record {|
    int id;
    int passengerId;
    string ticketType; // single, multiple, pass
    string status; // CREATED, PAID, VALIDATED, EXPIRED
|};

// In-memory "database"
map<Ticket> tickets = {};

// Ticketing service
service /ticket on new http:Listener(8081) {

    // Create ticket
    resource function post create(@http:Payload Ticket newTicket) returns string {
        if tickets.hasKey(newTicket.id.toString()) {
            return "Ticket with ID " + newTicket.id.toString() + " already exists.";
        }
        newTicket.status = "CREATED";
        tickets[newTicket.id.toString()] = newTicket;
        return "Ticket created successfully!";
    }

    // Get ticket by ID
    resource function get [int id]() returns Ticket|http:NotFound {
        Ticket? t = tickets[id.toString()];
        if t is Ticket {
            return t;
        } else {
            return http:NOT_FOUND;
        }
    }

    // Get all tickets
    resource function get list() returns Ticket[] {
        Ticket[] result = [];
        foreach var key in tickets.keys() {
            Ticket? t = tickets[key];
            if t is Ticket {
                result.push(t);
            }
        }
        return result;
    }

    // Update status
    resource function put [int id]/status(string newStatus) returns string {
        Ticket? t = tickets[id.toString()];
        if t is Ticket {
            t.status = newStatus;
            tickets[id.toString()] = t;
            return "Ticket status updated to " + newStatus;
        } else {
            return "Ticket not found.";
        }
    }

    // Delete ticket
    resource function delete [int id]() returns string {
        if tickets.hasKey(id.toString()) {
            _ = tickets.remove(id.toString());
            return "Ticket deleted successfully.";
        } else {
            return "Ticket not found.";
        }
    }
}
