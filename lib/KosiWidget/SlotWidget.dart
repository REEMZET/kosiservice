import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SlotWidget extends StatefulWidget {
  final void Function(String daySlot, String timeSlot) onSelectionChanged;

  const SlotWidget({Key? key, required this.onSelectionChanged})
      : super(key: key);

  @override
  State<SlotWidget> createState() => _SlotWidgetState();
}

List<String> timeSlots = [];
List<String> dateSlots = [];
String selectedTimeSlot = '';
String selectedDaySlot = '';

class _SlotWidgetState extends State<SlotWidget> {
  void onTimeSlotSelected(String timeSlot) {
    setState(() {
      selectedTimeSlot = timeSlot;
      widget.onSelectionChanged(selectedDaySlot, selectedTimeSlot);
    });
  }

  void onDaySlotSelected(String daySlot) {
    setState(() {
      selectedDaySlot = daySlot;
      widget.onSelectionChanged(selectedDaySlot, selectedTimeSlot);
    });
  }

  List<String> generateTimeSlots() {
    String startTime = "6:00 AM";
    String endTime = "9:00 PM";

    DateFormat sdf = DateFormat("hh:mm a");

    DateTime currentTime = sdf.parse(startTime);
    DateTime endTimeDateTime = sdf.parse(endTime);

    List<String> timeSlots = [];

    while (currentTime.isBefore(endTimeDateTime)) {
      timeSlots.add(sdf.format(currentTime));
      currentTime = currentTime.add(Duration(minutes: 60));
    }

    timeSlots.add(endTime);

    return timeSlots;
  }

  List<String> generateDateSlots() {
    List<String> dateSlots = [];

    DateFormat dateFormat = DateFormat('dd MMM');

    DateTime currentDate = DateTime.now();

    for (int i = 0; i < 7; i++) {
      String formattedDate = dateFormat.format(currentDate);

      dateSlots.add(formattedDate);

      currentDate = currentDate.add(Duration(days: 1));
    }

    return dateSlots;
  }

  @override
  initState() {
    super.initState();
    timeSlots = generateTimeSlots();
    dateSlots = generateDateSlots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChooseDaySlot(dateSlots, onDaySlotSelected),
        ChooseTimeSlot(timeSlots, selectedTimeSlot, onTimeSlotSelected),
      ],
    );
  }
}

class ChooseDaySlot extends StatelessWidget {
  final List<String> dateSlots;
  final Function(String) onDaySlotSelected;

  ChooseDaySlot(this.dateSlots, this.onDaySlotSelected);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(6),
          alignment: Alignment.topLeft,
          child: Text(
            'Choose Day Slot',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          height: 40,
          alignment: Alignment.center,
          child: Slots(dateSlots, selectedDaySlot, onDaySlotSelected),
        ),
      ],
    );
  }
}

class ChooseTimeSlot extends StatelessWidget {
  final List<String> timeSlots;
  final String selectedTimeSlot;
  final Function(String) onTimeSlotSelected;

  ChooseTimeSlot(
      this.timeSlots, this.selectedTimeSlot, this.onTimeSlotSelected);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(6),
          alignment: Alignment.topLeft,
          child: Text(
            'Choose Time Slot',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          height: 40,
          alignment: Alignment.center,
          child: Slots(timeSlots, selectedTimeSlot, onTimeSlotSelected),
        ),
      ],
    );
  }
}

class Slots extends StatefulWidget {
  final List<String> list;
  final String selectedItem;
  final Function(String) onSlotSelected;

  Slots(this.list, this.selectedItem, this.onSlotSelected);

  @override
  State<Slots> createState() => _SlotsState();
}

class _SlotsState extends State<Slots> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(widget.list.length, (index) {
        return Card(
          elevation: 1,
          color: widget.list[index] == widget.selectedItem
              ? Color(0xff01e9a3)
              : Colors.white70,
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(2),
            padding: EdgeInsets.all(4),
            child: InkWell(
              child: Text(
                widget.list[index],
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                widget.onSlotSelected(widget.list[index]);
              },
            ),
          ),
        );
      }),
    );
  }
}