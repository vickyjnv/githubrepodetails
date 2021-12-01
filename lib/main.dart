import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'Model/dataModel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPage = 1;
  late int totalPages;
  List<Repos> repos = [];

  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  Future<bool> getData({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
    } else {
      if (currentPage >= totalPages) {
        refreshController.loadNoData();
        return false;
      }
    }

    final Uri uri = Uri.parse(
        "https://api.github.com/users/JakeWharton/repos?page=$currentPage&per_page=15");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
    
      final result = reposFromJson(response.body);

      if (isRefresh) {
        repos = result;
      } else {
        repos.addAll(result);
      }

      currentPage++;

      print(response.body);
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Infinite List Pagination"),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final data = repos[index];

          return ListTile(
            title: Text(data.name),
            subtitle: Text(data.description),
            trailing: Text(
              data.language,
              style: TextStyle(color: Colors.green),
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: repos.length,
      ),
    );
  }
}
