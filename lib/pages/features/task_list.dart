import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:purrfect_compawnion/models/myuser.dart';
import 'package:purrfect_compawnion/models/task.dart';
import 'package:purrfect_compawnion/pages/features/edit_task.dart';
import 'package:purrfect_compawnion/services/database.dart';
import 'package:purrfect_compawnion/shared/constants.dart';
import '../../services/notification_services.dart';
import '../ui/widgets/task_tile.dart';

class TaskList extends StatefulWidget {
  DateTime selectedDate = DateTime.now();

  TaskList({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<String> taskDifficultyList = ["Easy", "Normal", "Hard"];

  late DateTime _selectedDate;
  var notifyHelper;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    _selectedDate = widget.selectedDate;
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    return _showTaskList(user);
  }

  _showTaskList(user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection("tasks")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();
        else {
          return Expanded(
            child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  Task task = _taskFromDoc(doc);
                  var taskEnd = task.getEndTime();

                  if (task.repeat == "Daily" ||
                      (task.getDate().year == _selectedDate.year &&
                          task.getDate().month == _selectedDate.month &&
                          task.getDate().day == _selectedDate.day) ||
                      taskEnd.isBefore(DateTime.now()) ||
                      (task.repeat == "Weekly" && task.getDate().weekday == _selectedDate.weekday) ||
                      (task.repeat == "Monthly" && task.getDate().day == _selectedDate.day)
                  ) {
                    return AnimationConfiguration.staggeredList(
                        position: index,
                        child: SlideAnimation(
                            child: FadeInAnimation(
                                child: Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  _showBottomSheet(context, task, doc.id);
                                },
                                child: TaskTile(task: task))
                          ],
                        ))));
                  } else {
                    return Container();
                  }
                }),
          );
        }
      },
    );
  }

  _taskFromDoc(doc) {
    return Task(
      title: doc['title'],
      note: doc['note'],
      isCompleted: doc['isCompleted'],
      date: doc['date'],
      startTime: doc['startTime'],
      endTime: doc['endTime'],
      color: doc['color'],
      remind: doc['remind'],
      repeat: doc['repeat'],
      difficulty: doc['difficulty'],
    );
  }

  _showBottomSheet(BuildContext context, Task task, String id) {
    final user = Provider.of<MyUser>(context, listen: false);

    Get.bottomSheet(Container(
      padding: const EdgeInsets.only(top: 4),
      height: task.isCompleted == 1
          ? MediaQuery.of(context).size.height * 0.18
          : MediaQuery.of(context).size.height * 0.32,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
          ),
          Spacer(),
          task.isCompleted == 1
              ? Container()
              : _buttonSheetButton(
                  label: "Task Completed",
                  onTap: () async => {
                        await DatabaseService(uid: user.uid).completeTask(id, task.difficulty),
                        Get.back(),
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: const Text("Congratulations!"),
                                  content: Text(
                                      "Congratulations on completing a ${taskDifficultyList[task.difficulty!]} task! You have been rewarded ${reward[task.difficulty!]} food to feed your pet!"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'OK'),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                )),
                      },
                  color: Colors.blue,
                  context: context),
          task.isCompleted == 1
              ? Container()
              : _buttonSheetButton(
                  label: "Edit Task",
                  onTap: () async {
                    Get.back();
                    await Get.to(() => EditTask(task: task, id: id));
                  },
                  color: Colors.pink,
                  context: context),
          _buttonSheetButton(
              label: "Delete Task",
              onTap: () async {
                    await DatabaseService(uid: user.uid).deleteTask(id);
                    await notifyHelper.editScheduledNotification(id, null);
                    Get.back();
                  },
              color: Colors.red,
              context: context),
          _buttonSheetButton(
              label: "Cancel",
              onTap: () => Get.back(),
              color: Colors.white,
              isClose: true,
              context: context),
        ],
      ),
    ));
  }

  _buttonSheetButton(
      {required String label,
      required Function()? onTap,
      required Color color,
      bool isClose = false,
      required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        height: 50,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: isClose ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(20.0),
          border: isClose ? Border.all(color: Colors.grey) : null,
        ),
        child: Center(
            child: Text(
          label,
          style: isClose
              ? titleStyle
              : titleStyle.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold),
        )),
      ),
    );
  }
}
