// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:purrfect_compawnion/pages/ui/widgets/button.dart';
import 'package:purrfect_compawnion/pages/ui/widgets/input_field.dart';
import 'package:intl/intl.dart';
import 'package:purrfect_compawnion/services/database.dart';
import 'package:purrfect_compawnion/shared/constants.dart';

import '../../models/myuser.dart';
import '../../models/task.dart';
import '../../services/notification_services.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  // final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _endTime = "9:30 PM";
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];

  String _selectedRepeat = "None";
  List<String> repeatList = ["None", "Daily", "Weekly", "Monthly"];
  int _selectedColor = 0;
  int _selectedDifficulty = 0;
  var notifyHelper;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();

    return Scaffold(
      appBar: _appBar(context),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyInputField(
                title: "Title",
                hint: "Enter your title",
                controller: _titleController,
              ),
              MyInputField(
                title: "Note",
                hint: "Enter your note",
                controller: _noteController,
              ),
              MyInputField(
                title: "Date",
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  icon: Icon(Icons.calendar_today_outlined, color: Colors.grey),
                  onPressed: () {
                    _getDateFromUser();
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: MyInputField(
                      title: "Start Time",
                      hint: _startTime,
                      widget: IconButton(
                        onPressed: () {
                          _getTimeFromUser(isStartTime: true);
                        },
                        icon:
                            Icon(Icons.access_time_rounded, color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: MyInputField(
                      title: "End Time",
                      hint: _endTime,
                      widget: IconButton(
                        onPressed: () {
                          _getTimeFromUser(isStartTime: false);
                        },
                        icon:
                            Icon(Icons.access_time_rounded, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              MyInputField(
                title: "Remind",
                hint: "$_selectedRemind minutes early",
                widget: DropdownButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  iconSize: 32,
                  elevation: 4,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey),
                  ),
                  underline: Container(
                    height: 0,
                  ),
                  items: remindList.map<DropdownMenuItem<String>>((int value) {
                    return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRemind = int.parse(newValue!);
                    });
                  },
                ),
              ),
              MyInputField(
                title: "Repeat",
                hint: "$_selectedRepeat",
                widget: DropdownButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  iconSize: 32,
                  elevation: 4,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey),
                  ),
                  underline: Container(
                    height: 0,
                  ),
                  items:
                      repeatList.map<DropdownMenuItem<String>>((String? value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value!, style: TextStyle(color: Colors.grey)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRepeat = newValue!;
                    });
                  },
                ),
              ),
              SizedBox(height: 12.0),
              _colorPallete(),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Difficulty",
                        style: titleStyle,
                      ),
                      SizedBox(height: 6.0),
                      Row(
                        children: [
                          Text("Easy"),
                          Wrap(
                            children: List<Widget>.generate(
                                3,
                                (index) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedDifficulty = index;
                                        });
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          _selectedDifficulty == index
                                              ? Icons.check_circle_outline
                                              : Icons.circle_outlined,
                                        ),
                                      ),
                                    )),
                          ),
                          Text("Hard"),
                        ],
                      ),
                    ],
                  ),
                  MyButton(
                      label: "Create Task", onTap: () => _validateDate(user))
                ],
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  _validateDate(user) {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToDb(user);
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar("Required", "All fields are required !",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          icon: Icon(Icons.warning_amber_rounded));
    }
  }

  _addTaskToDb(user) async {
    Task newTask = new Task(
      note: _noteController.text,
      title: _titleController.text,
      date: DateFormat.yMd().format(_selectedDate),
      startTime: _startTime,
      endTime: _endTime,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      color: _selectedColor,
      isCompleted: 0,
      difficulty: _selectedDifficulty,
    );
    String id = await DatabaseService(uid: user.uid).addTask(newTask);
    notifyHelper.scheduledNotification(id, newTask);
  }

  _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: appBarColor,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
      ),
      title: Text("Add Task"),
    );
  }

  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2042));

    if (_pickerDate != null) {
      setState(() {
        _selectedDate = _pickerDate;
        print(_selectedDate);
      });
    } else {
      print("it's null or something is wrong");
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    var pickedTime = await _showTimePicker();
    String _formatedTime = pickedTime.format(context);
    if (pickedTime == null) {
      print("Time canceled");
    } else if (isStartTime == true) {
      setState(() {
        _startTime = _formatedTime;
      });
    } else if (isStartTime == false) {
      setState(() {
        _endTime = _formatedTime;
      });
    }
  }

  _showTimePicker() {
    return showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
            hour: int.parse(_startTime.split(":")[0]),
            minute: int.parse(_startTime.split(":")[1].split(" ")[0])));
  }

  _colorPallete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Color",
          style: titleStyle,
        ),
        SizedBox(height: 6.0),
        Wrap(
          children: List<Widget>.generate(
              3,
              (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: index == 0
                            ? taskColor1
                            : index == 1
                                ? taskColor2
                                : taskColor3,
                        child: _selectedColor == index
                            ? Icon(
                                Icons.done,
                                color: Colors.white,
                                size: 16.0,
                              )
                            : Container(),
                      ),
                    ),
                  )),
        )
      ],
    );
  }
}
