import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupPurposeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safe Zone Groups'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildGroupList(),
          _buildCreateGroupForm(),
        ],
      ),
    );
  }

  Widget _buildGroupList() {
    return Expanded(
      child: StreamBuilder(
        stream: _firestore.collection('groups').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var groups = snapshot.data?.docs;

          List<Widget> groupWidgets = [];
          for (var group in groups!) {
            final groupName = group['name'];
            final groupPurpose = group['purpose'];
            final groupId = group.id;

            groupWidgets.add(
              Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(groupName),
                  subtitle: Text(groupPurpose),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupChatScreen(groupId, groupName),
                      ),
                    );
                  },
                ),
              ),
            );
          }

          return ListView(
            children: groupWidgets,
          );
        },
      ),
    );
  }

  Widget _buildCreateGroupForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a New Group',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _groupNameController,
            decoration: InputDecoration(labelText: 'Group Name'),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _groupPurposeController,
            decoration: InputDecoration(labelText: 'Group Purpose'),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              _createGroup();
            },
            child: Text('Create Group'),
          ),
        ],
      ),
    );
  }

  void _createGroup() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String groupName = _groupNameController.text.trim();
      String groupPurpose = _groupPurposeController.text.trim();

      if (groupName.isNotEmpty && groupPurpose.isNotEmpty) {
        _firestore.collection('groups').add({
          'name': groupName,
          'purpose': groupPurpose,
        });

        _groupNameController.clear();
        _groupPurposeController.clear();
      }
    }
  }

  void _signOut() async {
    await _auth.signOut();
  }
}

class GroupChatScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  GroupChatScreen(this.groupId, this.groupName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: GroupChat(groupId),
    );
  }
}

class GroupChat extends StatefulWidget {
  final String groupId;

  GroupChat(this.groupId);

  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: _firestore
                .collection('groups')
                .doc(widget.groupId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var messages = snapshot.data?.docs;

              List<Widget> messageWidgets = [];
              for (var message in messages!) {
                final messageText = message['text'];
                final messageSender = message['sender'];

                messageWidgets.add(
                  ListTile(
                    title: Text(messageSender),
                    subtitle: Text(messageText),
                  ),
                );
              }

              return ListView(
                children: messageWidgets,
              );
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Type your message'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String messageText = _messageController.text.trim();
      String messageSender = user.email ?? 'User'; // Use email as sender's name

      if (messageText.isNotEmpty) {
        _firestore
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .add({
              'text': messageText,
              'sender': messageSender,
              'timestamp': FieldValue.serverTimestamp(),
            });

        _messageController.clear();
      }
    }
  }
}
