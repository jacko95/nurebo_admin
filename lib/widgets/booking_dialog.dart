import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nurebo_admin/models/reservation.dart';
import 'package:nurebo_admin/models/reservation_proposal.dart';
import 'package:nurebo_admin/models/reservation_proposal_datetime.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:provider/provider.dart';

class BookingDialog extends StatefulWidget {
  // final Reservation? reservation;

  const BookingDialog({super.key});

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  int _currentExpandedIndex = 0;
  DateTime? _selectedDate;
  // final Map<DateTime, List<TimeOfDay>> _selectedTimeSlots = {};
  final List<DateTime> _selectedDateTimes = [];
  late BusinessProvider businessProvider;
  List<DateTime> dateTimeSlots = [];
  late SocketProvider socketProvider;


  Future getBusinessWeekdayTimetable(DateTime datetime) async {
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/timetable/${datetime.weekday}");

    var response = await http.get(
        url,
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'Business-Mobile-App',
        }
    );

    dateTimeSlots.clear();
    if(response.statusCode >= 400) {
      setState(() {
        _currentExpandedIndex = 0;
      });
    }
    else if(response.statusCode >= 200 && response.statusCode < 400) {

      dynamic jsonData = json.decode(response.body);

      print('jsonData120055');
      print(jsonData);

      for (var e in jsonData) {
        int? openHour = int.tryParse(e['open_at_hour']);
        int? openMinute = int.tryParse(e['open_at_minute']);
        int? closeHour = int.tryParse(e['close_at_hour']);
        int? closeMinute = int.tryParse(e['close_at_minute']);

        // Costruiamo DateTime per l'apertura e la chiusura utilizzando il giorno preso in input
        DateTime start = DateTime(datetime.year, datetime.month, datetime.day, openHour!, openMinute!);
        DateTime end = DateTime(datetime.year, datetime.month, datetime.day, closeHour!, closeMinute!);

        DateTime current = start;

        // Ciclo per generare i DateTime a intervalli di 30 minuti
        while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
          dateTimeSlots.add(current);
          current = current.add(Duration(minutes: 30));
        }

        dateTimeSlots.sort((a, b) => a.compareTo(b));

        setState(() {
          _currentExpandedIndex = 1;
        });

        // Stampa dei DateTime creati per il business corrente
        print("Orari per ${e['name']}:");
        for (DateTime slot in dateTimeSlots) {
          print(slot);
        }
        print('-------------------------');
      }

      return jsonData;
    }
  }

  void _toggleExpansion(int index) {
    setState(() => _currentExpandedIndex = _currentExpandedIndex == index ? -1 : index);
  }

  // void _handleDateSelection(DateTime? date) async {
  //   setState(() {
  //     _selectedDate = date;
  //     // _currentExpandedIndex = date != null ? 1 : -1;
  //
  //     if (date != null) {
  //       _selectedTimeSlots[date] ??= [];
  //     }
  //   });
  //   await getBusinessWeekdayTimetable(date!);
  // }
  void _handleDateSelection(DateTime? date) async {
    setState(() {
      _selectedDate = date;
    });
    if (date != null) await getBusinessWeekdayTimetable(date);
  }

  // void _toggleTime(TimeOfDay time) {
  //   if (_selectedDate == null) return;
  //
  //   setState(() {
  //     final times = _selectedTimeSlots[_selectedDate]!;
  //     times.contains(time) ? times.remove(time) : times.add(time);
  //   });
  // }
  void _toggleTime(DateTime dateTime) {
    setState(() {
      if (_selectedDateTimes.contains(dateTime)) {
        _selectedDateTimes.remove(dateTime);
      } else {
        _selectedDateTimes.add(dateTime);
      }
    });
  }

  Widget _buildCalendarSection(double screenWidth) => Accordion(
    index: 0,
    title: _selectedDate != null
        ? "Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}"
        : "Seleziona Data",
    content: SizedBox(
      width: screenWidth * 0.8,
      height: 300,
      child: CalendarDatePicker2(
        config: CalendarDatePicker2Config(
          calendarType: CalendarDatePicker2Type.single,
          selectedDayHighlightColor: Colors.green[800],
          weekdayLabels: ['Dom', 'Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab'],
          weekdayLabelTextStyle: const TextStyle(fontSize: 12),
        ),
        value: _selectedDate != null ? [_selectedDate] : [],
        onValueChanged: (dates) => _handleDateSelection(dates.isNotEmpty ? dates.first : null),
      ),
    ),
    isExpanded: _currentExpandedIndex == 0,
    onTap: () => setState(() => _currentExpandedIndex = _currentExpandedIndex == 0 ? -1 : 0),
  );

  // Widget _buildTimeSection() {
  //   return Accordion(
  //     index: 1,
  //     title: _selectedDate != null /*&& _selectedTimeSlots[_selectedDate]!.isNotEmpty*/
  //         ? "Orari selezionati: ${_selectedTimeSlots[_selectedDate] == null ? 0 : _selectedTimeSlots[_selectedDate]?.length}"
  //         : "Seleziona Orari",
  //     content: _buildTimeGrid(),
  //     isExpanded: _currentExpandedIndex == 1,
  //     onTap: () => setState(() => _currentExpandedIndex = _currentExpandedIndex == 1 ? -1 : 1),
  //   );
  // }
  Widget _buildTimeSection() {
    return Accordion(
      index: 1,
      title: _selectedDate != null
          ? "Orari selezionati: ${_selectedDateTimes.where((dt) =>
      dt.year == _selectedDate!.year &&
          dt.month == _selectedDate!.month &&
          dt.day == _selectedDate!.day
      ).length}"
          : "Seleziona Orari",
      content: _buildTimeGrid(),
      isExpanded: _currentExpandedIndex == 1,
      onTap: () => setState(() => _currentExpandedIndex = _currentExpandedIndex == 1 ? -1 : 1),
    );
  }

  // Widget _buildSummaryCard(DateTime date, TimeOfDay time) => Card(
  //   margin: const EdgeInsets.symmetric(vertical: 4),
  //   child: ListTile(
  //     contentPadding: const EdgeInsets.only(left: 16, right: 4),
  //     title: Text("${DateFormat('dd/MM/yyyy').format(date)} - ${time.format(context)}"),
  //     trailing: Padding(
  //       padding: const EdgeInsets.only(right: 0.0),
  //       child: IconButton(
  //         icon: const Icon(Icons.close, size: 22),
  //         onPressed: () => setState(() {
  //           _selectedTimeSlots[date]?.remove(time);
  //           if (_selectedTimeSlots[date]?.isEmpty ?? true) {
  //             _selectedTimeSlots.remove(date);
  //           }
  //         }),
  //       ),
  //     ),
  //   ),
  // );
  Widget _buildSummaryCard(DateTime dateTime) => Card(
    child: ListTile(
      title: Text(DateFormat('dd/MM/yyyy - HH:mm').format(dateTime)),
      trailing: IconButton(
        onPressed: () => setState(() => _selectedDateTimes.remove(dateTime)),
        icon: const Icon(Icons.close),
      ),
    ),
  );

  Widget _buildActionButtons() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('ANNULLA'),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: /*_selectedTimeSlots*/_selectedDateTimes.isNotEmpty ? () {
          // Navigator.pop(context, {'prenotazioni': _selectedTimeSlots});
          Navigator.pop(context, _selectedDateTimes);
          // _selectedTimeSlots.forEach((date, times) {
          //   for (final time in times) {
          //     print('📅 ${DateFormat('dd/MM/yyyy').format(date)} ---- ⏰ ${time.format(context)}');
          //   }
          // });
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[800],
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: const Text('CONFERMA', style: TextStyle(color: Colors.white)),
      ),
    ],
  );

  Widget _buildTimeGrid() {
    // final timeSlots = List.generate(21, (i) => TimeOfDay(hour: 12 + i ~/ 2, minute: (i % 2) * 30));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.2,
      ),
      // itemCount: timeSlots.length,
      itemCount: dateTimeSlots.length,
      itemBuilder: (context, index) {
        // final time = timeSlots[index];
        // final time = TimeOfDay.fromDateTime(dateTimeSlots[index]);
        // final isSelected = _selectedDate != null && _selectedTimeSlots[_selectedDate]?.contains(time) == true;
        final dateTime = dateTimeSlots[index];
        final isSelected = _selectedDateTimes.contains(dateTime);

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.green[800] : Colors.grey[200],
            foregroundColor: isSelected ? Colors.white : Colors.black,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ), // Parentesi aggiunta qui
          // onPressed: () => _toggleTime(time),
          onPressed: () => _toggleTime(dateTime),
          // child: Text(time.format(context), style: const TextStyle(fontSize: 14)),
          child: Text(DateFormat('HH:mm').format(dateTime)),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    final today = DateTime.now();
    _selectedDate = today;
    // _selectedTimeSlots[today] = [];
    Future.wait([
      getBusinessWeekdayTimetable(DateTime.now()),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Seleziona Data e Orario',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildCalendarSection(screenWidth),
                        const SizedBox(height: 16),
                        if (_selectedDate != null) _buildTimeSection(),
                        const SizedBox(height: 16),
                        // if (_selectedTimeSlots.isNotEmpty)
                        if (_selectedDateTimes.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Prenotazioni selezionate:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              // ..._selectedTimeSlots.entries.expand((entry) => entry.value.map((time) => _buildSummaryCard(entry.key, time))),
                              ..._selectedDateTimes.map((dateTime) => _buildSummaryCard(dateTime)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class Accordion extends StatelessWidget {
  final int index;
  final String title;
  final Widget content;
  final bool isExpanded;
  final VoidCallback onTap;

  const Accordion({
    super.key,
    required this.index,
    required this.title,
    required this.content,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ), // Parentesi aggiunta qui
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 24),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: double.infinity,
            padding: isExpanded ? const EdgeInsets.only(top: 12) : EdgeInsets.zero,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isExpanded ? content : null,
            ),
          ),
        ),
      ],
    );
  }
}