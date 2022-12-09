class ChatRoomModel{
  String? chatroomid;
  Map<String,dynamic>? participants;
  String? lastMessage;
  DateTime? lastUpdated;
  List<dynamic>? users;

  ChatRoomModel({this.chatroomid,this.participants,this.lastMessage,this.lastUpdated,this.users});

  ChatRoomModel.fromMap(Map<String,dynamic> map){
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMessage = map["lastmessage"];
    lastUpdated = map["lastUpdated"].toDate();
    users = map["users"];
  }

  Map<String,dynamic> toMap(){
    return{
      "chatroomid" : chatroomid,
      "participants" : participants,
      "lastmessage" : lastMessage,
      "lastUpdated" : lastUpdated,
      "users" : users
    };
  }
}