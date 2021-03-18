// ignore_for_file: public_member_api_docs

import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'model/models.dart';

void main() => runApp(Report('Kasun Atulugama'));


class Report extends StatelessWidget {
  Report(this.title){
    _getProjects();
  }

  final String title;
  final List<ProjectModel> _projects = [];

  _getProjects() async {

    FirebaseFirestore.instance.collection('projects').get().then((value) {
      print("Length of project list " + value.docs.length.toString());

//      for (var i = 0; i <= _projects.length - 1; i++) {
//        superkey.currentState.removeItem(0,
//                (BuildContext context, Animation<double> animation) {
//              return Container();
//            });
//      }
      _projects.clear();

      ProjectModel projectModel;
      value.docs.forEach((element) {
        projectModel = ProjectModel(
            element.data().containsKey("pid")
                ? element["pid"]
                : "",
            element.data().containsKey("project_name")
                ? element["project_name"]
                : "",
            element.data().containsKey("start_date")
                ? element["start_date"]
                : "",
            element.data().containsKey("end_date") ? element["end_date"] : "",
            element.data().containsKey("cost")
                ? element["cost"]
                : "",
            element.data().containsKey("manager_name")
                ? element["manager_name"]
                : "",
            element.data().containsKey("client") ? element["client"] : "",
            element.data().containsKey("status") ? element["status"] : "",
            element.data().containsKey("manager") ? element["manager"] : ""
//            element.id);
        );

        _projects.add(projectModel);
//        superkey.currentState.insertItem(_projects.length - 1);
      });
      print(_projects.length);
      print(_projects);
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Report")),
        body: PdfPreview(
          build: (format) => _generatePdf(format, title),
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document();

    const tableHeaders = ['Project Name', 'Reason'];

    const dataTable = [
      ['Flutter Project 1', 'Reason 1'],
      ['Flutter Project 2', 'Reason 2' ],
      ['Flutter Project 3', 'Reason 1' ],
      ['Flutter Project 4', 'Reason 1' ],
      ['Flutter Project 5', 'Reason 1' ],
      ['Flutter Project 6', 'Reason 1' ],
      ['Flutter Project 7', 'Reason 1' ],
    ];

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {

          // Data table
          final table = pw.Table.fromTextArray(
            border: null,
            headers: tableHeaders,
            data: List<List<dynamic>>.generate(
              dataTable.length,
                  (index) => <dynamic>[
                dataTable[index][0],
                dataTable[index][1],
              ],
            ),
            headerHeight: 5,
            headerStyle: pw.TextStyle(
              color: PdfColors.red400,
              fontSize: 25,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: pw.BoxDecoration(
            ),
            rowDecoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  width: .5,
                ),
              ),
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {0: pw.Alignment.centerLeft},
          );

          // Page layout
          return pw.Column(
            children: [
              pw.Text('On Hold Projects Report',
                  style: pw.TextStyle(
                    fontSize: 40,
                  )),
              pw.Divider(thickness: 4),
              pw.Expanded(
                flex: 2,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(width: 10),
                    pw.Expanded(child: table),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}