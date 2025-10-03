import ballerina/http;
import ballerina/io;

public type Payment record {|
    int ticketId;
    int passengerId;
    float amount;
    string status; // PENDING, COMPLETED
|};

map<Payment> payments = {};

service /payment on new http:Listener(8082) {

    resource function post process(@http:Payload Payment newPayment) returns string {
        newPayment.status = "COMPLETED";
        payments[newPayment.ticketId.toString()] = newPayment;

        // Simulate Kafka event
        string payload = string `{"ticketId": ${newPayment.ticketId}, "status": "PAID"}`;
        io:println("Event sent: " + payload);

        return "Payment processed and event sent!";
    }

    resource function get list() returns Payment[] {
        Payment[] result = [];
        foreach var key in payments.keys() {
            Payment? p = payments[key];
            if p is Payment {
                result.push(p);
            }
        }
        return result;
    }
}
