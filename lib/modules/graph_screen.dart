import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphview/GraphView.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/analytics.dart';
import 'package:runic_flutter/core/hf_auth.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/core/rune_graph.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/main_menu.dart';
import 'package:share_plus/share_plus.dart';

class GraphScreen extends StatefulWidget {
  GraphScreen({Key? key}) : super(key: key);

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  @override
  final Graph graph = Graph()..isTree = false;
  SugiyamaConfiguration builder = SugiyamaConfiguration();

  List<Node> nodes = [];
  List<Map<String, dynamic>> metaNode = [];
  Map<String, List<int>> connections = {};
  void buildGraph() {
    //capabilities
    builder
      ..nodeSeparation = (15)
      ..levelSeparation = (15)
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;

    for (Capability cap in RuneEngine.runeGraph!.capabilities) {
      Node node = Node.Id(nodes.length);
      Map<String, dynamic> meta = {
        "id": nodes.length,
        "name": cap.name,
        "type": "cap",
        "outputs": cap.outputs,
        "args": cap.args
      };
      nodes.add(node);
      metaNode.add(meta);
      if (cap.outputs != null) {
        for (String con in cap.outputs!) {
          addConnection(con, meta["id"]);
        }
      }
    }

    for (Capability cap in RuneEngine.runeGraph!.capabilities) {
      if (cap.outputs != null) {
        for (String con in cap.outputs!) {
          addProcBlocks(con);
        }
      }
    }

    for (Model model in RuneEngine.runeGraph!.models) {
      Node node = Node.Id(nodes.length);
      Map<String, dynamic> meta = {
        "id": nodes.length,
        "name": model.name,
        "type": "model",
        "outputs": model.outputs,
        "inputs": model.inputs,
        "args": model.file
      };
      nodes.add(node);
      metaNode.add(meta);
      if (model.inputs != null) {
        for (String con in model.inputs!) {
          addConnection(con, meta["id"]);
        }
      }
      if (model.outputs != null) {
        for (String con in model.outputs!) {
          addConnection(con, meta["id"]);
        }
      }
    }

    for (Model model in RuneEngine.runeGraph!.models) {
      if (model.outputs != null) {
        for (String con in model.outputs!) {
          addProcBlocks(con);
        }
      }
    }

    for (Output output in RuneEngine.runeGraph!.outputs) {
      Node node = Node.Id(nodes.length);
      Map<String, dynamic> meta = {
        "id": nodes.length,
        "name": output.name,
        "type": "output",
        "inputs": output.inputs,
        "args": output.kind
      };
      nodes.add(node);
      metaNode.add(meta);
      if (output.inputs != null) {
        for (String con in output.inputs!) {
          addConnection(con, meta["id"]);
        }
      }
    }

    //generate
    for (String connection in connections.keys) {
      if (connections[connection]!.length == 2) {
        Node node = Node.Id(nodes.length);
        Map<String, dynamic> meta = {
          "id": nodes.length,
          "name": connection,
          "type": "con",
        };
        nodes.add(node);
        metaNode.add(meta);
        Paint paint = new Paint();
        paint.color = Colors.white;
        paint.strokeWidth = 2.0;

        graph.addEdge(nodes[connections[connection]![0]], node, paint: paint);
        graph.addEdge(node, nodes[connections[connection]![1]], paint: paint);
      }
    }
  }

  void markPreModel(String connection) {
    for (ProcBlock proc in RuneEngine.runeGraph!.procBlocks) {
      if (proc.inputs != null) {
        for (String input in proc.inputs!) {
          if (input == connection) {
            proc.preModel = true;
            if (proc.outputs != null) {
              for (String output in proc.outputs!) {
                markPreModel(output);
              }
            }
          }
        }
      }
    }
  }

  void addProcBlocks(String connection) {
    for (ProcBlock proc in RuneEngine.runeGraph!.procBlocks) {
      if (proc.inputs != null) {
        for (String input in proc.inputs!) {
          if (input == connection) {
            Node node = Node.Id(nodes.length);
            Map<String, dynamic> meta = {
              "id": nodes.length,
              "name": proc.name,
              "type": "proc",
              "outputs": proc.outputs,
              "inputs": proc.inputs,
              "args": proc.path
            };
            nodes.add(node);
            metaNode.add(meta);
            if (proc.inputs != null) {
              for (String con in proc.inputs!) {
                addConnection(con, meta["id"]);
              }
            }
            if (proc.outputs != null) {
              for (String con in proc.outputs!) {
                addConnection(con, meta["id"]);
              }
            }
            if (proc.outputs != null) {
              for (String output in proc.outputs!) {
                addProcBlocks(output);
              }
            }
          }
        }
      }
    }
  }

  void addConnection(String uuid, int nodeId) {
    if (!connections.containsKey(uuid)) {
      connections[uuid] = [];
    }
    connections[uuid]!.add(nodeId);
  }

  void initState() {
    buildGraph();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Background(),
      Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            leadingWidth: 42,
            backgroundColor: Colors.transparent,
            title: Text(
              'Rune Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            actions: [
              IconButton(
                  icon: Image.asset(
                    "assets/images/icons/notification.png",
                    width: 16,
                  ),
                  onPressed: () {}),
              Center(
                  child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        barneyPurpleColor.withAlpha(150),
                        indigoBlueColor.withAlpha(150),
                      ],
                    )),
                width: 30,
                height: 30,
                child: IconButton(
                    icon: Icon(Icons.segment, size: 16),
                    splashColor: Colors.white,
                    splashRadius: 21,
                    onPressed: () {}),
              )),
              Container(
                width: 10,
              )
            ],
          ),
          body: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: InteractiveViewer(
                constrained: false,
                boundaryMargin: EdgeInsets.all(200),
                minScale: 0.01,
                maxScale: 5.6,
                child: GraphView(
                  graph: graph,
                  algorithm: SugiyamaAlgorithm(builder),
                  builder: (Node node) {
                    var a = node.key!.value as int;
                    return rectangleWidget(a);
                  },
                )),
          )),
    ]);
  }

  Widget rectangleWidget(int a) {
    if (metaNode[a]["type"] == "con") {
      Tensor tensor = RuneEngine.runeGraph!.tensors["${metaNode[a]["name"]}"]!;
      Color color = Colors.grey[800]!;
      return Card(
          shape: RoundedRectangleBorder(
            //side: BorderSide(color: Colors.white.withAlpha(50), width: 2),
            side: BorderSide(color: color.withAlpha(250), width: 1),
            borderRadius: BorderRadius.circular(19.0),
          ),
          color: color,
          margin: EdgeInsets.all(0),
          child: Container(
              padding: EdgeInsets.all(5),
              child: Text(
                " ${tensor.elementType} ${tensor.dimensions}",
                style: TextStyle(color: Colors.white, fontSize: 8),
              )));
    }

    String name = "${metaNode[a]["name"]}";

    if (name.split("_").length > 1) {
      name = name.split("_")[0];
    }
    String description = "${metaNode[a]["args"]}";
    Color color = Colors.purple[200]!;
    if (metaNode[a]["type"] == "model") {
      color = Colors.pink;
    }
    if (metaNode[a]["type"] == "proc") {
      color = Colors.green[900]!;
    }
    if (metaNode[a]["type"] == "output") {
      color = Colors.blueAccent;
    }
    return InkWell(
        onTap: () {
          print('clicked');
        },
        child: Card(
            shape: RoundedRectangleBorder(
              //side: BorderSide(color: Colors.white.withAlpha(50), width: 2),
              side: BorderSide(color: color.withAlpha(250), width: 2),
              borderRadius: BorderRadius.circular(19.0),
            ),
            color: color,
            margin: EdgeInsets.all(0),
            child: Container(
              //margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
              height: 80,
              width: 120,
              //padding: EdgeInsets.all(3),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                      color: Colors.white.withAlpha(60),
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Stack(children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                            child: Text(
                              "$name",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            )),
                        Container(
                          padding: EdgeInsets.all(5),
                          child: Center(
                              child: Text(
                            description,
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          )),
                        ),
                      ]))),
            )));
  }
}
