import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:runic_mobile/rune/home.dart';
import 'package:searchfield/searchfield.dart';

const Color lightColor = Color.fromRGBO(42, 39, 98, 1);
const Color darkColor = Color.fromRGBO(24, 17, 64, 1);
const Color accentColor = Color.fromRGBO(255, 0, 229, 1.0);
const Color whiteColor = Color.fromRGBO(255, 255, 255, 1.0);

class Registry extends StatefulWidget {
  final List<dynamic>? registry;
  Registry({Key? key, this.registry}) : super(key: key);

  @override
  _RegistryState createState() => _RegistryState();
}

class _RegistryState extends State<Registry> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    loadRegistry();
    super.initState();
  }

  List<dynamic> searchList = [];
  void loadRegistry() async {
    _searchController.addListener(() {
      search(_searchController.text);
    });
    search("");
    setState(() {});
  }

  void search(String pattern) {
    if (pattern == "") {
      searchList = List.from(widget.registry!);
    } else {
      searchList = [];
      for (var rune in widget.registry!) {
        if (rune["name"]!.contains(pattern) ||
            rune["description"]!
                .toString()
                .toLowerCase()
                .contains(pattern.toLowerCase())) {
          searchList.add(rune);
        }
      }
    }
    setState(() {});
  }

  void open(Map<String, dynamic> rune, bool isURL) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RunicHomePage(
                currentRune: rune,
                url: isURL,
              )),
    );
  }

  bool _link = false;
  static String _url = "https://";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: darkColor,
          leading: Container(
              padding: EdgeInsets.all(6),
              child: Image.asset(
                "assets/rune.png",
                height: 32,
              )),
          title: Text("Runic"),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    _link = !_link;
                  });
                },
                icon: Icon(_link ? Icons.search : Icons.link))
          ],
        ),
        body: _link
            ? Container(
                color: lightColor,
                child: ListView(
                  children: [
                    TextFormField(
                      style: TextStyle(color: accentColor),
                      initialValue: _url,
                      onChanged: (value) {
                        _url = value;
                      },
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Rune url'),
                    ),
                    FlatButton(
                      height: 42,
                      color: accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: () {
                        open({"name": _url}, true);
                      },
                      child: Text("Fetch & Deploy",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ))
            : Column(children: [
                SearchField(
                  marginColor: lightColor,
                  searchStyle: TextStyle(color: whiteColor),
                  searchInputDecoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(0.0),
                        ),
                      ),
                      hintStyle: TextStyle(color: accentColor),
                      filled: true,
                      fillColor: lightColor),
                  suggestionsDecoration: BoxDecoration(color: darkColor),
                  suggestionItemDecoration: BoxDecoration(color: darkColor),
                  suggestionStyle:
                      TextStyle(color: Color.fromRGBO(59, 188, 235, 1)),
                  suggestions: List<String>.from(
                      widget.registry!.map((rune) => rune["name"]).toList()),
                  controller: _searchController,
                  hint: 'Search rune registry',
                  maxSuggestionsInViewPort: 4,
                  itemHeight: 45,
                  onTap: (x) {},
                ),
                Expanded(
                    child: Container(
                        color: lightColor,
                        padding: EdgeInsets.all(6),
                        child: GridView.builder(
                          itemCount: searchList.length,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 320),
                          itemBuilder: (BuildContext context, int index) {
                            return new InkWell(
                                onTap: () {
                                  open(searchList[index], false);
                                },
                                child: new Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    color: darkColor,
                                    margin: EdgeInsets.all(6),
                                    child: Container(
                                      padding: EdgeInsets.all(21),
                                      child: new GridTile(
                                          child: Container(
                                              child: Opacity(
                                            opacity: 0.2,
                                            child: Image.asset(
                                              "assets/rune.png",
                                              height: double.infinity,
                                              width: double.infinity,
                                            ),
                                          )),
                                          header: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                new Text(
                                                  searchList[index]['name'],
                                                  style: TextStyle(
                                                      color: accentColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: new Text(
                                                    searchList[index]
                                                        ['description'],
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: whiteColor,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ), //just for testing, will fill with image later
                                                )
                                              ])),
                                    )));
                          },
                        ))),
                /*Container(
              height: 21,
              color: darkColor,
              padding: EdgeInsets.only(right: 5.0),
              child: Row(children: [
                Expanded(child: Container()),
                Text("Copyright © 2021 hotg.ai inc.",
                    style: TextStyle(
                        color: whiteColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w300))
              ]))*/
              ])
// This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
