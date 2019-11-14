import 'package:flutter/material.dart';
import 'package:flutter_journal_demo/ConnectingWidget.dart';
import 'package:flutter_journal_demo/CoolRoundedButton.dart';
import 'package:flutter_journal_demo/FirebaseWrapper.dart';
import 'package:flutter_journal_demo/LoginPage.dart';

class UserPost {
  String id;
  String title;
  String body;

  UserPost({this.id, this.title, this.body});

  Map<String, dynamic> map() {
    return {'title': title, 'body': body};
  }
}

class HomePage extends StatefulWidget {
  HomePage({this.userId});

  final String userId;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StatusState _loadingState;

  List<UserPost> userPosts;

  @override
  void initState() {
    super.initState();
    _loadingState = StatusState.pending;
    _fetchUserPosts();
  }

  void _fetchUserPosts() async {
    //Retrieve all posts for this user from Firebase

    var fetchedPosts = await FirebaseWrapper().getPosts(widget.userId);
    if (fetchedPosts == null) {
      setState(() {
        _loadingState = StatusState.idle;
      });
      return;
    }

    //Assign these posts to local storage
    userPosts = [];
    fetchedPosts.forEach((postID, post) {
      userPosts.add(
          new UserPost(id: postID, title: post['title'], body: post['body']));
    });

    //Sort the posts by descending postID
    userPosts.sort((a, b) {
      return b.id.compareTo(a.id);
    });

    setState(() {
      _loadingState = StatusState.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _logoutButton(),
        actions: <Widget>[],
        title: Text('Flutter Journal'),
        centerTitle: true,
      ),
      body: _bodyWidget(),
      floatingActionButton: CoolRoundedButton(
          child: Text('Create post',
              style: TextStyle(fontSize: 16, color: Colors.white)),
          color: Colors.blue,
          onPressed: () {
            _openPostEditor(null);
          }),
    );
  }

  Future<bool> _disconnect() async {
    await FirebaseWrapper().signOut();
    return true;
  }

  Widget _logoutButton() {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          _disconnect();
          Navigator.pushReplacementNamed(context, "/login");
        });
  }

  Widget _bodyWidget() {
    if (_loadingState == StatusState.pending) {
      return Center(child: ConnectingWidget(color: Colors.blue));
    }

    if (userPosts == null || userPosts.length < 1) {
      return Container(
          alignment: Alignment.center,
          child: Text('Tap below to make your first post'));
    }

    return Center(
        child: Scrollbar(
            child: ListView(
                children: _postWidgetList(),
                semanticChildCount: userPosts.length ?? 0)));
  }

  List<Widget> _postWidgetList() {
    List<Widget> postWidgets = [];
    for (var i = 0; i < userPosts.length; ++i) {
      postWidgets.add(_postWidget(userPosts[i]));
    }
    return postWidgets;
  }

  Widget _postWidget(UserPost post) {
    return new InkWell(
      onTap: () {
        _openPostEditor(post);
      },
      child: Container(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(height: 2),
                  Text(post.title ?? '',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  Container(height: 10),
                  Text(post.body ?? '', style: TextStyle(fontSize: 18),),
                  Container(height: 1, color: Colors.grey),
                ],
              ))),
    );
  }

  void _openPostEditor(UserPost post) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostEditor(
                  post: post,
                  parent: this,
                )));
  }

  void savePost(UserPost post) async {
    setState(() {
      _loadingState = StatusState.pending;
    });
    if (post.id == null) {
      await FirebaseWrapper().createPost(widget.userId, post);
    } else {
      await FirebaseWrapper().updatePost(widget.userId, post);
    }
    _fetchUserPosts();
  }

  void deletePost(UserPost post) async {
    setState(() {
      _loadingState = StatusState.pending;
    });
    await FirebaseWrapper().deletePost(widget.userId, post);
    _fetchUserPosts();
  }
}

class PostEditor extends StatefulWidget {
  final UserPost post;
  final _HomePageState parent;

  PostEditor({this.post, this.parent});

  @override
  _PostEditorState createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditor> {
  //Needed to reference the text fields
  TextEditingController _titleController;
  TextEditingController _bodyController;

  UserPost newPost;

  @override
  void initState() {
    super.initState();

    _titleController = new TextEditingController();
    _bodyController = new TextEditingController();

    if (widget.post != null) {
      //Editing a post
      newPost = widget.post;
      _titleController.text = newPost.title;
      _bodyController.text = newPost.body;
    } else {
      //Creating a new post
      newPost = new UserPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    var heroTag = widget.post == null ? 'new' : widget.post.id;

    return Scaffold(
        body: Center(
            child: Hero(
                tag: heroTag,
                child: Container(
                  width: 380,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.white),
                            onPressed: _delete,
                          )
                        ],
                      ),
                      //Title
                      Padding(
                          padding:
                              EdgeInsets.only(left: 80, right: 80, bottom: 20),
                          child: TextFormField(
                            maxLines: 1,
                            controller: _titleController,
                            decoration: _textFieldDecoration('Title'),
                          )),
                      //Body
                      Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          child: TextFormField(
                            maxLines: null,
                            controller: _bodyController,
                            decoration: _textFieldDecoration('Content'),
                          )),
                      CoolRoundedButton(
                        color: Colors.pinkAccent,
                        child: Text('Save',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        onPressed: _finish,
                      ),
                      Container(height: 20)
                    ],
                  ),
                ))));
  }

  InputDecoration _textFieldDecoration(String hint) {
    OutlineInputBorder _border(Color color) {
      return OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: color, width: 3));
    }

    return InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        fillColor: Colors.white,
        filled: true,
        hintText: hint,
        enabledBorder: _border(Colors.white),
        focusedBorder: _border(Colors.lightBlue));
  }

  void _finish() {
    newPost.title = _titleController.text;
    newPost.body = _bodyController.text;

    widget.parent.savePost(newPost);

    //Leave
    Navigator.pop(context);
  }

  void _delete() {
    widget.parent.deletePost(widget.post);

    //Leave
    Navigator.pop(context);
  }
}
