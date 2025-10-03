import ballerina/http;
import ballerina/io;

// Notification record
public type Notification record {|
    int ticketId;
    string message;
|};

// In-memory store
Notification[] notifications = [];

// Notification service
service /notification on new http:Listener(8083) {

    // Receive event from Payment Service
    resource function post receiveEvent(@http:Payload map<anydata> event) returns string {
        // assume ticketId is an int
        int ticketId = <int>event["ticketId"];
        string status = <string>event["status"];

        Notification n = {ticketId: ticketId, message: "Ticket " + ticketId.toString() + " status: " + status};
        notifications.push(n);

        io:println("Notification created: " + n.message);
        return "Notification received for ticket " + ticketId.toString();
    }

    // Get all notifications
    resource function get list() returns Notification[] {
        return notifications;
    }
}
