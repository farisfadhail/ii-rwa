import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Text "mo:base/Text";

actor {
    type User = {
        id: Nat;
        principal: Principal;
        nik: Nat;
    };

    stable var users: [User] = [];
    stable var nextUserId: Nat = 1;

    type Land = {
        id: Nat;           
        certifcate_id: Text;       
        owner: Principal;         
        price: Nat;               
        forSale: Bool;            
    };

    stable var lands: [Land] = [];
    stable var nextLandId: Nat = 1;

    type EventLog = {
        landId: Nat;
        seller: Principal;
        buyer: Principal;
        price: Nat;
        timestamp: Int;
    };

    // var transactionLogs: [EventLog] = [];

    public shared(msg) func registerUser(nik: Nat) : async (Nat, Text, ?User) {
        let caller = msg.caller;
        if (caller == Principal.fromText("2vxsx-fae")) {
            return (403, "Unauthorized", null);
        };
        if (Nat.toText(nik).size() != 16) {
            return (400, "NIK is invalid", null);
        };
        if (Array.filter<User>(users, func (user) = user.principal == caller).size() > 0) {
            return (409, "User already registered", null);
        };
        let user = { id = nextUserId; principal = caller; nik = nik };
        users := Array.append(users, [user]);
        nextUserId += 1;
        return (200, "User registered", ?user);
    };

    public shared(msg) func authenticateUser(nik: Nat) : async (Nat, Text) {
        let caller = msg.caller;
        for (user in users.vals()) {
            if (user.principal == caller and user.nik == nik) {
                return (200, "User authenticated");
            }
        };
        return (500, "Authentication failed");
    };

    public query func getUsers() : async [User] {
        return users;
    };

    public shared(msg) func getUserByPrincipal() : async User {
        for (user in users.vals()) {
            if (user.principal == msg.caller) {
                return user;
            }
        };
        return { id = 0; principal = Principal.fromText("2vxsx-fae"); nik = 0 };
    };

    public func getUserById(id : Nat) : async User {
        for (user in users.vals()) {
            if (user.id == id) {
                return user;
            }
        };
        return { id = 0; principal = Principal.fromText("2vxsx-fae"); nik = 0 };
    };

    public query func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };

    public shared (msg) func whoami() : async Principal {
        msg.caller
    };

    public shared(msg) func registerLand(certifcate_id: Text, price: Nat): async (Nat, Text, ?Land) {
        let caller = msg.caller;
        // if (caller == Principal.fromText("2vxsx-fae")) {
        //     return (403, "Unauthorized", null);
        // };

        if (Array.filter<Land>(lands, func (land) = land.certifcate_id == certifcate_id).size() > 0) {
            return (409, "Land already registered", null);
        };

        let newLand = {
            id = nextLandId;
            certifcate_id = certifcate_id;
            owner = caller;
            price = price;
            forSale = false;
        };

        lands := Array.append(lands, [newLand]);
        nextLandId += 1;
        return (200, "Land successfully registered.", ?newLand);
    };

    public query func getLands() : async [Land] {
    // public shared (msg) func getLands() : async [Land] {
        // return Array.filter<Land>(lands, func (land) = land.forSale == true and land.owner == msg.caller);
        return lands;
    };
};