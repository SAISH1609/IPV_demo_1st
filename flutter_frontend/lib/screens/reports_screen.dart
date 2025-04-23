import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/attendance.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Attendance> _attendances = [];
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  Future<void> _loadAttendances() async {
    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final attendances = await apiService.getReports(
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() => _attendances = attendances);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : DateTimeRange(start: DateTime.now(), end: DateTime.now()),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadAttendances();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _attendances.isEmpty
              ? const Center(child: Text('No attendance records found'))
              : ListView.builder(
                itemCount: _attendances.length,
                itemBuilder: (context, index) {
                  final attendance = _attendances[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(attendance.checkInTime)}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check-in: ${DateFormat('hh:mm a').format(attendance.checkInTime)}',
                          ),
                          if (attendance.checkOutTime != null)
                            Text(
                              'Check-out: ${DateFormat('hh:mm a').format(attendance.checkOutTime!)}',
                            ),
                          Text('Status: ${attendance.status}'),
                          Text(
                            'Confidence: ${(attendance.confidence * 100).toStringAsFixed(2)}%',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
