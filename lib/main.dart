import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wikipedia Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  Future<List<Map<String, dynamic>>> searchWiki(String searchQuery) async {
    final apiUrl =
        'http://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=$searchQuery&format=json';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonResult = json.decode(response.body);
      final searchResults = jsonResult['query']['search'];

      List<Map<String, dynamic>> parsedResults = [];

      for (var result in searchResults) {
        parsedResults.add(result);
      }

      return parsedResults;
    } else {
      throw Exception('Failed to search Wikipedia');
    }
  }

  void performSearch() async {
    final query = searchController.text;

    if (query.isNotEmpty) {
      try {
        final results = await searchWiki(query);
        setState(() {
          searchResults = results;
        });
      } catch (e) {
        // Handle error
      }
    }
  }

  ListView searchResultsListView(List<Map<String, dynamic>> searchResults) {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final result = searchResults[index];
        return ListTile(
          title: Text(
            result['title'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(result['snippet']),
          onTap: () {
            // Handle tapping on a search result
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wikipedia Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Enter your search query',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: performSearch,
                ),
              ),
            ),
          ),
          Expanded(
            child: searchResults.isEmpty
                ? Center(
                    child: Text('No results found.'),
                  )
                : searchResultsListView(searchResults),
          ),
        ],
      ),
    );
  }
}
