import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  List<Map<String, dynamic>> getFetchList = [];
  List<Map<String, dynamic>> filteredList = [];
  String dropdownValue = "All";

  @override
  void initState() {
    super.initState();
    getAPiData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fetch Demo"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          DropdownButton<String>(
            value: dropdownValue,
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
                filterList();
              });
            },
            items: <String>['All', ...getUniqueListIds()]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 3,
              child: ListTile(
                title: Text('ID: ${filteredList[index]['id']}'),
                subtitle: Text('ListID: ${filteredList[index]['listId']}'),
                trailing: Text('Name: ${filteredList[index]['name'] ?? "Unnamed"}'),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> getAPiData() async {
    try {
      var res = await http.get(Uri.parse('https://fetch-hiring.s3.amazonaws.com/hiring.json'));
      if (res.statusCode == 200) {
        List<dynamic> getDataResponse = jsonDecode(res.body);
        setState(() {
          getFetchList = getDataResponse
              .cast<Map<String, dynamic>>()
              .where((item) => item['name'] != null && item['name'].toString().isNotEmpty)
              .toList();
          filterList(); // Filter list immediately after fetching data
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
    }
  }

  List<String> getUniqueListIds() {
    Set<String> uniqueIds = Set();
    for (var item in getFetchList) {
      uniqueIds.add(item['listId'].toString());
    }
    return uniqueIds.toList()..sort();
  }

  void filterList() {
    List<Map<String, dynamic>> tempList;
    if (dropdownValue == 'All') {
      tempList = List.from(getFetchList);
    } else {
      tempList = getFetchList.where((item) => item['listId'].toString() == dropdownValue).toList();
    }

    // Filter out items with blank or null names
    tempList = tempList.where((item) => item['name'] != null && item['name'].toString().isNotEmpty).toList();

    // Sort by listId first and then by name
    tempList.sort((a, b) {
      int listIdComparison = a['listId'].toString().compareTo(b['listId'].toString());
      if (listIdComparison != 0) {
        return listIdComparison;
      }
      return a['name'].toString().compareTo(b['name'].toString());
    });

    setState(() {
      filteredList = tempList;
    });
  }
}
