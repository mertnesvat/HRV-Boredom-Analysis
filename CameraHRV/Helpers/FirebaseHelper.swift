import Foundation
import FirebaseDatabase
import CodableFirebase
import FirebaseAuth

class FirebaseHelper  {
    
    var ref: DatabaseReference! = Database.database().reference()
    var users: DatabaseReference! = Database.database().reference().child("users/")
    let defaults = UserDefaults.standard
    lazy var measurements: DatabaseReference! = {
        return Database.database().reference().child("users/\(defaults.string(forKey: "uid")!)/measurements/")
    }()

    static let shared = FirebaseHelper()
    var currentUser: UserModel?
    
    func login(isFirst:Bool){
        self.currentUser = UserModel(withFirebaseUser: Auth.auth().currentUser!)
        let defaults = UserDefaults.standard
        self.currentUser?.email      = defaults.string(forKey: "email")
        self.currentUser?.dob        = defaults.string(forKey: "dob")
        self.currentUser?.firstName  = defaults.string(forKey: "firstName")
        self.currentUser?.secondName = defaults.string(forKey: "lastName")
        self.currentUser?.fcmToken   = defaults.string(forKey: "fcmToken")
        defaults.set(Auth.auth().currentUser!.uid, forKey: "uid")

        if isFirst {
            let data = try! FirebaseEncoder().encode(self.currentUser)
            users.child(self.currentUser!.uid).setValue(data)
            NotificationCenter.default.addObserver(self, selector: #selector(addNotificationToken(notification:)), name: .registeredToken , object: nil)
        }
    }
    
    func updateFcmToken(_ token: String) {
        Database.database().reference().child("users/\(defaults.string(forKey: "uid")!)/fcmToken").setValue(token)
    }
    
    @objc
    func addNotificationToken(notification: NSNotification){
        if let t = notification.userInfo?["token"] as! String?, let uid = currentUser?.uid{
            users.child("\(uid)/notificationTokens").setValue([t: true])
        } else {
            if let t = UserDefaults.standard.string(forKey: "token"), let uid = currentUser?.uid {
                users.child("\(uid)/notificationTokens").setValue([t: true])
            }
        }
    }
    
    func fetchMeasurementHistory(callback: @escaping (([MeasurementModel]) -> Void)) {
        measurements
            .queryLimited(toLast: 30)
            .observeSingleEvent(of: .value) { shot in
            let enumerator = shot.children
            var model: [MeasurementModel] = []
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let measurement = try! FirebaseDecoder().decode(MeasurementModel.self, from: rest.value)
                model.append(measurement)
            }
            callback(model)
        }
    }
    /*
    func observeChatForAbi(callback: @escaping (DataSnapshot) -> Void){
        let abiChat = chats.child("\(123)/messages/")
        
        abiChat.observe(.childAdded) { (snapshot) in
            print(snapshot)
            callback(snapshot)
        }
    }
    
    func fetchLastMessages(count: UInt, callback: @escaping ([MessageModel]) -> Void) {
        let abiChat = chats.child("\(123)/messages/")
        
        (abiChat.queryLimited(toFirst: count)).observe(.value) { (shot) in
            let enumerator = shot.children
            var messages: [MessageModel] = []
            while let rest = enumerator.nextObject() as? DataSnapshot {
                var message = try! FirebaseDecoder().decode(MessageModel.self, from: rest.value)
                messages.append(message)
            }
            callback(messages)
        }
        
    }
    
    func sendMessage(chatId: String, message: MessageModel) {
        let data = try! FirebaseEncoder().encode(message)
        
        chats.child("\(chatId)/messages/").childByAutoId().setValue(data)
    }
    */
    func saveMeasurement(measurement: MeasurementModel) {
        let data = try! FirebaseEncoder().encode(measurement)
        measurements.childByAutoId().setValue(data)
    }
}
