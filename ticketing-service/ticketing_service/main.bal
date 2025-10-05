import ballerina/http;

// Ticket record
type Ticket record {|
    int id;
    int passengerId;
    string passengerName;
    string ticketType; // single, multi, or pass
    string status;     // CREATED | PAID | VALIDATED | EXPIRED
|};

// In-memory storage
map<Ticket> tickets = {};

// HTTP Service
service /ticket on new http:Listener(8090) {

    // Create a new ticket
    resource function post create(@http:Payload Ticket newTicket) returns json {
        if tickets.hasKey(newTicket.id.toString()) {
            return { message: "Ticket with ID " + newTicket.id.toString() + " already exists." };
        }
        tickets[newTicket.id.toString()] = newTicket;
        return { message: "Ticket created successfully!", ticket: newTicket };
    }

    // Get ticket by ID
    resource function get [int id]() returns json {
        Ticket? t = tickets[id.toString()];
        if t is Ticket {
            return { ticket: t };
        } else {
            return { message: "Ticket not found." };
        }
    }

    // Get all tickets
    resource function get list() returns json {
        Ticket[] allTickets = [];
        foreach var key in tickets.keys() {
            Ticket? t = tickets[key];
            if t is Ticket {
                allTickets.push(t);
            }
        }
        return { tickets: allTickets };
    }

    // ✅ Update ticket status using path params
    resource function put updateStatus/[int id]/[string newStatus]() returns json {
        Ticket? t = tickets[id.toString()];
        if t is Ticket {
            t.status = newStatus;
            tickets[id.toString()] = t;
            return { message: "Ticket status updated successfully!", ticket: t };
        } else {
            return { message: "Ticket not found." };
        }
    }

    // Delete ticket
    resource function delete [int id]() returns json {
        if tickets.hasKey(id.toString()) {
            _ = tickets.remove(id.toString());
            return { message: "Ticket deleted successfully." };
        } else {
            return { message: "Ticket not found." };
        }
    }
}
