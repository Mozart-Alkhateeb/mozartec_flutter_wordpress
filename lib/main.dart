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
  List<int> _selectedCategories =
      List(); // Preserves a list with selected categoty Id's
  bool _isLoading =
      false; // We will use this to show a loading indicator when fetching posts

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mozartec'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_sharp),
            onPressed: () => openFilterDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
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
    this.getCategories();
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
    setState(() {
      _isLoading = true;
    });

    var res = await fetchPosts();
    setState(() {
      posts = res;
      _isLoading = false;
    });
    return "Success!";
  }

  Future<String> getCategories() async {
    var res = await fetchCategories();
    setState(() {
      categories = res;

      // Just to confirm that we are getting the categories form the server
      categories.forEach((element) {
        print(element.toJson());
      });
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
          includeCategories: _selectedCategories),
      fetchAuthor: true,
      fetchFeaturedMedia: true,
      fetchComments: true,
      fetchCategories: true,
      fetchTags: true,
    );
    return posts;
  }

  List<wp.Category> categories;
  Future<List<wp.Category>> fetchCategories() async {
    var cats = wordPress.fetchCategories(
        params: wp.ParamsCategoryList(
      hideEmpty: true,
    ));

    return cats;
  }

  openFilterDialog() {
    showDialog(
      context: context,
      builder: (
        BuildContext context,
      ) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
          child: StatefulBuilder(
            // We need the stateful builder since Dialog content are not affected by widget setState
            builder: (BuildContext context, StateSetter setState) =>
                ListView.builder(
              itemCount: categories == null ? 0 : categories.length,
              itemBuilder: (BuildContext context, int index) {
                return buildCategory(
                    index, setState); //Building the categories list view
              },
            ),
          ),
        );
      },
    ).then((value) =>
        getPosts()); // Refresh posts after category filter has changed
  }

  Widget buildCategory(int index, StateSetter setState) {
    var currentItem = categories[index];
    return Container(
      child: ListTile(
        title: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 5.0,
          ),
          child: Text(currentItem.name),
        ),
        selected:
            _selectedCategories.any((element) => element == currentItem.id),
        isThreeLine: false,
        onTap: () => setState(() => toggleSelection(currentItem)),
        key: Key(currentItem.id.toString()),
      ),
    );
  }

  void toggleSelection(wp.Category currentItem) {
    if (_selectedCategories.any((element) => element == currentItem.id)) {
      _selectedCategories.remove(currentItem.id);
    } else {
      _selectedCategories.add(currentItem.id);
    }
  }
}
