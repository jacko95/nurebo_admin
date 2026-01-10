import 'package:nurebo_admin/models/business_room_message.dart';
import 'package:nurebo_admin/models/event.dart';

class ChatRoom {
  Event? event;
  List<BusinessChatRoomMessage>? chatRoomMessages = [];
  late int? unread_messages;

  ChatRoom({
    this.event,
    this.chatRoomMessages,
    this.unread_messages,
  });
}