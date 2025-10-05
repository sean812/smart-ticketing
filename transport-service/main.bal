import ballerina/http;

type Transport record {|
    int id;
    string transportType;
    string route;
    int capacity;
    string status;
|};

map<Transport> transportDb = {};

service /transport on new http:Listener(8092) {

    resource function post create(@http:Payload Transport newTransport) returns json {
        if transportDb.hasKey(newTransport.id.toString()) {
            return { "status": "error", "message": "Transport with this ID already exists" };
        }
        transportDb[newTransport.id.toString()] = newTransport;
        return { "status": "success", "data": newTransport };
    }

    resource function get [int id]() returns json {
        Transport? t = transportDb[id.toString()];
        if t is Transport {
            return { "status": "success", "data": t };
        }
        return { "status": "error", "message": "Transport not found" };
    }

    resource function get all() returns json {
        return { "status": "success", "data": transportDb };
    }

    resource function put update/[int id](@http:Payload Transport updatedTransport) returns json {
        if !transportDb.hasKey(id.toString()) {
            return { "status": "error", "message": "Transport not found" };
        }
        transportDb[id.toString()] = updatedTransport;
        return { "status": "success", "data": updatedTransport };
    }

    resource function delete delete/[int id]() returns json {
        if !transportDb.hasKey(id.toString()) {
            return { "status": "error", "message": "Transport not found" };
        }
        _ = transportDb.remove(id.toString());
        return { "status": "success", "message": "Transport deleted successfully" };
    }
}
