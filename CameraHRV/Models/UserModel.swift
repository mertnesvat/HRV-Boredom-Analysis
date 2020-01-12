import Foundation
import FirebaseAuth

struct UserModel: Codable{
    var uid: String = ""
    var firstName: String?
    var secondName: String?
    var displayName: String?
    var username: String = ""
    var email: String?
    var notificationTokens: [String : Bool] = [:]
    var isLoggedin: Bool    = false
    var dob: String?
    var fcmToken: String?
    
    init(uid: String, firstName: String?, secondName: String?, displayName: String, username: String, email: String, notificationTokens: String, isLoggedin: Bool, dob: String?) {
        self.uid                    = uid
        self.firstName              = firstName
        self.secondName             = secondName
        self.displayName            = displayName
        self.username               = username
        self.email                  = email
        self.notificationTokens     = [notificationTokens : true]
        self.isLoggedin             = isLoggedin
        self.dob                    = dob
    }
    
    init(withFirebaseUser u:User){
        self.uid = u.uid
        self.displayName = u.displayName
//        self.email = u.email
        self.isLoggedin = true
    }

}
