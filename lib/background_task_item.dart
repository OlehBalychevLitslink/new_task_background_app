import 'background_task_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BackgroundTaskItem extends StatelessWidget {
  final BackgroundTaskModel model;

  const BackgroundTaskItem({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(child: Text(model.taskName)),
                Expanded(
                    child: Text(
                  model.platform,
                  textAlign: TextAlign.center,
                )),
                Expanded(
                    child: Text(
                  model.executionDateTime != null
                      ? DateFormat('dd/MM/yyyy\nkk:mm:ss')
                          .format(model.executionDateTime!)
                      : 'DateTime not set',
                  textAlign: TextAlign.right,
                )),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  model.uuid,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
