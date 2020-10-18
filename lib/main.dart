import 'package:flutter/material.dart';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;

final _root = 'https://mozartec.com'; //replace with your site url
final wp.WordPress wordPress = wp.WordPress(baseUrl: _root);

void main() {
  runApp(MaterialApp(home: MyHomePage()));
} //App Entry Point

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mozartec'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: posts == null ? 0 : posts.length,
        itemBuilder: (BuildContext context, int index) {
          return buildPost(index); //Building the posts list view
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    this.getPosts();
  }

  Widget buildPost(int index) {
    return Column(
      children: <Widget>[
        Card(
          child: Column(
            children: <Widget>[
              buildImage(index),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: ListTile(
                  title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(posts[index].title.rendered)),
                  subtitle: Text(posts[index].excerpt.rendered),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget buildImage(int index) {
    if (posts[index].featuredMedia == null) {
      return Image.network(
        'https://mozartec.com/wp-content/uploads/2020/10/mozartec-no-photo-available-icon.png',
      );
    }
    return Image.network(
      posts[index].featuredMedia.mediaDetails.sizes.medium.sourceUrl,
    );
  }

  Future<String> getPosts() async {
    var res = await fetchPosts();
    setState(() {
      posts = res;
    });
    return "Success!";
  }

  List<wp.Post> posts;
  Future<List<wp.Post>> fetchPosts() async {
    var posts = wordPress.fetchPosts(
      postParams: wp.ParamsPostList(
        context: wp.WordPressContext.view,
        postStatus: wp.PostPageStatus.publish,
        orderBy: wp.PostOrderBy.date,
        order: wp.Order.desc,
      ),
      fetchAuthor: true,
      fetchFeaturedMedia: true,
      fetchComments: true,
      fetchCategories: true,
      fetchTags: true,
    );
    return posts;
  }
}
